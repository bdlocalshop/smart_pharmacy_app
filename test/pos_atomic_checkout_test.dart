import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/sales_dao.dart';
import 'package:smart_pharmacy_app/core/errors/exceptions.dart';
import 'package:smart_pharmacy_app/features/pos/data/pos_repository.dart';

void main() {
  late AppDatabase db;
  late PosRepository posRepo;
  const pharmacyUid = 'ph-pos-test-001';
  const cashierId = 'user-cashier-001';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    posRepo = PosRepository(db);

    // Seed Pharmacy Setting
    await db.into(db.pharmacySettingsTable).insert(
          PharmacySettingsTableCompanion.insert(
            pharmacyUid: pharmacyUid,
            pharmacyName: 'Central Care Pharmacy',
            contactPhone: '01700000000',
            address: const Value('Main Street, Ward 3'),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    // Seed Cashier User
    await db.into(db.usersTable).insert(
          UsersTableCompanion.insert(
            id: cashierId,
            pharmacyUid: pharmacyUid,
            fullName: 'Jane Cashier',
            username: 'jane_pos',
            passwordHash: 'hash_test_123',
            role: 'SALESMAN',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Atomic POS Checkout & FEFO Stock Deduction Tests', () {
    test('Deducts exact batch stock in FEFO order and marks records as pending_insert / pending_update', () async {
      final now = DateTime.now();
      const prodId = 'prod-napa-500';

      // Insert Medicine
      await db.into(db.productsTable).insert(
            ProductsTableCompanion.insert(
              id: prodId,
              pharmacyUid: pharmacyUid,
              brandName: 'Napa 500mg',
              genericName: 'Paracetamol',
              category: 'Analgesic',
              manufacturer: 'Beximco',
              shelfLocation: 'Rack A-1',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Insert Batch 1: Expiring in 30 days (100 units, Cost: $1.00, MRP: $1.50)
      final expiry1 = now.add(const Duration(days: 30));
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion.insert(
              id: 'batch-001-fefo-1',
              pharmacyUid: pharmacyUid,
              productId: prodId,
              batchNumber: 'B-001-EARLY',
              purchasePrice: 1.00,
              sellingPrice: 1.50,
              initialQuantity: 100,
              currentStock: 100,
              expiryDate: expiry1,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Insert Batch 2: Expiring in 90 days (150 units, Cost: $1.10, MRP: $1.50)
      final expiry2 = now.add(const Duration(days: 90));
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion.insert(
              id: 'batch-002-fefo-2',
              pharmacyUid: pharmacyUid,
              productId: prodId,
              batchNumber: 'B-002-LATER',
              purchasePrice: 1.10,
              sellingPrice: 1.50,
              initialQuantity: 150,
              currentStock: 150,
              expiryDate: expiry2,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Request 120 units: Must completely deplete Batch 1 (100 units) and take 20 units from Batch 2
      final checkoutResult = await posRepo.checkout(
        pharmacyUid: pharmacyUid,
        cashierUserId: cashierId,
        items: [
          CheckoutItemRequest(
            productId: prodId,
            quantity: 120,
            unitSellingPrice: 1.50,
            lineDiscountAmount: 10.0, // $10 line discount
          ),
        ],
        customerName: 'Robert Smith',
        customerPhone: '01811122233',
        invoiceDiscount: 5.0, // $5 overall invoice discount
        amountTendered: 200.0,
        paymentMethod: 'Cash',
      );

      // 1. Verify Sale Invoice Record
      final sale = checkoutResult.sale;
      expect(sale.id, isNotEmpty);
      expect(sale.pharmacyUid, equals(pharmacyUid));
      expect(sale.invoiceNumber, startsWith('INV-'));
      expect(sale.cashierUserId, equals(cashierId));
      expect(sale.customerName, equals('Robert Smith'));
      expect(sale.syncStatus, equals('pending_insert'));

      // Subtotal = 120 * 1.50 = $180.00
      expect(sale.subtotal, equals(180.0));
      // Total Discount = $10 (line) + $5 (invoice) = $15.00
      expect(sale.discountAmount, equals(15.0));
      // Net Payable = $180.00 - $15.00 = $165.00
      expect(sale.totalPayable, equals(165.0));
      // Change Returned = $200.00 - $165.00 = $35.00
      expect(sale.changeReturned, equals(35.0));

      // Total Cost Price: (100 * 1.00) + (20 * 1.10) = $100.00 + $22.00 = $122.00
      expect(sale.totalCostPrice, equals(122.0));
      // Gross Profit: $165.00 - $122.00 = $43.00
      expect(sale.grossProfit, equals(43.0));

      // 2. Verify Sale Item Line Entries (2 slices across the 2 FEFO batches)
      final saleItems = checkoutResult.items;
      expect(saleItems.length, equals(2));

      final slice1 = saleItems.firstWhere((i) => i.batchId == 'batch-001-fefo-1');
      expect(slice1.quantity, equals(100));
      expect(slice1.unitCostPrice, equals(1.00));
      expect(slice1.unitSellingPrice, equals(1.50));
      expect(slice1.syncStatus, equals('pending_insert'));

      final slice2 = saleItems.firstWhere((i) => i.batchId == 'batch-002-fefo-2');
      expect(slice2.quantity, equals(20));
      expect(slice2.unitCostPrice, equals(1.10));
      expect(slice2.unitSellingPrice, equals(1.50));
      expect(slice2.syncStatus, equals('pending_insert'));

      // 3. Verify Batch Stock Levels in Database
      final batchesInDb = await (db.select(db.productBatchesTable)
            ..where((tbl) => tbl.productId.equals(prodId))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.expiryDate)]))
          .get();

      // Batch 1 should be completely exhausted (0 units left, syncStatus: pending_update)
      expect(batchesInDb[0].currentStock, equals(0));
      expect(batchesInDb[0].syncStatus, equals('pending_update'));

      // Batch 2 should have 130 units left (150 - 20 = 130, syncStatus: pending_update)
      expect(batchesInDb[1].currentStock, equals(130));
      expect(batchesInDb[1].syncStatus, equals('pending_update'));
    });

    test('Strictly blocks sale if batch is expired and rolls back transaction atomically', () async {
      final now = DateTime.now();
      const prodId = 'prod-expired-med';

      await db.into(db.productsTable).insert(
            ProductsTableCompanion.insert(
              id: prodId,
              pharmacyUid: pharmacyUid,
              brandName: 'Expired Syrup',
              genericName: 'Cough Med',
              category: 'Syrup',
              manufacturer: 'Square',
              shelfLocation: 'Rack B-4',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Batch expired 15 days ago
      final expiredDate = now.subtract(const Duration(days: 15));
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion.insert(
              id: 'batch-expired-001',
              pharmacyUid: pharmacyUid,
              productId: prodId,
              batchNumber: 'EXP-BATCH-99',
              purchasePrice: 2.0,
              sellingPrice: 3.5,
              initialQuantity: 50,
              currentStock: 50,
              expiryDate: expiredDate,
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Attempting to sell from expired batch MUST throw ExpiredBatchSaleBlockedException
      expect(
        () => posRepo.checkout(
          pharmacyUid: pharmacyUid,
          cashierUserId: cashierId,
          items: [
            CheckoutItemRequest(
              productId: prodId,
              quantity: 5,
              unitSellingPrice: 3.5,
            ),
          ],
          amountTendered: 20.0,
        ),
        throwsA(isA<ExpiredBatchSaleBlockedException>()),
      );

      // Verify Transaction Rollback: Stock must remain untouched at 50
      final batchAfterFailedSale = await (db.select(db.productBatchesTable)
            ..where((tbl) => tbl.id.equals('batch-expired-001')))
          .getSingle();
      expect(batchAfterFailedSale.currentStock, equals(50));

      // Verify zero Sale records created
      final salesCount = await db.select(db.salesTable).get();
      expect(salesCount.isEmpty, isTrue);
    });

    test('Throws InsufficientStockException and rolls back when requested quantity exceeds available stock', () async {
      final now = DateTime.now();
      const prodId = 'prod-low-stock';

      await db.into(db.productsTable).insert(
            ProductsTableCompanion.insert(
              id: prodId,
              pharmacyUid: pharmacyUid,
              brandName: 'Limited Inhaler',
              genericName: 'Salbutamol',
              category: 'Respiratory',
              manufacturer: 'GSK',
              shelfLocation: 'Rack R-2',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Batch has only 10 units
      await db.into(db.productBatchesTable).insert(
            ProductBatchesTableCompanion.insert(
              id: 'batch-inhaler-001',
              pharmacyUid: pharmacyUid,
              productId: prodId,
              batchNumber: 'INH-10',
              purchasePrice: 5.0,
              sellingPrice: 8.0,
              initialQuantity: 10,
              currentStock: 10,
              expiryDate: now.add(const Duration(days: 180)),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Requesting 15 units when only 10 exist
      expect(
        () => posRepo.checkout(
          pharmacyUid: pharmacyUid,
          cashierUserId: cashierId,
          items: [
            CheckoutItemRequest(
              productId: prodId,
              quantity: 15,
              unitSellingPrice: 8.0,
            ),
          ],
          amountTendered: 120.0,
        ),
        throwsA(isA<InsufficientStockException>()),
      );

      // Batch stock remains 10
      final batch = await (db.select(db.productBatchesTable)
            ..where((tbl) => tbl.id.equals('batch-inhaler-001')))
          .getSingle();
      expect(batch.currentStock, equals(10));

      final salesCount = await db.select(db.salesTable).get();
      expect(salesCount.isEmpty, isTrue);
    });
  });
}

