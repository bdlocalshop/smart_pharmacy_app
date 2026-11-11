import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/backup_manager.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/core/network/api_client.dart';
import 'package:smart_pharmacy_app/core/network/cloud_license_service.dart';
import 'package:smart_pharmacy_app/core/services/device_info_service.dart';
import 'package:smart_pharmacy_app/core/services/secure_storage_service.dart';
import 'package:smart_pharmacy_app/features/auth/data/auth_repository.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_session.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/views/database_backups_view.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/views/main_app_shell.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:smart_pharmacy_app/features/pos/presentation/controllers/pos_controller.dart';

class MockCloudLicenseService extends CloudLicenseService {
  final OwnerVerificationResult Function(String identifier, String password)?
  onVerify;

  MockCloudLicenseService({
    required super.apiClient,
    required super.secureStorage,
    required super.deviceInfo,
    this.onVerify,
  });

  @override
  Future<OwnerVerificationResult> verifyOwnerCredentials({
    required String identifier,
    required String password,
  }) async {
    if (onVerify != null) {
      return onVerify!(identifier, password);
    }
    return const OwnerVerificationResult(
      success: false,
      message: 'Default failure',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late InMemorySecureStorageClient storageClient;
  late SecureStorageService secureStorage;
  late DeviceInfoService deviceInfo;
  late Directory tempBackupDir;
  late Directory backupDir;
  late DatabaseBackupManager backupManager;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storageClient = InMemorySecureStorageClient();
    secureStorage = SecureStorageService(storageClient);
    deviceInfo = DeviceInfoService(secureStorage);

    tempBackupDir = Directory.systemTemp.createTempSync('unbound_backup_test_');
    backupDir = Directory('${tempBackupDir.path}/backups')..createSync();
    File('${backupDir.path}/backup_smart_pharmacy_20261108_120000.sqlite')
        .writeAsStringSync('dummy sqlite content');
    backupManager = DatabaseBackupManager(
      customBackupDir: backupDir,
      customDbFile: File('${tempBackupDir.path}/test.sqlite'),
    );
  });

  tearDown(() async {
    await db.close();
    if (tempBackupDir.existsSync()) {
      tempBackupDir.deleteSync(recursive: true);
    }
  });

  group('Unbound Owner Login Flow Tests', () {
    test('Owner logging in on new device verifies online, sets local DB, and creates unbound session', () async {
      final mockCloud = MockCloudLicenseService(
        apiClient: ApiClient(),
        secureStorage: secureStorage,
        deviceInfo: deviceInfo,
        onVerify: (ident, pass) {
          if (ident == 'owner@bismillah.com' && pass == 'correct_pass_123') {
            return const OwnerVerificationResult(
              success: true,
              isCallingDeviceBound: false, // Unbound machine
              pharmacy: {
                'id': 'pharm_123',
                'pharmacy_name': 'Bismillah Pharmacy & Healthcare',
                'trade_license_number': 'TRAD-9988',
                'pharmacy_phone': '+880 1717-000000',
                'pharmacy_address': 'Dhaka, Bangladesh',
              },
              owner: {
                'name': 'Ali Reza',
                'email': 'owner@bismillah.com',
                'phone': '+880 1717-000000',
              },
              licenseSummary: {
                'has_license': true,
                'license_key': 'PHARMA-TEST-KEY',
              },
            );
          }
          return const OwnerVerificationResult(
            success: false,
            message: 'Invalid credentials',
          );
        },
      );

      final authRepo = AuthRepository(
        db: db,
        secureStorage: secureStorage,
        cloudLicenseService: mockCloud,
      );

      // Verify DB is initially empty
      expect(await authRepo.isPharmacyConfigured(), isFalse);

      // Perform Owner login from new machine
      final session = await authRepo.login(
        username: 'owner@bismillah.com',
        password: 'correct_pass_123',
      );

      // Verify Session properties
      expect(session.fullName, equals('Ali Reza'));
      expect(session.role, equals(UserRole.owner));
      expect(session.pharmacyName, equals('Bismillah Pharmacy & Healthcare'));
      expect(session.isDeviceBound, isFalse); // Must be unbound!

      // Verify Local SQLite DB was populated
      expect(await authRepo.isPharmacyConfigured(), isTrue);
      final settings = await authRepo.getPharmacySettings();
      expect(settings?.pharmacyName, equals('Bismillah Pharmacy & Healthcare'));
      expect(settings?.licenseNumber, equals('TRAD-9988'));

      // Verify persistent session restored retains isDeviceBound: false
      final restored = await authRepo.restoreSession();
      expect(restored?.isDeviceBound, isFalse);
    });

    test('UserSession serialization correctly retains isDeviceBound state', () {
      final unboundSession = UserSession(
        userId: 'u1',
        username: 'owner',
        fullName: 'Owner Name',
        role: UserRole.owner,
        pharmacyUid: 'p1',
        pharmacyName: 'My Pharmacy',
        currencySymbol: '৳',
        token: 'token123',
        loginTimestamp: DateTime.now(),
        isDeviceBound: false,
      );

      final jsonStr = unboundSession.toJson();
      final restored = UserSession.fromJson(jsonStr);
      expect(restored.isDeviceBound, isFalse);

      final boundSession = unboundSession.copyWith(isDeviceBound: true);
      expect(boundSession.isDeviceBound, isTrue);
    });
  });

