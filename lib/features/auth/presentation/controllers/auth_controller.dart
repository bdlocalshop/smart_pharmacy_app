import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/database/database_provider.dart';
import 'package:smart_pharmacy_app/core/services/secure_storage_service.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_repository_interface.dart';
import '../../domain/user_role.dart';
import '../../domain/user_session.dart';

/// Secure storage provider.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Auth repository provider.
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(db: db, secureStorage: secureStorage);
});

enum AuthStatus {
  initial,
  loading,
  setupRequired,
  unauthenticated,
  authenticated,
}

class AuthState {
  final AuthStatus status;
  final UserSession? session;
  final PharmacySetting? pharmacySetting;
  final String? errorMessage;
  final bool isSubmitting;

  const AuthState({
    this.status = AuthStatus.initial,
    this.session,
    this.pharmacySetting,
    this.errorMessage,
    this.isSubmitting = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && session != null;
  bool get isSetupRequired => status == AuthStatus.setupRequired;
  UserRole? get role => session?.role;

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
    PharmacySetting? pharmacySetting,
    String? errorMessage,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      pharmacySetting: pharmacySetting ?? this.pharmacySetting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  IAuthRepository get _authRepo => ref.read(authRepositoryProvider);

  /// Checks database and persistent secure storage on application boot.
  Future<void> initializeAuth() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final isConfigured = await _authRepo.isPharmacyConfigured();

      if (!isConfigured) {
        state = state.copyWith(status: AuthStatus.setupRequired);
        return;
      }

      final pharmacy = await _authRepo.getPharmacySettings();

      // Check persistent session in desktop secure credentials manager
      final restoredSession = await _authRepo.restoreSession();

      if (restoredSession != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          session: restoredSession,
          pharmacySetting: pharmacy,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          pharmacySetting: pharmacy,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Failed to initialize session: $e',
      );
    }
  }

  /// Initial setup for first run: creates pharmacy tenant & Owner.
  Future<bool> setupInitialPharmacy({
    required String pharmacyName,
    required String contactPhone,
    String? licenseNumber,
    String? address,
    String currencySymbol = '\$',
    required String ownerFullName,
    required String ownerUsername,
    required String ownerPassword,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await _authRepo.setupInitialPharmacy(
        pharmacyName: pharmacyName,
        contactPhone: contactPhone,
        licenseNumber: licenseNumber,
        address: address,
        currencySymbol: currencySymbol,
        ownerFullName: ownerFullName,
        ownerUsername: ownerUsername,
        ownerPassword: ownerPassword,
      );

      final pharmacy = await _authRepo.getPharmacySettings();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        pharmacySetting: pharmacy,
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('AppException: ', ''),
      );
      return false;
    }
  }

  /// Logs in with local password verification and persists session.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await _authRepo.login(
        username: username,
        password: password,
      );

      final pharmacy = await _authRepo.getPharmacySettings();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        pharmacySetting: pharmacy,
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('AppException: ', ''),
      );
      return false;
    }
  }

  /// Explicit logout: revokes persistent desktop credentials.
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authRepo.logout();
    final pharmacy = await _authRepo.getPharmacySettings();
    state = AuthState(
      status: AuthStatus.unauthenticated,
      pharmacySetting: pharmacy,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

// Helper selector providers
final currentUserSessionProvider = Provider<UserSession?>((ref) {
  return ref.watch(authControllerProvider).session;
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authControllerProvider).role;
});

