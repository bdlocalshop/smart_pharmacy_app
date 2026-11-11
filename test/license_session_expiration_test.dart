import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/backup_manager.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/core/database/seed_data.dart';
import 'package:smart_pharmacy_app/core/localization/app_strings.dart';
import 'package:smart_pharmacy_app/core/localization/language_controller.dart';
import 'package:smart_pharmacy_app/core/services/secure_storage_service.dart';
import 'package:smart_pharmacy_app/features/auth/data/auth_repository.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/views/database_backups_view.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/views/reports_view.dart';

class _MockLanguageNotifier extends LanguageNotifier {
  final AppLanguage initial;
  _MockLanguageNotifier(this.initial);

  @override
  AppLanguage build() => initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService License Session Storage Tests', () {
    late InMemorySecureStorageClient mockClient;
    late SecureStorageService storage;

    setUp(() {
      mockClient = InMemorySecureStorageClient();
      storage = SecureStorageService(mockClient);
    });

    test('stores and retrieves license validity and days remaining', () async {
      final expiry = DateTime.now().add(const Duration(days: 15));
      await storage.saveLicenseSession(
        validUntil: expiry,
        daysRemaining: 15,
        status: 'ACTIVE',
      );

      final retrievedDate = await storage.getLicenseValidUntil();
      final retrievedDays = await storage.getLicenseDaysRemaining();
      final retrievedStatus = await storage.getLicenseStatus();

      expect(retrievedDate, isNotNull);
      expect(retrievedDays, equals(15));
      expect(retrievedStatus, equals('ACTIVE'));
      expect(await storage.isLicenseSessionExpired(), isFalse);
    });

    test('isLicenseSessionExpired returns true when validUntil is in the past', () async {
      final pastExpiry = DateTime.now().subtract(const Duration(days: 2));
      await storage.saveLicenseSession(
        validUntil: pastExpiry,
        daysRemaining: 0,
        status: 'ACTIVE',
      );

      expect(await storage.isLicenseSessionExpired(), isTrue);
    });

    test('isLicenseSessionExpired returns true when status is EXPIRED', () async {
      await storage.saveLicenseSession(
        validUntil: DateTime.now().add(const Duration(days: 5)),
        daysRemaining: 5,
        status: 'EXPIRED',
      );

      expect(await storage.isLicenseSessionExpired(), isTrue);
    });

