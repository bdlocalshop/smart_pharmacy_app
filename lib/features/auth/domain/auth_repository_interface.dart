import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'user_role.dart';
import 'user_session.dart';

/// Contract for local authentication and user session management.
abstract class IAuthRepository {
  /// Checks if pharmacy settings have been configured (onboarding status).
  Future<bool> isPharmacyConfigured();

  /// Gets current pharmacy settings record.
  Future<PharmacySetting?> getPharmacySettings();

  /// Executes first-run onboarding setup: generates pharmacy_uid and creates master Owner.
  Future<UserSession> setupInitialPharmacy({
    required String pharmacyName,
    required String contactPhone,
    String? licenseNumber,
    String? address,
    String currencySymbol = '৳',
    required String ownerFullName,
    required String ownerUsername,
    required String ownerPassword,
  });

  /// Authenticates user against local SQLite database with salted hash verification.
  Future<UserSession> login({
    required String username,
    required String password,
  });

  /// Restores active session from persistent desktop storage.
  /// Validates that the cached user is still active in SQLite.
  Future<UserSession?> restoreSession();

  /// Explicit logout: clears persistent storage cache.
  Future<void> logout();

  /// Registers a new staff member (Owner only).
  Future<User> registerUser({
    required String pharmacyUid,
    required String fullName,
    required String username,
    required String password,
    required UserRole role,
    String? phone,
  });

  /// Updates an existing staff member's details (Owner only).
  Future<User> updateUser({
    required String userId,
    required String fullName,
    required String username,
    required UserRole role,
    String? phone,
    String? newPassword,
    bool? isActive,
  });

  /// Fetches all users for the current pharmacy.
  Future<List<User>> getUsers(String pharmacyUid);

  /// Toggles user active state (activate/deactivate).
  Future<void> setUserActiveState(String userId, bool isActive);
}

