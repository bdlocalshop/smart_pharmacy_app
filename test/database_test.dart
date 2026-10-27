import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/constants/app_constants.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/seed_data.dart';
import 'package:smart_pharmacy_app/core/errors/exceptions.dart';

void main() {
  late AppDatabase db;
  late DatabaseSeeder seeder;

  setUp(() async {
    // In-memory SQLite for isolated test runs
    db = AppDatabase(NativeDatabase.memory());
    seeder = DatabaseSeeder(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Schema & Seed Data Tests', () {
    test('Database seeds initial pharmacy settings, users, and medicines', () async {
      final seeded = await seeder.seedIfEmpty();
      expect(seeded, isTrue);

      // Verify Pharmacy Settings
      final settings = await db.select(db.pharmacySettingsTable).get();
      expect(settings.length, equals(1));
      final pharmacy = settings.first;
      expect(pharmacy.pharmacyName, equals('Smart Pharmacy & Healthcare'));
      expect(pharmacy.pharmacyUid.isNotEmpty, isTrue);

      // Verify Users (Owner, Manager, Salesman)
      final users = await db.select(db.usersTable).get();
      expect(users.length, equals(3));

      final owner = users.firstWhere((u) => u.role == AppConstants.roleOwner);
      expect(owner.username, equals('admin'));
      expect(owner.pharmacyUid, equals(pharmacy.pharmacyUid));

      // Test User Authentication via DAO
      final authenticated = await db.usersDao.authenticate('admin', 'admin123');
      expect(authenticated, isNotNull);
      expect(authenticated!.role, equals(AppConstants.roleOwner));

      final wrongAuth = await db.usersDao.authenticate('admin', 'wrong_password');
      expect(wrongAuth, isNull);

      // Verify idempotency
      final secondRun = await seeder.seedIfEmpty();
      expect(secondRun, isFalse);
    });

    test('Medicines and batches are properly linked with pharmacy_uid', () async {
      await seeder.seedIfEmpty();

      final products = await db.select(db.productsTable).get();
      expect(products.length, greaterThanOrEqualTo(5));

      final batches = await db.select(db.productBatchesTable).get();
      expect(batches.length, greaterThanOrEqualTo(8));

      for (final p in products) {
        expect(p.pharmacyUid.isNotEmpty, isTrue);
        expect(p.id.isNotEmpty, isTrue);
      }

      for (final b in batches) {
        expect(b.pharmacyUid.isNotEmpty, isTrue);
        expect(b.productId.isNotEmpty, isTrue);
        expect(b.batchNumber.isNotEmpty, isTrue);
        expect(b.currentStock, greaterThanOrEqualTo(0));
      }
    });
  });

  group('FEFO (First Expired, First Out) Logic Tests', () {
    test('getFefoBatches returns batches sorted chronologically by expiry date', () async {
      await seeder.seedIfEmpty();

      final panadol = await (db.select(db.productsTable)
            ..where((tbl) => tbl.brandName.equals('Panadol 500mg')))
          .getSingle();

      final fefoBatches = await db.productsDao.getFefoBatches(panadol.pharmacyUid, panadol.id).get();
      expect(fefoBatches.length, equals(2));

      // Earliest expiry should be first
      expect(fefoBatches[0].batchNumber, equals('PAN-2026-01'));
      expect(fefoBatches[1].batchNumber, equals('PAN-2027-02'));
      expect(fefoBatches[0].expiryDate.isBefore(fefoBatches[1].expiryDate), isTrue);
    });

    test('FEFO ignores expired batches for normal active selling', () async {
      await seeder.seedIfEmpty();

      final losec = await (db.select(db.productsTable)
            ..where((tbl) => tbl.brandName.equals('Losec 20mg')))
          .getSingle();

      // Losec has 1 expired batch and 1 valid batch
      final fefoBatches = await db.productsDao.getFefoBatches(losec.pharmacyUid, losec.id).get();
      expect(fefoBatches.length, equals(1));
      expect(fefoBatches.first.batchNumber, equals('OMP-2027-02'));

      // Check expired batches query detects the expired batch
      final expired = await db.productsDao.getExpiredBatches(losec.pharmacyUid).get();
      expect(expired.any((b) => b.batchNumber == 'OMP-EXPIRED-01'), isTrue);
    });

    test('deductStockFefo deducts from earliest batch first in transaction', () async {
      await seeder.seedIfEmpty();

      final panadol = await (db.select(db.productsTable)
            ..where((tbl) => tbl.brandName.equals('Panadol 500mg')))
          .getSingle();

      // Initial Panadol: PAN-2026-01 has 40 units, PAN-2027-02 has 200 units.
      // Request 50 units: should deduct 40 from Batch 1, and 10 from Batch 2.
      final allocations = await db.productsDao.deductStockFefo(
        pharmacyUid: panadol.pharmacyUid,
        productId: panadol.id,
        requestedQuantity: 50,
      );

      expect(allocations.length, equals(2));
      expect(allocations[0].batch.batchNumber, equals('PAN-2026-01'));
      expect(allocations[0].deductedQuantity, equals(40));
      expect(allocations[1].batch.batchNumber, equals('PAN-2027-02'));
      expect(allocations[1].deductedQuantity, equals(10));

      // Re-query batches to ensure DB was updated
      final updatedBatch1 = await (db.select(db.productBatchesTable)
            ..where((tbl) => tbl.id.equals(allocations[0].batch.id)))
          .getSingle();
      expect(updatedBatch1.currentStock, equals(0));

      final updatedBatch2 = await (db.select(db.productBatchesTable)
            ..where((tbl) => tbl.id.equals(allocations[1].batch.id)))
          .getSingle();
      expect(updatedBatch2.currentStock, equals(190));
    });

    test('deductStockFefo throws InsufficientStockException on excessive quantity', () async {
      await seeder.seedIfEmpty();

      final zyrtec = await (db.select(db.productsTable)
            ..where((tbl) => tbl.brandName.equals('Zyrtec 10mg')))
          .getSingle();

      // Zyrtec only has 8 units
      expect(
        () => db.productsDao.deductStockFefo(
          pharmacyUid: zyrtec.pharmacyUid,
          productId: zyrtec.id,
          requestedQuantity: 999,
        ),
        throwsA(isA<InsufficientStockException>()),
      );
    });
  });

  group('Financial Reporting & Sales KPI Tests', () {
    test('getKpiSummary calculates revenue, costs, and gross profit accurately', () async {
      await seeder.seedIfEmpty();

      final settings = await db.select(db.pharmacySettingsTable).getSingle();
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 1));
      final end = now.add(const Duration(days: 1));

      final summary = await db.salesDao.getKpiSummary(settings.pharmacyUid, start, end);
      expect(summary.totalInvoices, equals(1));
      expect(summary.grossRevenue, equals(11.50));
      expect(summary.totalCostPrice, equals(6.40));
      expect(summary.grossProfit, equals(5.10));
    });
  });
}

