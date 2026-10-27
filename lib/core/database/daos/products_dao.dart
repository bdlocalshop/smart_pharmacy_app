import 'package:drift/drift.dart';
import '../app_database.dart';
import '../converters.dart';
import '../tables/tables.dart';
import '../../errors/exceptions.dart';

part 'products_dao.g.dart';

/// FEFO inventory queries, batch replenishment, and radar alerts DAO.
@DriftAccessor(tables: [ProductsTable, ProductBatchesTable])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  ProductsDao(super.db);

  static const _dateConverter = DateOnlyConverter();

  // --- Medicine Master Operations ---

  /// Stream of all active medicines for a pharmacy with optional search query.
  Stream<List<Product>> watchProducts(String pharmacyUid, {String? searchQuery}) {
    final query = select(productsTable)
      ..where((tbl) => tbl.pharmacyUid.equals(pharmacyUid) & tbl.deletedAt.isNull());

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where((tbl) =>
          tbl.brandName.lower().like(term) |
          tbl.genericName.lower().like(term) |
          tbl.category.lower().like(term) |
          tbl.shelfLocation.lower().like(term));
    }

    query.orderBy([
      (tbl) => OrderingTerm(expression: tbl.brandName, mode: OrderingMode.asc),
    ]);

    return query.watch();
  }

  /// Fetches a single medicine by its UUID.
  Future<Product?> getProductById(String pharmacyUid, String productId) {
    return (select(productsTable)
          ..where((tbl) =>
              tbl.pharmacyUid.equals(pharmacyUid) &
              tbl.id.equals(productId) &
              tbl.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Inserts a new medicine into the catalog.
  Future<void> insertProduct(ProductsTableCompanion product) {
    return into(productsTable).insert(product);
  }

  /// Updates medicine master details.
  Future<bool> updateProduct(ProductsTableCompanion product) {
    return update(productsTable).replace(product);
  }

  /// Soft deletes a medicine by populating deletedAt and CDC status.
  Future<void> softDeleteProduct(String pharmacyUid, String productId) async {
    final now = DateTime.now();
    await (update(productsTable)
          ..where((tbl) => tbl.pharmacyUid.equals(pharmacyUid) & tbl.id.equals(productId)))
        .write(
      ProductsTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_delete'),
      ),
    );
  }

  // --- Batch Operations (Multi-Supplier & Multi-Price) ---

  /// Stream of all batches for a given medicine (both active and expired).
  Stream<List<ProductBatch>> watchBatchesForProduct(String pharmacyUid, String productId) {
    return (select(productBatchesTable)
          ..where((tbl) =>
              tbl.pharmacyUid.equals(pharmacyUid) &
              tbl.productId.equals(productId) &
              tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.expiryDate, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  /// Inserts a new batch procurement.
  Future<void> insertBatch(ProductBatchesTableCompanion batch) {
    return into(productBatchesTable).insert(batch);
  }

  /// Updates batch details (e.g. stock adjustment or price update).
  Future<bool> updateBatch(ProductBatchesTableCompanion batch) {
    return update(productBatchesTable).replace(batch);
  }

  /// Soft deletes a batch.
  Future<void> softDeleteBatch(String pharmacyUid, String batchId) async {
    final now = DateTime.now();
    await (update(productBatchesTable)
          ..where((tbl) => tbl.pharmacyUid.equals(pharmacyUid) & tbl.id.equals(batchId)))
        .write(
      ProductBatchesTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_delete'),
      ),
    );
  }

  // --- FEFO & POS Queries ---

  /// FEFO Query: Returns active, non-expired batches for a medicine sorted
  /// by earliest expiry date first (First Expired, First Out).
  Selectable<ProductBatch> getFefoBatches(String pharmacyUid, String productId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _dateConverter.toSql(today);

    return select(productBatchesTable)
      ..where((tbl) =>
          tbl.pharmacyUid.equals(pharmacyUid) &
          tbl.productId.equals(productId) &
          tbl.currentStock.isBiggerThanValue(0) &
          tbl.deletedAt.isNull() &
          tbl.expiryDate.isBiggerOrEqualValue(todayStr))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.expiryDate, mode: OrderingMode.asc),
      ]);
  }

  /// Reactive stream of FEFO batches for real-time POS stock allocation.
  Stream<List<ProductBatch>> watchFefoBatches(String pharmacyUid, String productId) {
    return getFefoBatches(pharmacyUid, productId).watch();
  }

  /// FEFO batch deduction inside an isolated database transaction.
  /// Throws [InsufficientStockException] if requested quantity exceeds available non-expired stock.
  Future<List<DeductedBatchAllocation>> deductStockFefo({
    required String pharmacyUid,
    required String productId,
    required int requestedQuantity,
  }) async {
    return db.transaction(() async {
      final batches = await getFefoBatches(pharmacyUid, productId).get();
      final totalAvailable = batches.fold<int>(0, (sum, b) => sum + b.currentStock);

      if (totalAvailable < requestedQuantity) {
        throw InsufficientStockException(
          productId: productId,
          requestedQuantity: requestedQuantity,
          availableStock: totalAvailable,
        );
      }

      int remainingToDeduct = requestedQuantity;
      final allocations = <DeductedBatchAllocation>[];

      for (final batch in batches) {
        if (remainingToDeduct <= 0) break;

        final deduction = remainingToDeduct <= batch.currentStock
            ? remainingToDeduct
            : batch.currentStock;

        final newStock = batch.currentStock - deduction;
        await (update(productBatchesTable)..where((tbl) => tbl.id.equals(batch.id))).write(
          ProductBatchesTableCompanion(
            currentStock: Value(newStock),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending_update'),
          ),
        );

        allocations.add(
          DeductedBatchAllocation(
            batch: batch,
            deductedQuantity: deduction,
            unitCostPrice: batch.purchasePrice,
            unitSellingPrice: batch.sellingPrice,
          ),
        );

        remainingToDeduct -= deduction;
      }

      return allocations;
    });
  }

  // --- Expiry Radar & Stock Alert Queries ---

  /// Batches expiring within the given [minDays] to [maxDays] range.
  Selectable<ProductBatch> getExpiringBatches(
    String pharmacyUid, {
    int minDays = 0,
    required int maxDays,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.add(Duration(days: minDays));
    final endDate = today.add(Duration(days: maxDays));

    final startStr = _dateConverter.toSql(startDate);
    final endStr = _dateConverter.toSql(endDate);

    return select(productBatchesTable)
      ..where((tbl) =>
          tbl.pharmacyUid.equals(pharmacyUid) &
          tbl.currentStock.isBiggerThanValue(0) &
          tbl.deletedAt.isNull() &
          tbl.expiryDate.isBiggerOrEqualValue(startStr) &
          tbl.expiryDate.isSmallerOrEqualValue(endStr))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.expiryDate, mode: OrderingMode.asc),
      ]);
  }

  /// Expired batches that must be blocked from sale.
  Selectable<ProductBatch> getExpiredBatches(String pharmacyUid) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _dateConverter.toSql(today);

    return select(productBatchesTable)
      ..where((tbl) =>
          tbl.pharmacyUid.equals(pharmacyUid) &
          tbl.currentStock.isBiggerThanValue(0) &
          tbl.deletedAt.isNull() &
          tbl.expiryDate.isSmallerThanValue(todayStr))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.expiryDate, mode: OrderingMode.asc),
      ]);
  }

  /// Joined query fetching expired batches with product metadata (shelf location, brand, generic).
  Stream<List<BatchWithProductInfo>> watchExpiredBatchesWithProduct(String pharmacyUid) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _dateConverter.toSql(today);

    final query = select(productBatchesTable).join([
      innerJoin(
        productsTable,
        productsTable.id.equalsExp(productBatchesTable.productId),
      ),
    ])
      ..where(
        productBatchesTable.pharmacyUid.equals(pharmacyUid) &
            productBatchesTable.currentStock.isBiggerThanValue(0) &
            productBatchesTable.deletedAt.isNull() &
            productBatchesTable.expiryDate.isSmallerThanValue(todayStr) &
            productsTable.deletedAt.isNull(),
      )
      ..orderBy([
        OrderingTerm(expression: productBatchesTable.expiryDate, mode: OrderingMode.asc),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return BatchWithProductInfo(
          batch: row.readTable(productBatchesTable),
          product: row.readTable(productsTable),
        );
      }).toList();
    });
  }

  /// Joined query fetching expiring batches within a range with product metadata.
  Stream<List<BatchWithProductInfo>> watchExpiringBatchesWithProduct(
    String pharmacyUid, {
    int minDays = 0,
    required int maxDays,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.add(Duration(days: minDays));
    final endDate = today.add(Duration(days: maxDays));

    final startStr = _dateConverter.toSql(startDate);
    final endStr = _dateConverter.toSql(endDate);

    final query = select(productBatchesTable).join([
      innerJoin(
        productsTable,
        productsTable.id.equalsExp(productBatchesTable.productId),
      ),
    ])
      ..where(
        productBatchesTable.pharmacyUid.equals(pharmacyUid) &
            productBatchesTable.currentStock.isBiggerThanValue(0) &
            productBatchesTable.deletedAt.isNull() &
            productBatchesTable.expiryDate.isBiggerOrEqualValue(startStr) &
            productBatchesTable.expiryDate.isSmallerOrEqualValue(endStr) &
            productsTable.deletedAt.isNull(),
      )
      ..orderBy([
        OrderingTerm(expression: productBatchesTable.expiryDate, mode: OrderingMode.asc),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return BatchWithProductInfo(
          batch: row.readTable(productBatchesTable),
          product: row.readTable(productsTable),
        );
      }).toList();
    });
  }

  /// Joined query computing aggregate active inventory stock per medicine.
  Stream<List<ProductWithAggregateStock>> watchProductsWithAggregateStock(
    String pharmacyUid, {
    String? searchQuery,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Watch all products
    return watchProducts(pharmacyUid, searchQuery: searchQuery).asyncMap((products) async {
      final results = <ProductWithAggregateStock>[];

      for (final p in products) {
        final batches = await (select(productBatchesTable)
              ..where((tbl) =>
                  tbl.pharmacyUid.equals(pharmacyUid) &
                  tbl.productId.equals(p.id) &
                  tbl.deletedAt.isNull()))
            .get();

        int activeNonExpiredStock = 0;
        int expiredStock = 0;
        DateTime? earliestActiveExpiry;

        for (final b in batches) {
          final isExpired = b.expiryDate.isBefore(today);
          if (isExpired) {
            expiredStock += b.currentStock;
          } else {
            activeNonExpiredStock += b.currentStock;
            if (earliestActiveExpiry == null || b.expiryDate.isBefore(earliestActiveExpiry)) {
              earliestActiveExpiry = b.expiryDate;
            }
          }
        }

        results.add(
          ProductWithAggregateStock(
            product: p,
            activeStock: activeNonExpiredStock,
            expiredStock: expiredStock,
            batchCount: batches.length,
            earliestExpiry: earliestActiveExpiry,
            isLowStock: activeNonExpiredStock <= p.minStockAlert,
          ),
        );
      }

      return results;
    });
  }
}

/// Helper model representing batch stock allocated and deducted via FEFO.
class DeductedBatchAllocation {
  final ProductBatch batch;
  final int deductedQuantity;
  final double unitCostPrice;
  final double unitSellingPrice;

  DeductedBatchAllocation({
    required this.batch,
    required this.deductedQuantity,
    required this.unitCostPrice,
    required this.unitSellingPrice,
  });
}

/// Helper model joining a batch with its parent medicine catalog details.
class BatchWithProductInfo {
  final ProductBatch batch;
  final Product product;

  BatchWithProductInfo({
    required this.batch,
    required this.product,
  });

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return batch.expiryDate.difference(today).inDays;
  }
}

/// Helper model bundling a medicine with its aggregated batch metrics.
class ProductWithAggregateStock {
  final Product product;
  final int activeStock;
  final int expiredStock;
  final int batchCount;
  final DateTime? earliestExpiry;
  final bool isLowStock;

  ProductWithAggregateStock({
    required this.product,
    required this.activeStock,
    required this.expiredStock,
    required this.batchCount,
    required this.earliestExpiry,
    required this.isLowStock,
  });
}
