import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../features/reports/domain/report_models.dart';
import '../../errors/exceptions.dart';
import '../app_database.dart';
import '../converters.dart';
import '../tables/tables.dart';

part 'sales_dao.g.dart';

/// Request model for checking out a line item in POS.
class CheckoutItemRequest {
  final String productId;
  final int quantity;
  final double? unitSellingPrice;
  final double lineDiscountAmount;
  final String? preferredBatchId;

  CheckoutItemRequest({
    required this.productId,
    required this.quantity,
    this.unitSellingPrice,
    this.lineDiscountAmount = 0.0,
    this.preferredBatchId,
  });
}

/// Result returned after successful atomic checkout.
class CompletedCheckoutResult {
  final Sale sale;
  final List<SaleItem> items;

  CompletedCheckoutResult({
    required this.sale,
    required this.items,
  });
}

/// Sales and profit calculation DAO.
@DriftAccessor(tables: [SalesTable, SaleItemsTable, ProductBatchesTable])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  static const _isoConverter = IsoDateTimeConverter();
  static const _uuid = Uuid();

  /// Atomic transaction: Inserts invoice header and line items.
  Future<void> recordSale({
    required SalesTableCompanion sale,
    required List<SaleItemsTableCompanion> items,
  }) async {
    await db.transaction(() async {
      await into(salesTable).insert(sale);
      for (final item in items) {
        await into(saleItemsTable).insert(item);
      }
    });
  }

  /// Generates the next sequential invoice number for a given day (e.g. INV-YYYYMMDD-0001).
  Future<String> generateNextInvoiceNumber(String pharmacyUid, DateTime date) async {
    final prefix = 'INV-${DateFormat('yyyyMMdd').format(date)}-';
    final existingSales = await (select(salesTable)
          ..where((tbl) =>
              tbl.pharmacyUid.equals(pharmacyUid) &
              tbl.invoiceNumber.like('$prefix%')))
        .get();

    int highest = 0;
    for (final s in existingSales) {
      final parts = s.invoiceNumber.split('-');
      if (parts.length >= 3) {
        final seq = int.tryParse(parts[2]);
        if (seq != null && seq > highest) {
          highest = seq;
        }
      }
    }
    final nextSeq = (highest + 1).toString().padLeft(4, '0');
    return '$prefix$nextSeq';
  }

  /// Atomic checkout transaction:
  /// 1. Queries active batches in FEFO order (earliest expiry first).
  /// 2. Blocks sale if any allocated batch is expired.
  /// 3. Validates inventory sufficiency and throws [InsufficientStockException] on shortage.
  /// 4. Deducts exact batch stock and marks batches with 'pending_update'.
  /// 5. Inserts [Sale] and [SaleItem] records marked as 'pending_insert' for future cloud sync.
  Future<CompletedCheckoutResult> executeAtomicCheckout({
    required String pharmacyUid,
    required String cashierUserId,
    required List<CheckoutItemRequest> items,
    String customerName = 'Walk-in Customer',
    String? customerPhone,
    double invoiceDiscount = 0.0,
    required double amountTendered,
    String paymentMethod = 'Cash',
  }) async {
    if (items.isEmpty) {
      throw AppException('Cart is empty. Cannot checkout an empty sale.');
    }

    return db.transaction(() async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final saleId = _uuid.v4();

      double totalCostPrice = 0.0;
      double itemsSubtotal = 0.0;
      final saleItemsToInsert = <SaleItemsTableCompanion>[];
      final insertedSaleItems = <SaleItem>[];

      for (final req in items) {
        if (req.quantity <= 0) {
          throw AppException('Invalid quantity for product ${req.productId}: ${req.quantity}');
        }

        // 1. Fetch available non-expired batches sorted by FEFO
        final batchesQuery = select(productBatchesTable)
          ..where((tbl) =>
              tbl.pharmacyUid.equals(pharmacyUid) &
              tbl.productId.equals(req.productId) &
              tbl.currentStock.isBiggerThanValue(0) &
              tbl.deletedAt.isNull());

        if (req.preferredBatchId != null) {
          batchesQuery.where((tbl) => tbl.id.equals(req.preferredBatchId!));
        }

        batchesQuery.orderBy([
          (tbl) => OrderingTerm(expression: tbl.expiryDate, mode: OrderingMode.asc),
        ]);

        final batches = await batchesQuery.get();

        // 2. Strict Expired Batch Blockage
        final validBatches = <ProductBatch>[];
        for (final b in batches) {
          if (b.expiryDate.isBefore(today)) {
            // If an expired batch was explicitly requested, hard block
            if (req.preferredBatchId == b.id) {
              throw ExpiredBatchSaleBlockedException(
                batchNumber: b.batchNumber,
                expiryDate: b.expiryDate,
              );
            }
          } else {
            validBatches.add(b);
          }
        }

        final totalAvailable = validBatches.fold<int>(0, (sum, b) => sum + b.currentStock);
        if (totalAvailable < req.quantity) {
          final hasExpired = batches.any((b) => b.expiryDate.isBefore(today));
          final totalWithExpired = batches.fold<int>(0, (s, b) => s + b.currentStock);
          if (hasExpired && totalWithExpired >= req.quantity) {
            final firstExpired = batches.firstWhere((b) => b.expiryDate.isBefore(today));
            throw ExpiredBatchSaleBlockedException(
              batchNumber: firstExpired.batchNumber,
              expiryDate: firstExpired.expiryDate,
            );
          }

          throw InsufficientStockException(
            productId: req.productId,
            requestedQuantity: req.quantity,
            availableStock: totalAvailable,
          );
        }

        // 3. Deduct stock across validBatches in FEFO order
        int remainingToDeduct = req.quantity;
        for (final batch in validBatches) {
          if (remainingToDeduct <= 0) break;

          if (batch.expiryDate.isBefore(today)) {
            throw ExpiredBatchSaleBlockedException(
              batchNumber: batch.batchNumber,
              expiryDate: batch.expiryDate,
            );
          }

          final deduction = remainingToDeduct <= batch.currentStock
              ? remainingToDeduct
              : batch.currentStock;
          final newStock = batch.currentStock - deduction;

          // Deduct exact batch stock with pending_update CDC status
          await (update(productBatchesTable)..where((tbl) => tbl.id.equals(batch.id))).write(
            ProductBatchesTableCompanion(
              currentStock: Value(newStock),
              updatedAt: Value(now),
              syncStatus: const Value('pending_update'),
            ),
          );

          final unitSellingPrice = req.unitSellingPrice ?? batch.sellingPrice;
          final sliceSubtotal = unitSellingPrice * deduction;
          final fraction = deduction / req.quantity;
          final sliceDiscount = req.lineDiscountAmount * fraction;
          final sliceLineTotal = (sliceSubtotal - sliceDiscount).clamp(0.0, double.infinity);

          final saleItemId = _uuid.v4();
          final itemCompanion = SaleItemsTableCompanion.insert(
            id: saleItemId,
            pharmacyUid: pharmacyUid,
            saleId: saleId,
            productId: req.productId,
            batchId: batch.id,
            quantity: deduction,
            unitCostPrice: batch.purchasePrice,
            unitSellingPrice: unitSellingPrice,
            lineTotal: sliceLineTotal,
            createdAt: now,
            syncStatus: const Value('pending_insert'),
          );

          saleItemsToInsert.add(itemCompanion);
          insertedSaleItems.add(
            SaleItem(
              id: saleItemId,
              pharmacyUid: pharmacyUid,
              saleId: saleId,
              productId: req.productId,
              batchId: batch.id,
              quantity: deduction,
              unitCostPrice: batch.purchasePrice,
              unitSellingPrice: unitSellingPrice,
              lineTotal: sliceLineTotal,
              createdAt: now,
              deletedAt: null,
              syncStatus: 'pending_insert',
            ),
          );

          totalCostPrice += batch.purchasePrice * deduction;
          itemsSubtotal += sliceSubtotal;
          remainingToDeduct -= deduction;
        }
      }

      // 4. Calculate invoice financial totals
      final totalLineDiscounts = items.fold<double>(0.0, (s, i) => s + i.lineDiscountAmount);
      final totalDiscount = totalLineDiscounts + invoiceDiscount;
      final totalPayable = (itemsSubtotal - totalDiscount).clamp(0.0, double.infinity);
      final changeReturned = (amountTendered - totalPayable).clamp(0.0, double.infinity);
      final grossProfit = totalPayable - totalCostPrice;

      // 5. Generate monotonic invoice number
      final invoiceNumber = await generateNextInvoiceNumber(pharmacyUid, now);

      // 6. Insert Sale header
      final saleCompanion = SalesTableCompanion.insert(
        id: saleId,
        pharmacyUid: pharmacyUid,
        invoiceNumber: invoiceNumber,
        cashierUserId: cashierUserId,
        customerName: Value(customerName.trim().isEmpty ? 'Walk-in Customer' : customerName.trim()),
        customerPhone: Value(customerPhone?.trim().isEmpty == true ? null : customerPhone?.trim()),
        subtotal: itemsSubtotal,
        discountAmount: Value(totalDiscount),
        taxAmount: const Value(0.0),
        totalPayable: totalPayable,
        amountTendered: amountTendered,
        changeReturned: changeReturned,
        paymentMethod: paymentMethod,
        totalCostPrice: totalCostPrice,
        grossProfit: grossProfit,
        createdAt: now,
        syncStatus: const Value('pending_insert'),
      );
      await into(salesTable).insert(saleCompanion);

      // 7. Insert all SaleItems
      for (final itemComp in saleItemsToInsert) {
        await into(saleItemsTable).insert(itemComp);
      }

      final completedSale = Sale(
        id: saleId,
        pharmacyUid: pharmacyUid,
        invoiceNumber: invoiceNumber,
        cashierUserId: cashierUserId,
        customerName: customerName.trim().isEmpty ? 'Walk-in Customer' : customerName.trim(),
        customerPhone: customerPhone?.trim().isEmpty == true ? null : customerPhone?.trim(),
        subtotal: itemsSubtotal,
        discountAmount: totalDiscount,
        taxAmount: 0.0,
        totalPayable: totalPayable,
        amountTendered: amountTendered,
        changeReturned: changeReturned,
        paymentMethod: paymentMethod,
        totalCostPrice: totalCostPrice,
        grossProfit: grossProfit,
        createdAt: now,
        deletedAt: null,
        syncStatus: 'pending_insert',
      );

      return CompletedCheckoutResult(
        sale: completedSale,
        items: insertedSaleItems,
      );
    });
  }

  /// Fetches a single sale by its invoice number.
  Future<Sale?> getSaleByInvoiceNumber(String pharmacyUid, String invoiceNumber) {
    return (select(salesTable)
          ..where((tbl) =>
              tbl.pharmacyUid.equals(pharmacyUid) &
              tbl.invoiceNumber.equals(invoiceNumber) &
              tbl.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Fetches all line items for an invoice.
  Future<List<SaleItem>> getSaleItems(String pharmacyUid, String saleId) {
    return (select(saleItemsTable)
          ..where((tbl) =>
              tbl.pharmacyUid.equals(pharmacyUid) &
              tbl.saleId.equals(saleId) &
              tbl.deletedAt.isNull()))
        .get();
  }

  /// Fetches sales for date range.
  Selectable<Sale> getSalesBetween(String pharmacyUid, DateTime start, DateTime end) {
    final startStr = _isoConverter.toSql(start);
    final endStr = _isoConverter.toSql(end);

    return select(salesTable)
      ..where((tbl) =>
          tbl.pharmacyUid.equals(pharmacyUid) &
          tbl.createdAt.isBiggerOrEqualValue(startStr) &
          tbl.createdAt.isSmallerOrEqualValue(endStr) &
          tbl.deletedAt.isNull())
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ]);
  }

  /// Calculates total gross revenue, units sold, and gross profit between dates.
  Future<SalesKpiSummary> getKpiSummary(String pharmacyUid, DateTime start, DateTime end) async {
    final sales = await getSalesBetween(pharmacyUid, start, end).get();
    double totalRevenue = 0.0;
    double totalCost = 0.0;
    double totalProfit = 0.0;
    double totalDiscounts = 0.0;
    int totalUnits = 0;

    final saleIds = sales.map((s) => s.id).toList();
    if (saleIds.isNotEmpty) {
      final items = await (select(saleItemsTable)
            ..where((tbl) => tbl.saleId.isIn(saleIds) & tbl.deletedAt.isNull()))
          .get();
      for (final item in items) {
        totalUnits += item.quantity;
      }
    }

    for (final s in sales) {
      totalRevenue += s.totalPayable;
      totalCost += s.totalCostPrice;
      totalProfit += s.grossProfit;
      totalDiscounts += s.discountAmount;
    }

    return SalesKpiSummary(
      totalInvoices: sales.length,
      totalUnitsSold: totalUnits,
      grossRevenue: totalRevenue,
      totalCostPrice: totalCost,
      grossProfit: totalProfit,
      totalDiscounts: totalDiscounts,
    );
  }

  /// Calculates full performance metrics including payment method distributions.
  Future<ReportKpiMetrics> getReportKpis(String pharmacyUid, DateTime start, DateTime end) async {
    final sales = await getSalesBetween(pharmacyUid, start, end).get();
    double totalRevenue = 0.0;
    double totalCost = 0.0;
    double totalProfit = 0.0;
    double totalDiscounts = 0.0;
    int totalUnits = 0;

    final paymentBreakdown = <String, double>{
      'Cash': 0.0,
      'Card': 0.0,
      'Mobile': 0.0,
      'Due': 0.0,
    };
    final paymentCounts = <String, int>{
      'Cash': 0,
      'Card': 0,
      'Mobile': 0,
      'Due': 0,
    };

    final saleIds = sales.map((s) => s.id).toList();
    if (saleIds.isNotEmpty) {
      final items = await (select(saleItemsTable)
            ..where((tbl) => tbl.saleId.isIn(saleIds) & tbl.deletedAt.isNull()))
          .get();
      for (final item in items) {
        totalUnits += item.quantity;
      }
    }

    for (final s in sales) {
      totalRevenue += s.totalPayable;
      totalCost += s.totalCostPrice;
      totalProfit += s.grossProfit;
      totalDiscounts += s.discountAmount;

      final method = s.paymentMethod;
      paymentBreakdown[method] = (paymentBreakdown[method] ?? 0.0) + s.totalPayable;
      paymentCounts[method] = (paymentCounts[method] ?? 0) + 1;
    }

    return ReportKpiMetrics(
      totalInvoices: sales.length,
      totalUnitsSold: totalUnits,
      grossRevenue: totalRevenue,
      totalCostPrice: totalCost,
      grossProfit: totalProfit,
      totalDiscounts: totalDiscounts,
      paymentBreakdown: paymentBreakdown,
      paymentCounts: paymentCounts,
    );
  }

  /// Fetches detailed sales including cashier full name and itemized breakdown with batches.
  Future<List<DetailedSaleReport>> getDetailedSalesReport(
    String pharmacyUid,
    DateTime start,
    DateTime end,
  ) async {
    final sales = await getSalesBetween(pharmacyUid, start, end).get();
    if (sales.isEmpty) return [];

    final userIds = sales.map((s) => s.cashierUserId).toSet().toList();
    final users = await (db.select(db.usersTable)..where((tbl) => tbl.id.isIn(userIds))).get();
    final userMap = {for (final u in users) u.id: u.fullName};

    final saleIds = sales.map((s) => s.id).toList();

    // Query line items joined with products and batches
    final itemQuery = (db.select(saleItemsTable)
          ..where((tbl) => tbl.saleId.isIn(saleIds) & tbl.deletedAt.isNull()))
        .join([
      innerJoin(db.productsTable, db.productsTable.id.equalsExp(saleItemsTable.productId)),
      innerJoin(productBatchesTable, productBatchesTable.id.equalsExp(saleItemsTable.batchId)),
    ]);

    final itemRows = await itemQuery.get();
    final itemsBySaleId = <String, List<DetailedSaleItemReport>>{};

    for (final row in itemRows) {
      final item = row.readTable(saleItemsTable);
      final product = row.readTable(db.productsTable);
      final batch = row.readTable(productBatchesTable);

      final saleItemReport = DetailedSaleItemReport(
        id: item.id,
        saleId: item.saleId,
        invoiceNumber: '', // populated in next pass
        saleDate: item.createdAt,
        productId: product.id,
        brandName: product.brandName,
        genericName: product.genericName,
        category: product.category,
        batchId: batch.id,
        batchNumber: batch.batchNumber,
        expiryDate: batch.expiryDate,
        quantity: item.quantity,
        unitCostPrice: item.unitCostPrice,
        unitSellingPrice: item.unitSellingPrice,
        lineTotal: item.lineTotal,
      );

      itemsBySaleId.putIfAbsent(item.saleId, () => []).add(saleItemReport);
    }

    final results = <DetailedSaleReport>[];
    for (final s in sales) {
      final rawItems = itemsBySaleId[s.id] ?? [];
      final populatedItems = rawItems
          .map(
            (i) => DetailedSaleItemReport(
              id: i.id,
              saleId: i.saleId,
              invoiceNumber: s.invoiceNumber,
              saleDate: s.createdAt,
              productId: i.productId,
              brandName: i.brandName,
              genericName: i.genericName,
              category: i.category,
              batchId: i.batchId,
              batchNumber: i.batchNumber,
              expiryDate: i.expiryDate,
              quantity: i.quantity,
              unitCostPrice: i.unitCostPrice,
              unitSellingPrice: i.unitSellingPrice,
              lineTotal: i.lineTotal,
            ),
          )
          .toList();

      final totalUnits = populatedItems.fold<int>(0, (sum, i) => sum + i.quantity);
      results.add(
        DetailedSaleReport(
          sale: s,
          cashierName: userMap[s.cashierUserId] ?? 'Staff Cashier',
          totalUnits: totalUnits,
          items: populatedItems,
        ),
      );
    }

    return results;
  }
}

/// Aggregated financial metrics container.
class SalesKpiSummary {
  final int totalInvoices;
  final int totalUnitsSold;
  final double grossRevenue;
  final double totalCostPrice;
  final double grossProfit;
  final double totalDiscounts;

  SalesKpiSummary({
    required this.totalInvoices,
    this.totalUnitsSold = 0,
    required this.grossRevenue,
    required this.totalCostPrice,
    required this.grossProfit,
    required this.totalDiscounts,
  });

  double get profitMarginPercentage =>
      grossRevenue > 0 ? (grossProfit / grossRevenue) * 100 : 0.0;
}
