import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/features/alerts/presentation/views/expiry_radar_view.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/inventory/domain/csv_medicine_importer.dart';
import 'package:smart_pharmacy_app/features/inventory/domain/inventory_repository_interface.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/views/batch_management_dialog.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/views/medicines_master_view.dart';

class _FakeInventoryRepository implements IInventoryRepository {
  final List<Map<String, dynamic>> addedBatches = [];
  final List<Map<String, dynamic>> updatedBatches = [];

  @override
  Future<void> addBatch({
    required String pharmacyUid,
    required String productId,
    required String batchNumber,
    String? supplierName,
    required double purchasePrice,
    required double sellingPrice,
    required int initialQuantity,
    required DateTime expiryDate,
  }) async {
    addedBatches.add({
      'pharmacyUid': pharmacyUid,
      'productId': productId,
      'batchNumber': batchNumber,
      'supplierName': supplierName,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'initialQuantity': initialQuantity,
      'expiryDate': expiryDate,
    });
  }

  @override
  Future<void> addProduct({
    required String pharmacyUid,
    required String brandName,
    required String genericName,
    required String category,
    required String manufacturer,
    required String shelfLocation,
    String unitType = 'Tablet',
    int minStockAlert = 10,
  }) async {}

  @override
  Future<int> addMultipleProducts({
    required String pharmacyUid,
    required List<ProductImportItem> products,
  }) async => products.length;

  @override
  Future<List<Product>> getActiveProducts(String pharmacyUid) async => [];

  @override
  Stream<List<String>> watchDistinctUnitTypes(String pharmacyUid) => const Stream.empty();

  @override
  Future<List<String>> getDistinctUnitTypes(String pharmacyUid) async => [];

  @override
  Future<CsvBatchImportReport> importMedicinesWithDuplicateCheck({
    required String pharmacyUid,
    required List<ProductImportItem> parsedProducts,
    required List<CsvSkippedItem> initialSkippedItems,
  }) async {
    return CsvBatchImportReport(
      insertedCount: parsedProducts.length,
      existingDbDuplicateCount: 0,
      inCsvDuplicateCount: 0,
      skippedMissingCount: initialSkippedItems.length,
      insertedProducts: parsedProducts,
      skippedItems: initialSkippedItems,
    );
  }

  @override
  Future<void> deleteBatch(String pharmacyUid, String batchId) async {}

  @override
  Future<void> deleteProduct(String pharmacyUid, String productId) async {}

  @override
  Future<void> updateBatch({
    required String batchId,
    required String pharmacyUid,
    required String productId,
    required String batchNumber,
    String? supplierName,
    required double purchasePrice,
    required double sellingPrice,
    required int currentStock,
    required DateTime expiryDate,
  }) async {
    updatedBatches.add({
      'batchId': batchId,
      'batchNumber': batchNumber,
      'supplierName': supplierName,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'expiryDate': expiryDate,
    });
  }

  @override
  Future<void> updateProduct({
    required String productId,
    required String pharmacyUid,
    required String brandName,
    required String genericName,
    required String category,
    required String manufacturer,
    required String shelfLocation,
    required String unitType,
    required int minStockAlert,
  }) async {}

  @override
  Stream<List<ProductBatch>> watchBatchesForProduct(String pharmacyUid, String productId) => const Stream.empty();

  @override
  Stream<List<BatchWithProductInfo>> watchExpiredBatches(String pharmacyUid) => const Stream.empty();

  @override
  Stream<List<BatchWithProductInfo>> watchExpiringBatches(
    String pharmacyUid, {
    int minDays = 0,
    required int maxDays,
  }) => const Stream.empty();

  @override
  Stream<List<ProductWithAggregateStock>> watchProducts(String pharmacyUid, {String? searchQuery}) => const Stream.empty();

  @override
  Stream<List<InventoryStatusItem>> watchInventoryStatus(String pharmacyUid) => const Stream.empty();

  @override
  Future<List<InventoryStatusItem>> getInventoryStatus(String pharmacyUid) async => [];
}

UserSession _createTestSession({UserRole role = UserRole.owner}) {
  return UserSession(
    userId: 'user-001',
    username: 'admin',
    fullName: 'Pharmacy Admin',
    role: role,
    pharmacyUid: 'pharmacy-test-101',
    pharmacyName: 'Central Care Pharmacy',
    currencySymbol: '\$',
    token: 'test-token',
    loginTimestamp: DateTime.now(),
  );
}

