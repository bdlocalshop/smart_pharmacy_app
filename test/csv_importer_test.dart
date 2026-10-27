import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/inventory/data/inventory_repository.dart';
import 'package:smart_pharmacy_app/features/inventory/domain/csv_medicine_importer.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/views/csv_import_dialog.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/views/medicine_dialog.dart';

void main() {
  group('CsvMedicineImporter Unit Tests', () {
    test('Correctly parses complete CSV with standard headers', () {
      const csvData = '''Brand / Commercial Name,Generic Formula,Therapeutic Category,Manufacturer / Brand Pharma,Physical Shelf Location,Dispensing Unit Type,Minimum Reorder Alert Threshold
Panadol 500mg,Paracetamol,Analgesic,GSK,Rack A-1,Tablet,60
Amoxil 250mg,Amoxicillin,Antibiotic,Pfizer,Rack B-3,Capsule,25''';

      final result = CsvMedicineImporter.parseCsv(csvData);
      expect(result.validProducts.length, equals(2));
      expect(result.skippedCount, equals(0));

      final p1 = result.validProducts[0];
      expect(p1.brandName, equals('Panadol 500mg'));
      expect(p1.genericName, equals('Paracetamol'));
      expect(p1.category, equals('Analgesic'));
      expect(p1.manufacturer, equals('GSK'));
      expect(p1.shelfLocation, equals('Rack A-1'));
      expect(p1.unitType, equals('Tablet'));
      expect(p1.minStockAlert, equals(60));

      final p2 = result.validProducts[1];
      expect(p2.brandName, equals('Amoxil 250mg'));
      expect(p2.genericName, equals('Amoxicillin'));
      expect(p2.category, equals('Antibiotic'));
      expect(p2.manufacturer, equals('Pfizer'));
      expect(p2.shelfLocation, equals('Rack B-3'));
      expect(p2.unitType, equals('Capsule'));
      expect(p2.minStockAlert, equals(25));
    });

    test('Skips rows where Brand / Commercial Name is missing', () {
      const csvData = '''Brand / Commercial Name,Generic Formula,Therapeutic Category,Manufacturer / Brand Pharma,Physical Shelf Location,Dispensing Unit Type,Minimum Reorder Alert Threshold
,Paracetamol,Analgesic,GSK,Rack A-1,Tablet,50
Napa Extra,Paracetamol + Caffeine,Analgesic,Beximco,Rack A-2,Tablet,100
"   ",Ibuprofen,Analgesic,Square,Rack A-3,Tablet,40''';

      final result = CsvMedicineImporter.parseCsv(csvData);
      expect(result.validProducts.length, equals(1));
      expect(result.validProducts.first.brandName, equals('Napa Extra'));
      expect(result.skippedCount, equals(2));
      expect(result.skippedReasons[0], contains('Row 2: Skipped because Brand / Commercial Name is missing'));
      expect(result.skippedReasons[1], contains('Row 4: Skipped because Brand / Commercial Name is missing'));
    });

    test('Applies fallback rules: Shelf -> "Rack 0-0", Threshold -> 50, Others -> "Not Available"', () {
      const csvData = '''Brand / Commercial Name,Generic Formula,Therapeutic Category,Manufacturer / Brand Pharma,Physical Shelf Location,Dispensing Unit Type,Minimum Reorder Alert Threshold
Mystery Med,,,,,,
Vitamin C,,,,Rack C-1,,
Cough Drops,Menthol,,,,Syrup,invalid_number''';

      final result = CsvMedicineImporter.parseCsv(csvData);
      expect(result.validProducts.length, equals(3));
      expect(result.skippedCount, equals(0));

      // Mystery Med: All missing except name
      final m1 = result.validProducts[0];
      expect(m1.brandName, equals('Mystery Med'));
      expect(m1.genericName, equals('Not Available'));
      expect(m1.category, equals('Not Available'));
      expect(m1.manufacturer, equals('Not Available'));
      expect(m1.shelfLocation, equals('Rack 0-0')); // Rule: Rack 0-0
      expect(m1.unitType, equals('Tablet'));
      expect(m1.minStockAlert, equals(50)); // Rule: 50

      // Vitamin C: Shelf is specified, others missing
      final m2 = result.validProducts[1];
      expect(m2.brandName, equals('Vitamin C'));
      expect(m2.genericName, equals('Not Available'));
      expect(m2.shelfLocation, equals('Rack C-1'));
      expect(m2.minStockAlert, equals(50));

      // Cough Drops: Invalid threshold string -> defaults to 50
      final m3 = result.validProducts[2];
      expect(m3.brandName, equals('Cough Drops'));
      expect(m3.genericName, equals('Menthol'));
      expect(m3.shelfLocation, equals('Rack 0-0'));
      expect(m3.unitType, equals('Syrup'));
      expect(m3.minStockAlert, equals(50));
    });

    test('Handles UTF-8 BOM properly', () {
      const bomData = '\uFEFFBrand / Commercial Name,Generic Formula\nFlagyl 400mg,Metronidazole';
      final result = CsvMedicineImporter.parseCsv(bomData);
      expect(result.validProducts.length, equals(1));
      expect(result.validProducts.first.brandName, equals('Flagyl 400mg'));
      expect(result.validProducts.first.genericName, equals('Metronidazole'));
      expect(result.validProducts.first.shelfLocation, equals('Rack 0-0'));
      expect(result.validProducts.first.minStockAlert, equals(50));
    });

    test('Template generator produces valid parseable template', () {
      final template = CsvMedicineImporter.generateCsvTemplate();
      final result = CsvMedicineImporter.parseCsv(template);
      expect(result.validProducts.isNotEmpty, isTrue);
      expect(result.skippedCount, equals(0));
    });
  });

  group('Database Batch Insertion Tests', () {
    late AppDatabase db;
    late InventoryRepository repo;
    const testUid = 'ph-batch-import-test';

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = InventoryRepository(db);

      await db.into(db.pharmacySettingsTable).insert(
            PharmacySettingsTableCompanion.insert(
              pharmacyUid: testUid,
              pharmacyName: 'Bulk Import Pharmacy',
              contactPhone: '555-1234',
              address: const Value('123 Import Ave'),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('addMultipleProducts inserts items atomically and reflects in catalog stream', () async {
      const csvData = '''Brand / Commercial Name,Generic Formula,Therapeutic Category,Manufacturer / Brand Pharma,Physical Shelf Location,Dispensing Unit Type,Minimum Reorder Alert Threshold
Paracetamol 500mg,Paracetamol,Analgesic,PharmaCorp,Rack 1-A,Tablet,40
,Paracetamol,Analgesic,PharmaCorp,Rack 1-A,Tablet,40
Omeprazole 20mg,Omeprazole,Gastrointestinal,HealthPharma,,Capsule,''';

      final parsed = CsvMedicineImporter.parseCsv(csvData);
      expect(parsed.validProducts.length, equals(2));
      expect(parsed.skippedCount, equals(1));

      final insertedCount = await repo.addMultipleProducts(
        pharmacyUid: testUid,
        products: parsed.validProducts,
      );

      expect(insertedCount, equals(2));

      final catalog = await repo.watchProducts(testUid).first;
      expect(catalog.length, equals(2));

      final omeprazole = catalog.firstWhere((p) => p.product.brandName == 'Omeprazole 20mg');
      expect(omeprazole.product.shelfLocation, equals('Rack 0-0'));
      expect(omeprazole.product.minStockAlert, equals(50));
      expect(omeprazole.product.category, equals('Gastrointestinal'));
      expect(omeprazole.product.unitType, equals('Capsule'));
    });
  });

  group('MedicineDialog & Add Multiple UI Tests', () {
    testWidgets('Renders Add Multiple button at the bottom-left of Add Medicine Dialog', (tester) async {
      final session = UserSession(
        userId: 'admin-001',
        username: 'admin',
        fullName: 'Admin User',
        role: UserRole.owner,
        pharmacyUid: 'pharmacy-test-101',
        pharmacyName: 'Test Pharmacy',
        currencySymbol: '\$',
        token: 'test-token',
        loginTimestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWith((ref) => session),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MedicineDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Dialog Title
      expect(find.text('Add New Medicine to Catalog'), findsOneWidget);

      // Verify "Add Multiple" button is present
      final addMultipleBtn = find.byKey(const ValueKey('add_multiple_button'));
      expect(addMultipleBtn, findsOneWidget);
      expect(find.text('Add Multiple'), findsOneWidget);

      // Verify standard buttons are also present on the right
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Add Medicine'), findsOneWidget);
    });

    testWidgets('CsvImportDialog renders rules and download template button', (tester) async {
      final session = UserSession(
        userId: 'admin-001',
        username: 'admin',
        fullName: 'Admin User',
        role: UserRole.owner,
        pharmacyUid: 'pharmacy-test-101',
        pharmacyName: 'Test Pharmacy',
        currencySymbol: '\$',
        token: 'test-token',
        loginTimestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserSessionProvider.overrideWith((ref) => session),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CsvImportDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Multiple Medicines (CSV Upload)'), findsOneWidget);
      expect(find.text('Download CSV Template'), findsOneWidget);
      expect(find.textContaining('Missing Brand/Commercial Name: Row is skipped'), findsOneWidget);
      expect(find.textContaining('Missing Shelf Location: Automatically assigned to "Rack 0-0"'), findsOneWidget);
      expect(find.textContaining('Defaults to 50 units'), findsOneWidget);
      expect(find.textContaining('Marked as "Not Available"'), findsOneWidget);
      expect(find.text('Click here to Browse & Select your CSV File'), findsOneWidget);
    });
  });
}
