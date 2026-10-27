import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/constants/app_constants.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/sales_dao.dart';
import 'package:smart_pharmacy_app/core/database/seed_data.dart';
import 'package:smart_pharmacy_app/features/reports/domain/report_models.dart';

void main() {
  late AppDatabase db;
  late DatabaseSeeder seeder;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    seeder = DatabaseSeeder(db);
    await seeder.seedIfEmpty();
  });

  tearDown(() async {
    await db.close();
  });

  group('Multi-Batch Deductions, FEFO Order, & Real Profit Calculation Tests', () {
    test(
        'executeAtomicCheckout deducts across multiple batches in FEFO order with accurate real-profit calculation',
        () async {
      final settings = await db.select(db.pharmacySettingsTable).getSingle();
      final users = await db.select(db.usersTable).get();
      final cashier = users.firstWhere((u) => u.role == AppConstants.roleOwner);

      // Find Panadol: Has 2 batches in seed data:
      // 1. PAN-2026-01: Cost $1.10, Sell $2.50, Stock 40, Exp: in 22 days
      // 2. PAN-2027-02: Cost $1.15, Sell $2.50, Stock 200, Exp: in 400 days
      final panadol = await (db.select(db.productsTable)
            ..where((tbl) => tbl.brandName.equals('Panadol 500mg')))
          .getSingle();

      final initialBatches = await db.productsDao.getFefoBatches(panadol.pharmacyUid, panadol.id).get();
      expect(initialBatches.length, equals(2));
      expect(initialBatches[0].batchNumber, equals('PAN-2026-01'));
      expect(initialBatches[0].currentStock, equals(40));
      expect(initialBatches[1].batchNumber, equals('PAN-2027-02'));
      expect(initialBatches[1].currentStock, equals(200));

      // Checkout 50 units (spanning both batches: 40 from Batch 1, 10 from Batch 2)
      // Line discount: $10.00, Invoice discount: $5.00. Total discount = $15.00.
      final checkoutResult = await db.salesDao.executeAtomicCheckout(
        pharmacyUid: settings.pharmacyUid,
        cashierUserId: cashier.id,
        items: [
          CheckoutItemRequest(
            productId: panadol.id,
            quantity: 50,
            unitSellingPrice: 2.50,
            lineDiscountAmount: 10.00,
          ),
        ],
        customerName: 'Robert Vance',
        customerPhone: '+1-555-0987',
        invoiceDiscount: 5.00,
        amountTendered: 120.00,
        paymentMethod: 'Cash',
      );

      final sale = checkoutResult.sale;
      final items = checkoutResult.items;

      // 1. Verify exact 2 line items created for the 2 batches
      expect(items.length, equals(2));
      final itemBatch1 = items.firstWhere((i) => i.batchId == initialBatches[0].id);
      final itemBatch2 = items.firstWhere((i) => i.batchId == initialBatches[1].id);

      expect(itemBatch1.quantity, equals(40));
      expect(itemBatch1.unitCostPrice, equals(1.10));
      expect(itemBatch1.unitSellingPrice, equals(2.50));

      expect(itemBatch2.quantity, equals(10));
      expect(itemBatch2.unitCostPrice, equals(1.15));
      expect(itemBatch2.unitSellingPrice, equals(2.50));

      // 2. Verify batch inventory levels updated in DB
      final updatedBatch1 = await (db.select(db.productBatchesTable)
            ..where((tbl) => tbl.id.equals(initialBatches[0].id)))
          .getSingle();
      final updatedBatch2 = await (db.select(db.productBatchesTable)
            ..where((tbl) => tbl.id.equals(initialBatches[1].id)))
          .getSingle();

      expect(updatedBatch1.currentStock, equals(0)); // Completely exhausted
      expect(updatedBatch2.currentStock, equals(190)); // 200 - 10 = 190
      expect(updatedBatch1.syncStatus, equals('pending_update'));
      expect(updatedBatch2.syncStatus, equals('pending_update'));

      // 3. Verify Financial Metrics & Real Profit Formula:
      // Subtotal = 50 * $2.50 = $125.00
      // Total Discount = $10.00 (line) + $5.00 (invoice) = $15.00
      // Total Payable = $125.00 - $15.00 = $110.00
      // Cost = (40 * 1.10) + (10 * 1.15) = 44.00 + 11.50 = $55.50
      // Real Profit = Total Payable - Cost = $110.00 - $55.50 = $54.50
      // Also via Formula: [(2.50 - 1.10) * 40] + [(2.50 - 1.15) * 10] - 15.00
      //                 = (1.40 * 40) + (1.35 * 10) - 15.00
      //                 = 56.00 + 13.50 - 15.00 = 54.50!
      expect(sale.subtotal, equals(125.00));
      expect(sale.discountAmount, equals(15.00));
      expect(sale.totalPayable, equals(110.00));
      expect(sale.totalCostPrice, equals(55.50));
      expect(sale.grossProfit, equals(54.50));
      expect(sale.amountTendered, equals(120.00));
      expect(sale.changeReturned, equals(10.00));

      // 4. Verify Detailed Sales Reporting Query returns accurate multi-batch records
      final now = DateTime.now();
      final detailedReports = await db.salesDao.getDetailedSalesReport(
        settings.pharmacyUid,
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(days: 1)),
      );

      final multiBatchReport = detailedReports.firstWhere((r) => r.sale.id == sale.id);
      expect(multiBatchReport.totalUnits, equals(50));
      expect(multiBatchReport.items.length, equals(2));
      expect(multiBatchReport.cashierName, equals(cashier.fullName));

      // Verify line cost on each batch slice
      final reportItem1 = multiBatchReport.items.firstWhere((i) => i.batchId == initialBatches[0].id);
      final reportItem2 = multiBatchReport.items.firstWhere((i) => i.batchId == initialBatches[1].id);
      expect(reportItem1.lineCost, equals(44.00));
      expect(reportItem2.lineCost, equals(11.50));
    });

    test('getReportKpis aggregates units sold, revenue, batch costs, and payment distributions',
        () async {
      final settings = await db.select(db.pharmacySettingsTable).getSingle();
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 1));
      final end = now.add(const Duration(days: 1));

      final kpis = await db.salesDao.getReportKpis(settings.pharmacyUid, start, end);
      // Seed data contains 1 initial sale (2 units of Panadol at $11.50 total payable, $6.40 cost, $5.10 profit)
      expect(kpis.totalInvoices, greaterThanOrEqualTo(1));
      expect(kpis.totalUnitsSold, greaterThanOrEqualTo(2));
      expect(kpis.grossRevenue, greaterThanOrEqualTo(11.50));
      expect(kpis.totalCostPrice, greaterThanOrEqualTo(6.40));
      expect(kpis.grossProfit, greaterThanOrEqualTo(5.10));
      expect(kpis.profitMarginPercentage, greaterThan(0));
      expect(kpis.paymentBreakdown.containsKey('Cash'), isTrue);
    });

    test('DatePeriodFilter generates correct DateTime ranges for presets', () {
      final refDate = DateTime(2026, 10, 24, 14, 30, 0);

      // Today
      final todayRange = DatePeriodFilter.today.toDateRange(refDate);
      expect(todayRange.start, equals(DateTime(2026, 10, 24, 0, 0, 0)));
      expect(todayRange.end, equals(DateTime(2026, 10, 24, 23, 59, 59, 999)));

      // Yesterday
      final yestRange = DatePeriodFilter.yesterday.toDateRange(refDate);
      expect(yestRange.start, equals(DateTime(2026, 10, 23, 0, 0, 0)));
      expect(yestRange.end, equals(DateTime(2026, 10, 23, 23, 59, 59, 999)));

      // This Month
      final monthRange = DatePeriodFilter.thisMonth.toDateRange(refDate);
      expect(monthRange.start, equals(DateTime(2026, 10, 1, 0, 0, 0)));
      expect(monthRange.end, equals(DateTime(2026, 10, 31, 23, 59, 59, 999)));

      // Last 7 Days
      final last7Range = DatePeriodFilter.last7Days.toDateRange(refDate);
      expect(last7Range.start, equals(DateTime(2026, 10, 18, 0, 0, 0)));
      expect(last7Range.end, equals(DateTime(2026, 10, 24, 23, 59, 59, 999)));
    });
  });
}