  group('Unbound Machine UI Restrictions Widget Tests', () {
    testWidgets(
      'MainAppShell disables POS Billing and displays Device Unbound pill',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final unboundSession = UserSession(
          userId: 'u_owner',
          username: 'owner',
          fullName: 'Ali Reza',
          role: UserRole.owner,
          pharmacyUid: 'p_test',
          pharmacyName: 'Bismillah Pharmacy',
          currencySymbol: '৳',
          token: 'tok_1',
          loginTimestamp: DateTime.now(),
          isDeviceBound: false, // Unbound machine
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              currentUserSessionProvider.overrideWithValue(unboundSession),
              currentUserRoleProvider.overrideWithValue(UserRole.owner),
              posSearchResultsProvider.overrideWith(
                (ref) => const Stream.empty(),
              ),
              productsWithStockProvider.overrideWith((ref) => Stream.value([])),
            ],
            child: const MaterialApp(home: MainAppShell()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Top bar must show "Device Unbound"
        expect(find.text('Device Unbound'), findsOneWidget);
        expect(find.text('Cloud Sync Active'), findsNothing);

        // POS Billing menu item should have LOCK tag
        expect(find.text('LOCK'), findsOneWidget);
        expect(find.text('Inactive (Unbound Device)'), findsOneWidget);

        // Default active tab should be Medicine Master (index 1), not POS Billing
        expect(find.text('Medicine Master Catalog'), findsOneWidget);

        // Tap POS Billing in sidebar: should show SnackBar and remain blocked
        await tester.tap(find.text('POS Billing'));
        await tester.pump();

        expect(
          find.textContaining('POS Billing is inactive on unbound devices'),
          findsOneWidget,
        );

        // Other sections like Backups & Restore must be accessible
        expect(find.text('Backups & Restore'), findsOneWidget);

        // Dismiss snackbar
        ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
            .hideCurrentSnackBar();
        await tester.pump();
      },
    );

    testWidgets(
      'DatabaseBackupsView disables Cloud Upload icon on unbound device',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final unboundSession = UserSession(
          userId: 'u_owner',
          username: 'owner',
          fullName: 'Ali Reza',
          role: UserRole.owner,
          pharmacyUid: 'p_test',
          pharmacyName: 'Bismillah Pharmacy',
          currencySymbol: '৳',
          token: 'tok_1',
          loginTimestamp: DateTime.now(),
          isDeviceBound: false, // Unbound machine
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              currentUserSessionProvider.overrideWithValue(unboundSession),
              currentUserRoleProvider.overrideWithValue(UserRole.owner),
              backupManagerProvider.overrideWithValue(backupManager),
              secureStorageServiceProvider.overrideWithValue(secureStorage),
            ],
            child: const MaterialApp(
              home: Scaffold(body: DatabaseBackupsView()),
            ),
          ),
        );

        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 300));
        });
        await tester.pump();

        expect(find.text('Export Immediate Backup (.sqlite)'), findsOneWidget);
        expect(find.text('Restore Database Archive'), findsOneWidget);
        expect(find.text('Activate License'), findsOneWidget);
        expect(find.text('Inventory Search'), findsOneWidget);

        // Verify Cloud Upload icon tooltip indicates disabled on unbound device
        expect(
          find.byTooltip(
            'Cloud upload is inactive on unbound devices. Please activate license to bind this machine.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
