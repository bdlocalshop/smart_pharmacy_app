import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/user_session.dart';

/// Secure storage wrapper interface to allow testing without desktop platform channels.
abstract class ISecureStorageClient {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class FlutterSecureStorageClient implements ISecureStorageClient {
  final FlutterSecureStorage _storage;

  FlutterSecureStorageClient([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
              wOptions: WindowsOptions(),
            );

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }
}

/// In-memory storage client for unit testing and headless environments.
class InMemorySecureStorageClient implements ISecureStorageClient {
  final Map<String, String> _data = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _data[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _data.remove(key);
  }
}

/// Service managing persistent desktop keychain session storage.
class SecureStorageService {
  final ISecureStorageClient _client;

  static const String _keySession = 'smart_pharmacy_active_session_v1';

  SecureStorageService([ISecureStorageClient? client])
      : _client = client ?? FlutterSecureStorageClient();

  /// Persists user session in desktop secure credentials manager.
  Future<void> saveSession(UserSession session) async {
    try {
      final jsonString = session.toJson();
      await _client.write(key: _keySession, value: jsonString);
    } catch (e) {
      throw StateError('Failed to save secure user session: $e');
    }
  }

  /// Loads active user session from desktop secure storage.
  Future<UserSession?> getSession() async {
    try {
      final jsonString = await _client.read(key: _keySession);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      return UserSession.fromJson(jsonString);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  /// Clears persistent session upon explicit logout.
  Future<void> clearSession() async {
    try {
      await _client.delete(key: _keySession);
    } catch (_) {}
  }

  /// Checks if a session is currently stored.
  Future<bool> hasSession() async {
    final session = await getSession();
    return session != null;
  }
}