    test('isLicenseSessionExpired returns true when daysRemaining is 0 or negative', () async {
      await storage.saveLicenseSession(
        validUntil: null,
        daysRemaining: 0,
        status: 'ACTIVE',
      );

      expect(await storage.isLicenseSessionExpired(), isTrue);
    });
  });

  group('AuthRepository Login Expiration Handling Tests', () {
    late AppDatabase db;
    late InMemorySecureStorageClient mockStorage;
    late SecureStorageService secureStorage;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();

      mockStorage = InMemorySecureStorageClient();
      secureStorage = SecureStorageService(mockStorage);
    });

    tearDown(() async {
      await db.close();
    });

    test('login succeeds and tags session as expired when local info is expired without kicking user out', () async {
      // Set expired session locally
      await secureStorage.saveLicenseSession(
        validUntil: DateTime.now().subtract(const Duration(days: 5)),
        daysRemaining: 0,
        status: 'EXPIRED',
      );

      final authRepo = AuthRepository(
        db: db,
        secureStorage: secureStorage,
      );

      // Login as admin
      final session = await authRepo.login(
        username: 'admin',
        password: 'admin123',
      );

      expect(session, isNotNull);
      expect(session.username, equals('admin'));
      expect(session.isLicenseExpired, isTrue);

      // Session in storage must also retain expired state
      final savedSession = await secureStorage.getSession();
      expect(savedSession?.isLicenseExpired, isTrue);
    });

    test('login retains active license when local info is not expired', () async {
      await secureStorage.saveLicenseSession(
        validUntil: DateTime.now().add(const Duration(days: 20)),
        daysRemaining: 20,
        status: 'ACTIVE',
      );

      final authRepo = AuthRepository(
        db: db,
        secureStorage: secureStorage,
      );

      final session = await authRepo.login(
        username: 'admin',
        password: 'admin123',
      );

      expect(session.isLicenseExpired, isFalse);
    });
  });

  group('Financial & Profit Report Expiration Restriction Widget Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      final seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();
    });

    tearDown(() async {
      await db.close();
    });

    UserSession createTestSession({required bool isLicenseExpired}) {
      return UserSession(
        userId: 'owner-id',
        username: 'owner',
        fullName: 'Owner User',
        role: UserRole.owner,
        pharmacyUid: 'pharmacy-main-001',
        pharmacyName: 'Bismillah Pharmacy',
        currencySymbol: '৳',
        token: 'test-token',
        loginTimestamp: DateTime.now(),
        isLicenseExpired: isLicenseExpired,
      );
    }

    testWidgets('Tapping non-today period chips displays license validation warning when expired', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final expiredSession = createTestSession(isLicenseExpired: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            currentUserSessionProvider.overrideWithValue(expiredSession),
            appLanguageProvider.overrideWith(() => _MockLanguageNotifier(AppLanguage.en)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Today chip should be present
      expect(find.text('Today'), findsOneWidget);

      // Tap 'Yesterday' chip
      final yesterdayChip = find.text('Yesterday');
      expect(yesterdayChip, findsOneWidget);
      await tester.tap(yesterdayChip);
      await tester.pumpAndSettle();

      // Dialog must popup with the exact message requested
      expect(find.text('Please update your license validation time'), findsOneWidget);
      expect(find.text('License Validation Required'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('Displays license validation warning in Bangla when language is set to BN', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final expiredSession = createTestSession(isLicenseExpired: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            currentUserSessionProvider.overrideWithValue(expiredSession),
            appLanguageProvider.overrideWith(() => _MockLanguageNotifier(AppLanguage.bn)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ReportsView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'গতকাল' (Yesterday) chip
      await tester.tap(find.text('গতকাল'));
      await tester.pumpAndSettle();

      // Must display Bengali notification
      expect(find.text('অনুগ্রহ করে আপনার লাইসেন্স যাচাইকরণের মেয়াদ আপডেট করুন'), findsOneWidget);
      expect(find.text('লাইসেন্স যাচাইকরণ প্রয়োজন'), findsOneWidget);
    });
  });

  group('Database Backups View Expiration Restriction Widget Tests', () {
    late Directory tempDir;
    late Directory backupDir;
    late File dbFile;
    late AppDatabase db;
    late DatabaseBackupManager backupManager;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('backup_exp_test_');
      backupDir = Directory(p.join(tempDir.path, 'backups'))..createSync();
      dbFile = File(p.join(tempDir.path, 'test_db.sqlite'));

      db = AppDatabase(NativeDatabase(dbFile));
      final seeder = DatabaseSeeder(db);
      await seeder.seedIfEmpty();

      // Create a dummy backup archive
      final testBackup = File(p.join(backupDir.path, 'backup_smart_pharmacy_20261111_010000.sqlite'));
      await testBackup.writeAsString('mock sqlite backup content');

      backupManager = DatabaseBackupManager(
        customBackupDir: backupDir,
        customDbFile: dbFile,
      );
    });

    tearDown(() async {
      try {
        await db.close();
      } catch (_) {}
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets('Tapping Inventory Search or Cloud Upload on expired license displays warning popup', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final expiredSession = UserSession(
        userId: 'owner-id',
        username: 'owner',
        fullName: 'Owner User',
        role: UserRole.owner,
        pharmacyUid: 'pharmacy-main-001',
        pharmacyName: 'Bismillah Pharmacy',
        currencySymbol: '৳',
        token: 'test-token',
        loginTimestamp: DateTime.now(),
        isDeviceBound: true,
        isLicenseExpired: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            backupManagerProvider.overrideWithValue(backupManager),
            currentUserSessionProvider.overrideWithValue(expiredSession),
            appLanguageProvider.overrideWith(() => _MockLanguageNotifier(AppLanguage.en)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DatabaseBackupsView(),
            ),
          ),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // 1. Verify Inventory Search button click shows popup
      final inventorySearchBtn = find.widgetWithText(OutlinedButton, 'Inventory Search');
      expect(inventorySearchBtn, findsOneWidget);
      await tester.tap(inventorySearchBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Please update your license validation time'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 2. Verify Cloud Upload icon button click shows popup
      final cloudUploadIcon = find.byIcon(Icons.cloud_upload_outlined);
      expect(cloudUploadIcon, findsOneWidget);
      await tester.tap(cloudUploadIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Please update your license validation time'), findsOneWidget);
    });
  });
}