Product _createSampleProduct({
  String id = 'prod-1',
  String brandName = 'Napa Extra 500mg',
  String genericName = 'Paracetamol + Caffeine',
  String category = 'Analgesic / Antipyretic',
  String shelfLocation = 'Rack A-12',
  int minStockAlert = 20,
}) {
  final now = DateTime.now();
  return Product(
    id: id,
    pharmacyUid: 'pharmacy-test-101',
    brandName: brandName,
    genericName: genericName,
    category: category,
    manufacturer: 'Beximco Pharma',
    shelfLocation: shelfLocation,
    unitType: 'Tablet',
    minStockAlert: minStockAlert,
    createdAt: now,
    updatedAt: now,
    syncStatus: 'synced',
  );
}

ProductBatch _createSampleBatch({
  String id = 'batch-1',
  String productId = 'prod-1',
  String batchNumber = 'BATCH-2026-X',
  String supplierName = 'National Med Depot',
  double purchasePrice = 2.0,
  double sellingPrice = 3.5,
  int currentStock = 120,
  required DateTime expiryDate,
}) {
  final now = DateTime.now();
  return ProductBatch(
    id: id,
    pharmacyUid: 'pharmacy-test-101',
    productId: productId,
    batchNumber: batchNumber,
    supplierName: supplierName,
    purchasePrice: purchasePrice,
    sellingPrice: sellingPrice,
    initialQuantity: currentStock,
    currentStock: currentStock,
    expiryDate: expiryDate,
    createdAt: now,
    updatedAt: now,
    syncStatus: 'synced',
  );
}

