import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/errors/exceptions.dart';
import 'package:smart_pharmacy_app/core/services/secure_storage_service.dart';
import 'package:smart_pharmacy_app/core/utils/password_hasher.dart';
import 'package:smart_pharmacy_app/features/auth/data/auth_repository.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';

void main() {
  late AppDatabase db;
  late InMemorySecureStorageClient storageClient;
  late SecureStorageService secureStorage;
  late AuthRepository authRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storageClient = InMemorySecureStorageClient();
    secureStorage = SecureStorageService(storageClient);
    authRepo = AuthRepository(db: db, secureStorage: secureStorage);
  });

  tearDown(() async {
    await db.close();
  });

  group('PasswordHasher Tests', () {
    test('Hashes passwords securely with random salt and verifies match', () {
      const password = 'StrongPassword123!';
      final hash1 = PasswordHasher.hashPassword(password);
      final hash2 = PasswordHasher.hashPassword(password);

      // Two hashes with different random salts must differ
      expect(hash1, isNot(equals(hash2)));
      expect(hash1.startsWith('\$'), isTrue);

      expect(PasswordHasher.verifyPassword(password, hash1), isTrue);
      expect(PasswordHasher.verifyPassword(password, hash2), isTrue);
      expect(PasswordHasher.verifyPassword('WrongPassword', hash1), isFalse);
    });
  });

  group('AuthRepository Initial Setup & Persistent Session Tests', () {
    test('isPharmacyConfigured returns false initially, then true after setup', () async {
      expect(await authRepo.isPharmacyConfigured(), isFalse);

      final session = await authRepo.setupInitialPharmacy(
        pharmacyName: 'City Central Pharmacy',
        contactPhone: '+1-555-0100',
        licenseNumber: 'LIC-2026',
        address: '742 Evergreen Terrace, Medical District',
        mapPinUrl: 'https://maps.google.com/?q=23.8103,90.4125',
        ownerFullName: 'Dr. John Doe',
        ownerPhone: '+1-555-PERSONAL',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      expect(session.username, equals('admin'));
      expect(session.role, equals(UserRole.owner));
      expect(session.pharmacyUid.isNotEmpty, isTrue);

      expect(await authRepo.isPharmacyConfigured(), isTrue);

      // Verify persistent session was saved to secure storage
      final storedSession = await secureStorage.getSession();
      expect(storedSession, isNotNull);
      expect(storedSession!.userId, equals(session.userId));

      // Verify owner personal phone is recorded in usersTable
      final userRecord = await (db.select(db.usersTable)..where((u) => u.id.equals(session.userId))).getSingle();
      expect(userRecord.phone, equals('+1-555-PERSONAL'));
      expect(storedSession.role, equals(UserRole.owner));

      // Verify address and mapPinUrl in pharmacySettingsTable
      final pharmacyRecord = await authRepo.getPharmacySettings();
      expect(pharmacyRecord, isNotNull);
      expect(pharmacyRecord!.address, equals('742 Evergreen Terrace, Medical District'));
      expect(pharmacyRecord.mapPinUrl, equals('https://maps.google.com/?q=23.8103,90.4125'));
    });

    test('setupInitialPharmacy rejects subsequent setup calls (idempotent)', () async {
      await authRepo.setupInitialPharmacy(
        pharmacyName: 'First Pharmacy',
        contactPhone: '+1-555-0100',
        address: 'First St',
        ownerFullName: 'Dr. John Doe',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      expect(
        () => authRepo.setupInitialPharmacy(
          pharmacyName: 'Second Pharmacy',
          contactPhone: '+1-555-0200',
          address: 'Second St',
          ownerFullName: 'Another Owner',
          ownerUsername: 'owner2',
          ownerPassword: 'password123',
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('login authenticates valid user and stores session in secure storage', () async {
      await authRepo.setupInitialPharmacy(
        pharmacyName: 'City Central Pharmacy',
        contactPhone: '+1-555-0100',
        address: 'Main St',
        ownerFullName: 'Dr. John Doe',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      // Clear storage to simulate fresh boot after explicit logout
      await secureStorage.clearSession();
      expect(await secureStorage.getSession(), isNull);

      final session = await authRepo.login(
        username: 'admin',
        password: 'adminPassword123',
      );

      expect(session.username, equals('admin'));
      expect(session.role, equals(UserRole.owner));

      // Verify secure storage now has the session
      final cached = await secureStorage.getSession();
      expect(cached, isNotNull);
      expect(cached!.userId, equals(session.userId));
    });

    test('login rejects incorrect password and non-existent username', () async {
      await authRepo.setupInitialPharmacy(
        pharmacyName: 'City Central Pharmacy',
        contactPhone: '+1-555-0100',
        address: 'Main St',
        ownerFullName: 'Dr. John Doe',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      expect(
        () => authRepo.login(username: 'admin', password: 'wrongPassword'),
        throwsA(isA<AppException>()),
      );

      expect(
        () => authRepo.login(username: 'unknown_user', password: 'password123'),
        throwsA(isA<AppException>()),
      );
    });

    test('restoreSession restores active session and revokes if user was deactivated', () async {
      final initialSession = await authRepo.setupInitialPharmacy(
        pharmacyName: 'City Central Pharmacy',
        contactPhone: '+1-555-0100',
        address: 'Main St',
        ownerFullName: 'Dr. John Doe',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      // Register a salesman
      final salesman = await authRepo.registerUser(
        pharmacyUid: initialSession.pharmacyUid,
        fullName: 'Alex Rivera',
        username: 'salesman',
        password: 'salesPassword123',
        role: UserRole.salesman,
      );

      // Salesman logs in
      final salesSession = await authRepo.login(
        username: 'salesman',
        password: 'salesPassword123',
      );
      expect(salesSession.role, equals(UserRole.salesman));

      // Simulate app restart: restoreSession reads from secure storage
      final restored = await authRepo.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.username, equals('salesman'));
      expect(restored.role, equals(UserRole.salesman));

      // Now deactivate salesman in SQLite
      await authRepo.setUserActiveState(salesman.id, false);

      // Subsequent restoreSession must reject deactivated user and purge storage
      final restoredAfterDeactivation = await authRepo.restoreSession();
      expect(restoredAfterDeactivation, isNull);
      expect(await secureStorage.getSession(), isNull);
    });

    test('logout clears persistent secure storage session', () async {
      await authRepo.setupInitialPharmacy(
        pharmacyName: 'City Central Pharmacy',
        contactPhone: '+1-555-0100',
        address: 'Main St',
        ownerFullName: 'Dr. John Doe',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      expect(await secureStorage.hasSession(), isTrue);

      await authRepo.logout();

      expect(await secureStorage.hasSession(), isFalse);
      expect(await authRepo.restoreSession(), isNull);
    });

    test('registerUser and updateUser support phone numbers, password updates, and login validation', () async {
      final initialSession = await authRepo.setupInitialPharmacy(
        pharmacyName: 'City Central Pharmacy',
        contactPhone: '+1-555-0100',
        address: 'Main St',
        ownerFullName: 'Dr. John Doe',
        ownerUsername: 'admin',
        ownerPassword: 'adminPassword123',
      );

      // 1. Register new staff user with phone number and '@' in username
      final newUser = await authRepo.registerUser(
        pharmacyUid: initialSession.pharmacyUid,
        fullName: 'Ali Reza',
        username: '@reza',
        password: 'password123',
        role: UserRole.salesman,
        phone: '+880 1717-449639',
      );

      expect(newUser.fullName, equals('Ali Reza'));
      expect(newUser.username, equals('reza')); // Leading @ normalized
      expect(newUser.phone, equals('+880 1717-449639'));
      expect(newUser.isActive, isTrue);

      // 2. New user can log in with proper credentials (using 'reza' or '@reza')
      final session1 = await authRepo.login(username: 'reza', password: 'password123');
      expect(session1.fullName, equals('Ali Reza'));
      expect(session1.role, equals(UserRole.salesman));

      final session2 = await authRepo.login(username: '@reza', password: 'password123');
      expect(session2.fullName, equals('Ali Reza'));

      // 3. Owner updates user details: promoted to manager, new phone, and new password
      final updatedUser = await authRepo.updateUser(
        userId: newUser.id,
        fullName: 'Ali Reza (Senior)',
        username: 'reza_mgr',
        role: UserRole.manager,
        phone: '+880 1717-999888',
        newPassword: 'newManagerPass123',
      );

      expect(updatedUser.fullName, equals('Ali Reza (Senior)'));
      expect(updatedUser.username, equals('reza_mgr'));
      expect(updatedUser.role, equals(UserRole.manager.code));
      expect(updatedUser.phone, equals('+880 1717-999888'));

      // 4. Log in with updated credentials
      final managerSession = await authRepo.login(username: 'reza_mgr', password: 'newManagerPass123');
      expect(managerSession.role, equals(UserRole.manager));

      // Old password must fail
      expect(
        () => authRepo.login(username: 'reza_mgr', password: 'password123'),
        throwsA(isA<AppException>()),
      );
    });
  });
}

