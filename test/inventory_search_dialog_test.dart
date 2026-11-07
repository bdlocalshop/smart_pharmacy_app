import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/daos/products_dao.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/views/database_backups_view.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/views/inventory_search_dialog.dart';

void main() {
  final now = DateTime.now();

  final testSession = UserSession(
    userId: 'user-001',
    username: 'admin',
    fullName: 'Pharmacy Admin',
    role: UserRole.owner,
    pharmacyUid: 'pharmacy-test-101',
    pharmacyName: 'Central Care Pharmacy',
    currencySymbol: '৳',
    token: 'test-token',
    loginTimestamp: now,
  );

  final List<InventoryStatusItem> sampleProducts = [
    InventoryStatusItem(
      product: Product(
        id: 'prod-1',
        pharmacyUid: 'pharmacy-test-101',
        brandName: 'Napa 500mg',
        genericName: 'Paracetamol',
        category: 'Analgesic',
        manufacturer: 'Beximco',
        shelfLocation: 'Rack A-1',
        unitType: 'Tablet',
        minStockAlert: 10,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'synced',
      ),
      totalStock: 100,
      activeStock: 100,
      expiredStock: 0,
      totalPurchaseCost: 200.0,
      totalSaleValue: 300.0,
      batchCount: 2,
      batches: [],
    ),
    InventoryStatusItem(
      product: Product(
        id: 'prod-2',
        pharmacyUid: 'pharmacy-test-101',
        brandName: 'Losec 20mg',
        genericName: 'Omeprazole',
        category: 'Gastrointestinal',
        manufacturer: 'Square',
        shelfLocation: 'Rack B-2',
        unitType: 'Capsule',
        minStockAlert: 15,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'synced',
      ),
      totalStock: 50,
      activeStock: 50,
      expiredStock: 0,
      totalPurchaseCost: 250.0,
      totalSaleValue: 400.0,
      batchCount: 1,
      batches: [],
    ),
    InventoryStatusItem(
      product: Product(
        id: 'prod-3',
        pharmacyUid: 'pharmacy-test-101',
        brandName: 'A-Fenac Plus',
        genericName: 'Diclofenac Sodium',
        category: 'NSAID',
        manufacturer: 'ACME',
        shelfLocation: 'Rack C-1',
        unitType: 'IM Injection',
        minStockAlert: 5,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'synced',
      ),
      totalStock: 20,
      activeStock: 20,
      expiredStock: 0,
      totalPurchaseCost: 100.0,
      totalSaleValue: 160.0,
      batchCount: 1,
      batches: [],
    ),
  ];

  group('InventorySearchDialog Widget Tests', () {
    testWidgets('Renders Row 1 with default "all", Search button, and Row 2 summary with CSV button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(testSession),
            inventoryStatusProvider.overrideWith((ref) => Stream.value(sampleProducts)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: InventorySearchDialog(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // Row 1: Input text field defaults to "all" and Search button exists
      expect(find.text('all'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Search'), findsOneWidget);

      // Row 2: Summary header & Download as CSV button exist
      expect(find.text('MEDICINE(S)'), findsOneWidget);
      expect(find.text('All Medicines (3 items)'), findsOneWidget);
      expect(find.text('TOTAL PURCHASE COST'), findsOneWidget);
      expect(find.text('TOTAL SALE PRICE'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Download as CSV'), findsOneWidget);

      // Total purchase cost = 200 + 250 + 100 = 550.00
      expect(find.text('৳ 550.00'), findsWidgets);

      // Total sale price = 300 + 400 + 160 = 860.00
      expect(find.text('৳ 860.00'), findsWidgets);

      // All 3 medicines visible in breakdown list
      expect(find.text('Napa 500mg'), findsOneWidget);
      expect(find.text('Losec 20mg'), findsOneWidget);
      expect(find.text('A-Fenac Plus'), findsOneWidget);
    });

    testWidgets('Comma-separated search filters Row 2 summary and table items correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(testSession),
            inventoryStatusProvider.overrideWith((ref) => Stream.value(sampleProducts)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: InventorySearchDialog(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // Enter comma separated medicines "Napa, Losec"
      final searchField = find.byType(TextFormField);
      await tester.enterText(searchField, 'Napa, Losec');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Search'));
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Check Row 2 updated
      expect(find.text('Matches for "Napa, Losec" (2 items)'), findsOneWidget);

      // Total purchase cost for Napa + Losec = 200 + 250 = 450.00
      expect(find.text('৳ 450.00'), findsWidgets);
      // Total sale price for Napa + Losec = 300 + 400 = 700.00
      expect(find.text('৳ 700.00'), findsWidgets);

      // Napa and Losec are present, A-Fenac is not
      expect(find.text('Napa 500mg'), findsOneWidget);
      expect(find.text('Losec 20mg'), findsOneWidget);
      expect(find.text('A-Fenac Plus'), findsNothing);
    });

    testWidgets('Paginates medicines across pages with next, previous and page-range indicators', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      final manyMedicines = List.generate(15, (index) {
        final numStr = (index + 1).toString().padLeft(2, '0');
        return InventoryStatusItem(
          product: Product(
            id: 'prod-$index',
            pharmacyUid: 'pharmacy-test-101',
            brandName: 'Medicine $numStr',
            genericName: 'Formula $numStr',
            category: 'Category',
            manufacturer: 'Manufacturer',
            shelfLocation: 'Rack A-1',
            unitType: 'Tablet',
            minStockAlert: 10,
            createdAt: now,
            updatedAt: now,
            syncStatus: 'synced',
          ),
          totalStock: 50,
          activeStock: 50,
          expiredStock: 0,
          totalPurchaseCost: 100.0,
          totalSaleValue: 150.0,
          batchCount: 1,
          batches: [],
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(testSession),
            inventoryStatusProvider.overrideWith((ref) => Stream.value(manyMedicines)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: InventorySearchDialog(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // Check initial page: 1 to 10 of 15 medicines, Page 1 of 2
      expect(find.text('Showing 1–10 of 15 medicines'), findsOneWidget);
      expect(find.text('Page 1 of 2'), findsOneWidget);
      expect(find.text('Medicine 01'), findsOneWidget);
      expect(find.text('Medicine 11'), findsNothing);

      // Tap Next Page
      final nextButton = find.byTooltip('Next Page');
      await tester.tap(nextButton);
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // Check second page: 11 to 15 of 15 medicines, Page 2 of 2
      expect(find.text('Showing 11–15 of 15 medicines'), findsOneWidget);
      expect(find.text('Page 2 of 2'), findsOneWidget);
      expect(find.text('Medicine 11'), findsOneWidget);
      expect(find.text('Medicine 01'), findsNothing);

      // Tap Previous Page
      final prevButton = find.byTooltip('Previous Page');
      await tester.tap(prevButton);
      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // Back to Page 1
      expect(find.text('Showing 1–10 of 15 medicines'), findsOneWidget);
      expect(find.text('Page 1 of 2'), findsOneWidget);
      expect(find.text('Medicine 01'), findsOneWidget);
    });

    test('Background CSV isolate worker formats rows and writes CSV file correctly', () async {
      final tempFile = File('${Directory.systemTemp.path}${Platform.pathSeparator}test_inventory_${DateTime.now().millisecondsSinceEpoch}.csv');
      final payload = CsvExportPayload(
        items: sampleProducts,
        currencySymbol: '৳',
        targetFilePath: tempFile.path,
      );

      final filePath = await compute(generateAndSaveCsvInBackground, payload);
      expect(filePath, equals(tempFile.path));
      expect(tempFile.existsSync(), isTrue);

      final content = tempFile.readAsStringSync();
      expect(content, contains('Medicine Name (Brand)'));
      expect(content, contains('Napa 500mg'));
      expect(content, contains('Losec 20mg'));
      expect(content, contains('A-Fenac Plus'));
      expect(content, contains('TOTAL / SUMMARY (3 medicines)'));

      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    });

    testWidgets('Renders Download as CSV button ready for background export', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(testSession),
            inventoryStatusProvider.overrideWith((ref) => Stream.value(sampleProducts)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: InventorySearchDialog(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      final csvButton = find.widgetWithText(ElevatedButton, 'Download as CSV');
      expect(csvButton, findsOneWidget);
    });

    testWidgets('DatabaseBackupsView displays Inventory Search button and does NOT display Upload to Cloud Backup in top bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWithValue(testSession),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DatabaseBackupsView(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Button "Inventory Search" is present
      expect(find.widgetWithText(OutlinedButton, 'Inventory Search'), findsOneWidget);

      // Button "Upload to Cloud Backup" in the top bar is REMOVED
      expect(find.widgetWithText(OutlinedButton, 'Upload to Cloud Backup'), findsNothing);
    });
  });
}
