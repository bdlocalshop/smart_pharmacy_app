import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/features/inventory/data/inventory_repository.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;
  const pharmacyUid = 'ph-test-12345';

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = InventoryRepository(db);

    await db.into(db.pharmacySettingsTable).insert(
          PharmacySettingsTableCompanion.insert(
            pharmacyUid: pharmacyUid,
            pharmacyName: 'Test Pharmacy',
            contactPhone: '1234567890',
            address: const Value('123 Test Street'),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Medicine Master Catalog Operations', () {
    test('Adds and retrieves a medicine with complete details', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Napa Extra 500mg/65mg',
        genericName: 'Paracetamol + Caffeine',
        category: 'Analgesic / Antipyretic',
        manufacturer: 'Beximco Pharmaceuticals Ltd',
        shelfLocation: 'Rack A-12, Bin 3',
        unitType: 'Tablet',
        minStockAlert: 100,
      );

      final catalog = await repo.watchProducts(pharmacyUid).first;
      expect(catalog.length, equals(1));
      final item = catalog.first;
      expect(item.product.pharmacyUid, equals(pharmacyUid));
      expect(item.product.brandName, equals('Napa Extra 500mg/65mg'));
      expect(item.product.genericName, equals('Paracetamol + Caffeine'));
      expect(item.product.shelfLocation, equals('Rack A-12, Bin 3'));
      expect(item.product.minStockAlert, equals(100));
      expect(item.product.unitType, equals('Tablet'));
    });

    test('Updates medicine details successfully', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Amoxil 500mg',
        genericName: 'Amoxicillin Trihydrate',
        category: 'Antibiotic',
        manufacturer: 'GSK',
        shelfLocation: 'Rack B-1',
        unitType: 'Capsule',
        minStockAlert: 50,
      );

      final initialList = await repo.watchProducts(pharmacyUid).first;
      final productId = initialList.first.product.id;

      await repo.updateProduct(
        pharmacyUid: pharmacyUid,
        productId: productId,
        brandName: 'Amoxil Forte 500mg',
        genericName: 'Amoxicillin Trihydrate',
        category: 'Antibiotic',
        manufacturer: 'GSK',
        shelfLocation: 'Rack B-2, Shelf 4',
        unitType: 'Capsule',
        minStockAlert: 75,
      );

      final updatedList = await repo.watchProducts(pharmacyUid).first;
      final updated = updatedList.first.product;
      expect(updated.brandName, equals('Amoxil Forte 500mg'));
      expect(updated.shelfLocation, equals('Rack B-2, Shelf 4'));
      expect(updated.minStockAlert, equals(75));
    });

    test('Soft-deletes a medicine and excludes it from active listing', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Discontinued Med 10mg',
        genericName: 'Old Molecule',
        category: 'Cardiovascular',
        manufacturer: 'Pharma Old',
        shelfLocation: 'Rack Z-9',
        unitType: 'Tablet',
        minStockAlert: 10,
      );

      final beforeDelete = await repo.watchProducts(pharmacyUid).first;
      expect(beforeDelete.length, equals(1));
      final productId = beforeDelete.first.product.id;

      await repo.deleteProduct(pharmacyUid, productId);

      final afterDelete = await repo.watchProducts(pharmacyUid).first;
      expect(afterDelete.isEmpty, isTrue);
    });

    test('Filters medicine catalog by search query (brand, generic, shelf location)', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Panadol 500mg',
        genericName: 'Paracetamol',
        category: 'Analgesic',
        manufacturer: 'GSK',
        shelfLocation: 'Shelf 1-A',
        unitType: 'Tablet',
      );

      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Azithrox 500mg',
        genericName: 'Azithromycin',
        category: 'Antibiotic',
        manufacturer: 'Square',
        shelfLocation: 'Shelf 2-B',
        unitType: 'Tablet',
      );

      // Search by brand
      final brandMatch = await repo.watchProducts(pharmacyUid, searchQuery: 'Panadol').first;
      expect(brandMatch.length, equals(1));
      expect(brandMatch.first.product.brandName, equals('Panadol 500mg'));

      // Search by generic
      final genericMatch = await repo.watchProducts(pharmacyUid, searchQuery: 'Azithro').first;
      expect(genericMatch.length, equals(1));
      expect(genericMatch.first.product.brandName, equals('Azithrox 500mg'));

      // Search by shelf location
      final shelfMatch = await repo.watchProducts(pharmacyUid, searchQuery: 'Shelf 2-B').first;
      expect(shelfMatch.length, equals(1));
      expect(shelfMatch.first.product.shelfLocation, equals('Shelf 2-B'));
    });
  });

  group('Batch Management & Multi-Supplier Purchasing', () {
    test('Allows purchasing the same medicine from different suppliers with varying costs and expiry dates', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Panadol Advance 500mg',
        genericName: 'Paracetamol',
        category: 'Analgesic',
        manufacturer: 'GSK Consumer Health',
        shelfLocation: 'Rack A-2',
        unitType: 'Tablet',
        minStockAlert: 50,
      );

      final catalog = await repo.watchProducts(pharmacyUid).first;
      final productId = catalog.first.product.id;

      final now = DateTime.now();
      final expiry1 = DateTime(now.year, now.month + 3, now.day);
      final expiry2 = DateTime(now.year, now.month + 8, now.day);

      // Supplier 1: City Pharma Wholesale (Purchased at $2.20, Selling MRP $3.50)
      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: productId,
        batchNumber: 'CP-BATCH-001',
        supplierName: 'City Pharma Wholesale',
        purchasePrice: 2.20,
        sellingPrice: 3.50,
        initialQuantity: 200,
        expiryDate: expiry1,
      );

      // Supplier 2: National Med Distributors (Purchased at $2.05, Selling MRP $3.50)
      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: productId,
        batchNumber: 'NMD-BATCH-882',
        supplierName: 'National Med Distributors',
        purchasePrice: 2.05,
        sellingPrice: 3.50,
        initialQuantity: 350,
        expiryDate: expiry2,
      );

      // Retrieve batches for this product - must follow FEFO (batch1 earlier than batch2)
      final batches = await repo.watchBatchesForProduct(pharmacyUid, productId).first;
      expect(batches.length, equals(2));
      expect(batches[0].batchNumber, equals('CP-BATCH-001'));
      expect(batches[0].supplierName, equals('City Pharma Wholesale'));
      expect(batches[0].purchasePrice, equals(2.20));

      expect(batches[1].batchNumber, equals('NMD-BATCH-882'));
      expect(batches[1].supplierName, equals('National Med Distributors'));
      expect(batches[1].purchasePrice, equals(2.05));

      // Verify aggregate active stock calculation
      final updatedCatalog = await repo.watchProducts(pharmacyUid).first;
      final catalogItem = updatedCatalog.firstWhere((i) => i.product.id == productId);
      expect(catalogItem.activeStock, equals(550)); // 200 + 350
    });
  });

  group('Expiry Radar & Stock Alerts Verification', () {
    test('Correctly categorizes expired stock (Red indicator) and blocks from active sales stock', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Expired Syrup 100ml',
        genericName: 'Cough Formula',
        category: 'Respiratory',
        manufacturer: 'Square Pharmaceuticals',
        shelfLocation: 'Rack R-1',
        unitType: 'Bottle',
        minStockAlert: 20,
      );

      final catalog = await repo.watchProducts(pharmacyUid).first;
      final productId = catalog.first.product.id;

      final now = DateTime.now();
      final expiredDate = DateTime(now.year, now.month - 2, 1); // Expired 2 months ago
      final validDate = DateTime(now.year + 1, now.month, now.day); // Valid for 1 year

      // Add expired batch
      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: productId,
        batchNumber: 'EXP-999',
        supplierName: 'Old Supplier',
        purchasePrice: 1.50,
        sellingPrice: 2.50,
        initialQuantity: 50,
        expiryDate: expiredDate,
      );

      // Add valid batch
      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: productId,
        batchNumber: 'VAL-101',
        supplierName: 'New Supplier',
        purchasePrice: 1.60,
        sellingPrice: 2.50,
        initialQuantity: 80,
        expiryDate: validDate,
      );

      // Expired batches stream should identify the expired batch
      final expiredBatches = await repo.watchExpiredBatches(pharmacyUid).first;
      expect(expiredBatches.any((b) => b.batch.batchNumber == 'EXP-999'), isTrue);
      expect(expiredBatches.any((b) => b.batch.batchNumber == 'VAL-101'), isFalse);

      // Active stock should ONLY count the valid batch (80 units, excluding the 50 expired)
      final updatedCatalog = await repo.watchProducts(pharmacyUid).first;
      final catalogItem = updatedCatalog.firstWhere((i) => i.product.id == productId);
      expect(catalogItem.activeStock, equals(80));
    });

    test('Correctly slots expiring batches into <30d (Yellow), 31-60d (Orange), and 61-90d (Yellow/Caution)', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Multi-Expiry Antibiotic',
        genericName: 'Ciprofloxacin',
        category: 'Antibiotic',
        manufacturer: 'Square Pharmaceuticals',
        shelfLocation: 'Rack C-4',
        unitType: 'Tablet',
        minStockAlert: 10,
      );

      final catalog = await repo.watchProducts(pharmacyUid).first;
      final productId = catalog.first.product.id;

      final now = DateTime.now();
      final dateUrgent = now.add(const Duration(days: 15)); // < 30 days
      final dateWarning = now.add(const Duration(days: 45)); // 31 - 60 days
      final dateCaution = now.add(const Duration(days: 75)); // 61 - 90 days

      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: productId,
        batchNumber: 'URG-15',
        supplierName: 'Supplier A',
        purchasePrice: 5.0,
        sellingPrice: 8.0,
        initialQuantity: 40,
        expiryDate: dateUrgent,
      );

      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: productId,
        batchNumber: 'WARN-45',
        supplierName: 'Supplier B',
        purchasePrice: 5.0,
        sellingPrice: 8.0,
        initialQuantity: 60,
        expiryDate: dateWarning,
      );

      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: productId,
        batchNumber: 'CAUT-75',
        supplierName: 'Supplier C',
        purchasePrice: 5.0,
        sellingPrice: 8.0,
        initialQuantity: 80,
        expiryDate: dateCaution,
      );

      final urgent = await repo.watchExpiringBatches(pharmacyUid, minDays: 0, maxDays: 30).first;
      final warning = await repo.watchExpiringBatches(pharmacyUid, minDays: 31, maxDays: 60).first;
      final caution = await repo.watchExpiringBatches(pharmacyUid, minDays: 61, maxDays: 90).first;

      expect(urgent.any((b) => b.batch.batchNumber == 'URG-15'), isTrue);
      expect(urgent.any((b) => b.batch.batchNumber == 'WARN-45'), isFalse);

      expect(warning.any((b) => b.batch.batchNumber == 'WARN-45'), isTrue);
      expect(warning.any((b) => b.batch.batchNumber == 'CAUT-75'), isFalse);

      expect(caution.any((b) => b.batch.batchNumber == 'CAUT-75'), isTrue);
      expect(caution.any((b) => b.batch.batchNumber == 'URG-15'), isFalse);
    });

    test('Identifies low stock deficit when active inventory is below minStockAlert threshold', () async {
      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Insulin Glargine 100IU',
        genericName: 'Insulin Glargine',
        category: 'Antidiabetic',
        manufacturer: 'Sanofi',
        shelfLocation: 'Fridge Unit #1',
        unitType: 'Vial',
        minStockAlert: 30, // Minimum threshold is 30
      );

      final validFuture = DateTime.now().add(const Duration(days: 180));
      final catalog = await repo.watchProducts(pharmacyUid).first;
      final lowStockProd = catalog.first.product;

      // Stock only 12 vials (deficit of 18)
      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: lowStockProd.id,
        batchNumber: 'INS-012',
        supplierName: 'ColdChain Logistics',
        purchasePrice: 15.0,
        sellingPrice: 22.0,
        initialQuantity: 12,
        expiryDate: validFuture,
      );

      await repo.addProduct(
        pharmacyUid: pharmacyUid,
        brandName: 'Normal Stock Vitamin C',
        genericName: 'Ascorbic Acid',
        category: 'Supplement',
        manufacturer: 'Pharma Health',
        shelfLocation: 'Rack V-1',
        unitType: 'Tablet',
        minStockAlert: 20,
      );

      final catalog2 = await repo.watchProducts(pharmacyUid).first;
      final normalProd = catalog2.firstWhere((p) => p.product.brandName == 'Normal Stock Vitamin C').product;

      // Stock 100 tablets (well above 20)
      await repo.addBatch(
        pharmacyUid: pharmacyUid,
        productId: normalProd.id,
        batchNumber: 'VIT-100',
        supplierName: 'Wholesale Co',
        purchasePrice: 1.0,
        sellingPrice: 2.0,
        initialQuantity: 100,
        expiryDate: validFuture,
      );

      final fullCatalog = await repo.watchProducts(pharmacyUid).first;
      final lowStockItems = fullCatalog.where((p) => p.isLowStock).toList();

      expect(lowStockItems.length, equals(1));
      expect(lowStockItems.first.product.brandName, equals('Insulin Glargine 100IU'));
      expect(lowStockItems.first.activeStock, equals(12));
    });
  });
}