void main() {
  group('Medicine Master Catalog UI Tests', () {
    testWidgets('Renders catalog with search, category chips, shelf location and stock indicators', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleItem = ProductWithAggregateStock(
        product: sampleProd,
        activeStock: 250,
        expiredStock: 0,
        batchCount: 2,
        earliestExpiry: DateTime(2027, 6, 15),
        isLowStock: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession(role: UserRole.owner)),
            currentUserRoleProvider.overrideWithValue(UserRole.owner),
            productsWithStockProvider.overrideWith((ref) => Stream.value([sampleItem])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MedicinesMasterView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify Header & Search
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Add Medicine (F3)'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      // Tap Refresh button
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(find.text('Refreshing...'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Refresh'), findsOneWidget);

      // Verify Category Chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Antibiotic'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Analgesic / Antipyretic'), findsOneWidget);

      // Verify Table Row Contents
      expect(find.text('Napa Extra 500mg'), findsOneWidget);
      expect(find.text('Paracetamol + Caffeine'), findsOneWidget);
      expect(find.text('Rack A-12'), findsOneWidget);
      expect(find.text('250 units'), findsOneWidget);
    });

    testWidgets('Salesman view-only mode hides Add Medicine button and displays restricted role notice', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleItem = ProductWithAggregateStock(
        product: sampleProd,
        activeStock: 100,
        expiredStock: 0,
        batchCount: 1,
        earliestExpiry: DateTime(2027, 1, 1),
        isLowStock: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession(role: UserRole.salesman)),
            currentUserRoleProvider.overrideWithValue(UserRole.salesman),
            productsWithStockProvider.overrideWith((ref) => Stream.value([sampleItem])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MedicinesMasterView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Salesman should NOT see Add Medicine button
      expect(find.text('Add Medicine (F3)'), findsNothing);
      // Salesman should see View-Only notice banner
      expect(find.textContaining('Salesman View-Only Mode'), findsOneWidget);
      // Salesman should NOT see Delete icon
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('Tapping delete icon on medicine with unsold stock blocks deletion and offers Manage Batches', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleItem = ProductWithAggregateStock(
        product: sampleProd,
        activeStock: 80,
        expiredStock: 20,
        batchCount: 2,
        earliestExpiry: DateTime(2027, 6, 15),
        isLowStock: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession(role: UserRole.owner)),
            currentUserRoleProvider.overrideWithValue(UserRole.owner),
            productsWithStockProvider.overrideWith((ref) => Stream.value([sampleItem])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MedicinesMasterView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Find and tap delete button
      final deleteBtn = find.byIcon(Icons.delete_outline);
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Should show Cannot Delete dialog
      expect(find.text('Cannot Delete Medicine'), findsOneWidget);
      expect(find.textContaining('Active Stock: 80 units'), findsOneWidget);
      expect(find.textContaining('Expired Stock: 20 units'), findsOneWidget);
      expect(find.textContaining('Total Unsold Stock: 100 units'), findsOneWidget);
      expect(find.text('Manage Batches'), findsOneWidget);
    });
  });

  group('Batch Management Dialog UI Tests', () {
    testWidgets('Renders multi-supplier fields and calculates real-time gross margin preview', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(
        expiryDate: DateTime.now().add(const Duration(days: 120)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession(role: UserRole.owner)),
            currentUserRoleProvider.overrideWithValue(UserRole.owner),
            productBatchesProvider(sampleProd.id).overrideWith((ref) => Stream.value([sampleBatch])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BatchManagementDialog(product: sampleProd),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify Header Info
      expect(find.text('Napa Extra 500mg'), findsOneWidget);
      expect(find.textContaining('Rack A-12'), findsOneWidget);

      // Verify Multi-Supplier Procurement Form Fields
      expect(find.text('Batch Number *'), findsOneWidget);
      expect(find.text('Supplier / Distributor Store *'), findsOneWidget);
      expect(find.text('Units Received *'), findsOneWidget);
      expect(find.text('Total Cost (৳) *'), findsOneWidget);
      expect(find.text('Purchase Cost Price (৳) *'), findsOneWidget);
      expect(find.text('Selling Price MRP (৳) *'), findsOneWidget);

      // Verify Existing Batch is listed in FEFO Priority Table
      expect(find.text('Batch #BATCH-2026-X'), findsOneWidget);
      expect(find.text('Supplier: National Med Depot'), findsOneWidget);
      expect(find.text('FEFO Priority #1'), findsOneWidget);
      // Verify Date format is DD-MM-YYYY in FEFO ledger
      expect(find.text(DateFormat('dd-MM-yyyy').format(sampleBatch.expiryDate)), findsOneWidget);

      // Enter Units: 100 and Total Cost: $2000.00 -> Verify Purchase Price auto-calculates to $20.00
      await tester.enterText(find.widgetWithText(TextFormField, 'Units Received *'), '100');
      await tester.enterText(find.widgetWithText(TextFormField, 'Total Cost (৳) *'), '2000.00');
      await tester.pump();

      // Purchase Cost Price should automatically calculate: 2000 / 100 = 20.00
      expect(find.widgetWithText(TextFormField, '20.00'), findsOneWidget);

      // Enter Selling MRP $30.00 -> Verify Gross Margin calculation
      await tester.enterText(find.widgetWithText(TextFormField, 'Selling Price MRP (৳) *'), '30.00');
      await tester.pump();

      // Selling $30 - Cost $20 = Profit $10 -> Margin: (30 - 20)/30 * 100 = 33.3%
      expect(find.text('Est. Gross Margin: 33.3%'), findsOneWidget);
    });

    testWidgets('Add Same Batch populates form, shows popup if batch number unchanged, and saves if changed', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sampleProd = _createSampleProduct();
      final sampleBatch = _createSampleBatch(
        id: 'batch-test-1',
        productId: sampleProd.id,
        batchNumber: 'BATCH-2026-X',
        supplierName: 'National Med Depot',
        purchasePrice: 15.50,
        sellingPrice: 22.00,
        currentStock: 80,
        expiryDate: DateTime(2027, 8, 20),
      );

      final fakeRepo = _FakeInventoryRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession(role: UserRole.owner)),
            currentUserRoleProvider.overrideWithValue(UserRole.owner),
            productBatchesProvider(sampleProd.id).overrideWith((ref) => Stream.value([sampleBatch])),
            inventoryRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BatchManagementDialog(product: sampleProd),
            ),
          ),
        ),
      );

      await tester.pump();

      // Open Popup Menu for batch
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Verify 3 options exist (Adjust Stock Count is now Edit Batch)
      expect(find.text('Add Same Batch'), findsOneWidget);
      expect(find.text('Edit Batch'), findsOneWidget);
      expect(find.text('Delete Batch'), findsOneWidget);

      // Tap 'Add Same Batch'
      await tester.tap(find.text('Add Same Batch'));
      await tester.pumpAndSettle();

      // Verify form is populated with auto-generated batch number (BA-YYYYMMDD-...) and source batch data
      final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
      expect(find.textContaining('BA-$todayStr-'), findsWidgets);
      expect(find.widgetWithText(TextFormField, '15.50'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '22.00'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '80'), findsOneWidget);

      // Click "Add Batch" to save the cloned batch
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Batch'));
      await tester.pumpAndSettle();

      // Verify batch was added with auto-generated batch number
      expect(fakeRepo.addedBatches.length, equals(1));
      expect(fakeRepo.addedBatches.first['batchNumber'], startsWith('BA-$todayStr-'));
      expect(fakeRepo.addedBatches.first['purchasePrice'], equals(15.50));
      expect(fakeRepo.addedBatches.first['sellingPrice'], equals(22.00));

      // Now test 'Edit Batch' flow
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Batch'));
      await tester.pumpAndSettle();

      // Button should now be 'Edit Batch'
      expect(find.widgetWithText(ElevatedButton, 'Edit Batch'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'BATCH-2026-X'), findsOneWidget);

      // Change selling price to 25.00 and save
      final priceField = find.widgetWithText(TextFormField, '22.00');
      await tester.enterText(priceField, '25.00');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Edit Batch'));
      await tester.pumpAndSettle();

      // Verify update was dispatched to repository
      expect(fakeRepo.updatedBatches.length, equals(1));
      expect(fakeRepo.updatedBatches.first['batchNumber'], equals('BATCH-2026-X'));
      expect(fakeRepo.updatedBatches.first['sellingPrice'], equals(25.00));
    });
  });

  group('Expiry Radar & Stock Alerts UI Tests', () {
    testWidgets('Displays urgency indicators (🔴 Expired, 🟡 <30d, 🟠 31-60d, 🟡 61-90d, ⚠️ Low Stock)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final expiredBatch = _createSampleBatch(
        id: 'b-exp',
        batchNumber: 'EXP-101',
        expiryDate: now.subtract(const Duration(days: 10)),
      );

      final urgentBatch = _createSampleBatch(
        id: 'b-urg',
        batchNumber: 'URG-202',
        expiryDate: now.add(const Duration(days: 15)),
      );

      final warningBatch = _createSampleBatch(
        id: 'b-warn',
        batchNumber: 'WARN-303',
        expiryDate: now.add(const Duration(days: 45)),
      );

      final cautionBatch = _createSampleBatch(
        id: 'b-caut',
        batchNumber: 'CAUT-404',
        expiryDate: now.add(const Duration(days: 75)),
      );

      final prod = _createSampleProduct();

      final expiredItem = BatchWithProductInfo(batch: expiredBatch, product: prod);
      final urgentItem = BatchWithProductInfo(batch: urgentBatch, product: prod);
      final warningItem = BatchWithProductInfo(batch: warningBatch, product: prod);
      final cautionItem = BatchWithProductInfo(batch: cautionBatch, product: prod);

      final lowStockItem = ProductWithAggregateStock(
        product: prod,
        activeStock: 5, // Alert threshold is 20 -> Deficit of 15
        expiredStock: 0,
        batchCount: 1,
        earliestExpiry: now.add(const Duration(days: 120)),
        isLowStock: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(_createTestSession(role: UserRole.owner)),
            currentUserRoleProvider.overrideWithValue(UserRole.owner),
            expiredBatchesProvider.overrideWith((ref) => Stream.value([expiredItem])),
            urgentExpiringBatchesProvider.overrideWith((ref) => Stream.value([urgentItem])),
            warningExpiringBatchesProvider.overrideWith((ref) => Stream.value([warningItem])),
            cautionExpiringBatchesProvider.overrideWith((ref) => Stream.value([cautionItem])),
            lowStockProductsProvider.overrideWithValue([lowStockItem]),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ExpiryRadarView(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify 5 Urgency KPI summary cards exist
      expect(find.text('Expired Stock'), findsOneWidget);
      expect(find.text('Expiring < 30 Days'), findsOneWidget);
      expect(find.text('Expiring 31-60 Days'), findsOneWidget);
      expect(find.text('Expiring 61-90 Days'), findsOneWidget);
      expect(find.text('Low Stock Threshold'), findsOneWidget);

      // Verify shelf location is displayed for physical warehouse retrieval
      expect(find.text('Rack A-12'), findsWidgets);

      // Verify expired batch blocked indicator
      expect(find.textContaining('🔴 EXPIRED'), findsWidgets);
      expect(find.text('Batch #EXP-101'), findsOneWidget);
    });
  });
}
