import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_pharmacy_app/core/constants/app_constants.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/errors/exceptions.dart';
import 'package:smart_pharmacy_app/core/services/secure_storage_service.dart';
import 'package:smart_pharmacy_app/core/utils/password_hasher.dart';
import '../domain/auth_repository_interface.dart';
import '../domain/user_role.dart';
import '../domain/user_session.dart';

/// Concrete implementation of authentication and staff management.
class AuthRepository implements IAuthRepository {
  final AppDatabase db;
  final SecureStorageService secureStorage;
  static const _uuid = Uuid();

  AuthRepository({
    required this.db,
    required this.secureStorage,
  });

  @override
  Future<bool> isPharmacyConfigured() async {
    final settings = await db.select(db.pharmacySettingsTable).get();
    if (settings.isEmpty) return false;
    final users = await (db.select(db.usersTable)..where((tbl) => tbl.deletedAt.isNull())).get();
    return users.isNotEmpty;
  }

  @override
  Future<PharmacySetting?> getPharmacySettings() async {
    return db.select(db.pharmacySettingsTable).getSingleOrNull();
  }

  @override
  Future<UserSession> setupInitialPharmacy({
    required String pharmacyName,
    required String contactPhone,
    String? licenseNumber,
    required String address,
    String? mapPinUrl,
    String currencySymbol = AppConstants.defaultCurrencySymbol,
    required String ownerFullName,
    String? ownerPhone,
    required String ownerUsername,
    required String ownerPassword,
  }) async {
    final existingSettings = await getPharmacySettings();
    final existingUsers = await (db.select(db.usersTable)..where((tbl) => tbl.deletedAt.isNull())).get();
    if (existingSettings != null && existingUsers.isNotEmpty) {
      throw AppException('Pharmacy has already been initialized on this device.');
    }

    final trimmedUsername = ownerUsername.trim().toLowerCase();
    if (trimmedUsername.isEmpty) {
      throw AppException('Owner username cannot be empty.');
    }
    if (ownerPassword.length < 6) {
      throw AppException('Owner password must be at least 6 characters.');
    }

    final pharmacyUid = existingSettings?.pharmacyUid ?? _uuid.v4();
    final ownerId = _uuid.v4();
    final now = DateTime.now();
    final passwordHash = PasswordHasher.hashPassword(ownerPassword);

    await db.transaction(() async {
      // 1. Insert or Update Pharmacy Settings
      if (existingSettings == null) {
        await db.into(db.pharmacySettingsTable).insert(
              PharmacySettingsTableCompanion(
                pharmacyUid: Value(pharmacyUid),
                pharmacyName: Value(pharmacyName.trim()),
                licenseNumber: Value(licenseNumber?.trim()),
                contactPhone: Value(contactPhone.trim()),
                address: Value(address.trim()),
                mapPinUrl: Value(mapPinUrl?.trim()),
                currencySymbol: Value(currencySymbol.trim()),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
      } else {
        await (db.update(db.pharmacySettingsTable)
              ..where((tbl) => tbl.pharmacyUid.equals(pharmacyUid)))
            .write(
          PharmacySettingsTableCompanion(
            pharmacyName: Value(pharmacyName.trim()),
            licenseNumber: Value(licenseNumber?.trim()),
            contactPhone: Value(contactPhone.trim()),
            address: Value(address.trim()),
            mapPinUrl: Value(mapPinUrl?.trim()),
            currencySymbol: Value(currencySymbol.trim()),
            updatedAt: Value(now),
          ),
        );
      }

      // 2. Insert Master Owner User
      await db.into(db.usersTable).insert(
            UsersTableCompanion(
              id: Value(ownerId),
              pharmacyUid: Value(pharmacyUid),
              fullName: Value(ownerFullName.trim()),
              phone: Value(ownerPhone?.trim()),
              username: Value(trimmedUsername),
              passwordHash: Value(passwordHash),
              role: const Value(AppConstants.roleOwner),
              isActive: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
              syncStatus: const Value(AppConstants.syncSynced),
            ),
          );
    });

    final session = UserSession(
      userId: ownerId,
      username: trimmedUsername,
      fullName: ownerFullName.trim(),
      role: UserRole.owner,
      pharmacyUid: pharmacyUid,
      pharmacyName: pharmacyName.trim(),
      currencySymbol: currencySymbol.trim(),
      token: _uuid.v4(),
      loginTimestamp: now,
    );

    // Save persistent desktop session
    await secureStorage.saveSession(session);
    return session;
  }

  @override
  Future<UserSession> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
    final user = await (db.select(db.usersTable)
          ..where((tbl) => tbl.username.equals(trimmedUsername) & tbl.deletedAt.isNull()))
        .getSingleOrNull();

    if (user == null) {
      throw AppException('Invalid username or password.');
    }

    if (!user.isActive) {
      throw AppException('This account has been deactivated. Contact the Administrator.');
    }

    final isCorrectPassword = PasswordHasher.verifyPassword(password, user.passwordHash);
    if (!isCorrectPassword) {
      throw AppException('Invalid username or password.');
    }

    final pharmacy = await (db.select(db.pharmacySettingsTable)
          ..where((tbl) => tbl.pharmacyUid.equals(user.pharmacyUid)))
        .getSingleOrNull();

    final session = UserSession(
      userId: user.id,
      username: user.username,
      fullName: user.fullName,
      role: UserRole.fromCode(user.role),
      pharmacyUid: user.pharmacyUid,
      pharmacyName: pharmacy?.pharmacyName ?? 'Smart Pharmacy',
      currencySymbol: pharmacy?.currencySymbol ?? AppConstants.defaultCurrencySymbol,
      token: _uuid.v4(),
      loginTimestamp: DateTime.now(),
    );

    await secureStorage.saveSession(session);
    return session;
  }

  @override
  Future<UserSession?> restoreSession() async {
    final cachedSession = await secureStorage.getSession();
    if (cachedSession == null) return null;

    // Validate that user still exists and is currently active in SQLite
    final user = await (db.select(db.usersTable)
          ..where((tbl) => tbl.id.equals(cachedSession.userId) & tbl.deletedAt.isNull()))
        .getSingleOrNull();

    if (user == null || !user.isActive) {
      // User was deactivated or deleted while offline: revoke session
      await secureStorage.clearSession();
      return null;
    }

    final pharmacy = await (db.select(db.pharmacySettingsTable)
          ..where((tbl) => tbl.pharmacyUid.equals(user.pharmacyUid)))
        .getSingleOrNull();

    return cachedSession.copyWith(
      fullName: user.fullName,
      role: UserRole.fromCode(user.role),
      pharmacyName: pharmacy?.pharmacyName ?? cachedSession.pharmacyName,
      currencySymbol: pharmacy?.currencySymbol ?? cachedSession.currencySymbol,
    );
  }

  @override
  Future<void> logout() async {
    await secureStorage.clearSession();
  }

  @override
  Future<User> registerUser({
    required String pharmacyUid,
    required String fullName,
    required String username,
    required String password,
    required UserRole role,
    String? phone,
  }) async {
    final trimmedUsername = username.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
    if (trimmedUsername.isEmpty) {
      throw AppException('Username cannot be empty.');
    }

    final existing = await (db.select(db.usersTable)
          ..where((tbl) => tbl.username.equals(trimmedUsername) & tbl.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      throw AppException('Username "$trimmedUsername" is already taken.');
    }

    if (password.length < 6) {
      throw AppException('Password must be at least 6 characters long.');
    }

    final id = _uuid.v4();
    final now = DateTime.now();
    final passwordHash = PasswordHasher.hashPassword(password);
    final cleanPhone = phone?.trim();

    await db.into(db.usersTable).insert(
          UsersTableCompanion(
            id: Value(id),
            pharmacyUid: Value(pharmacyUid),
            fullName: Value(fullName.trim()),
            username: Value(trimmedUsername),
            passwordHash: Value(passwordHash),
            role: Value(role.code),
            phone: Value(cleanPhone == null || cleanPhone.isEmpty ? null : cleanPhone),
            isActive: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value(AppConstants.syncPendingInsert),
          ),
        );

    return (db.select(db.usersTable)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  @override
  Future<User> updateUser({
    required String userId,
    required String fullName,
    required String username,
    required UserRole role,
    String? phone,
    String? newPassword,
    bool? isActive,
  }) async {
    final trimmedUsername = username.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
    if (trimmedUsername.isEmpty) {
      throw AppException('Username cannot be empty.');
    }

    // Check username uniqueness if changed
    final existing = await (db.select(db.usersTable)
          ..where((tbl) => tbl.username.equals(trimmedUsername) & tbl.id.isNotValue(userId) & tbl.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      throw AppException('Username "$trimmedUsername" is already in use by another user.');
    }

    final now = DateTime.now();
    final cleanPhone = phone?.trim();

    String? newHash;
    if (newPassword != null && newPassword.trim().isNotEmpty) {
      if (newPassword.trim().length < 6) {
        throw AppException('New password must be at least 6 characters long.');
      }
      newHash = PasswordHasher.hashPassword(newPassword.trim());
    }

    await (db.update(db.usersTable)..where((tbl) => tbl.id.equals(userId))).write(
      UsersTableCompanion(
        fullName: Value(fullName.trim()),
        username: Value(trimmedUsername),
        role: Value(role.code),
        phone: Value(cleanPhone == null || cleanPhone.isEmpty ? null : cleanPhone),
        passwordHash: newHash != null ? Value(newHash) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(now),
        syncStatus: const Value(AppConstants.syncPendingUpdate),
      ),
    );

    return (db.select(db.usersTable)..where((tbl) => tbl.id.equals(userId))).getSingle();
  }

  @override
  Future<List<User>> getUsers(String pharmacyUid) {
    return (db.select(db.usersTable)
          ..where((tbl) => tbl.pharmacyUid.equals(pharmacyUid) & tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.role, mode: OrderingMode.asc),
            (tbl) => OrderingTerm(expression: tbl.fullName, mode: OrderingMode.asc),
          ]))
        .get();
  }

  @override
  Future<void> setUserActiveState(String userId, bool isActive) async {
    await (db.update(db.usersTable)..where((tbl) => tbl.id.equals(userId))).write(
      UsersTableCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(AppConstants.syncPendingUpdate),
      ),
    );
  }
}
