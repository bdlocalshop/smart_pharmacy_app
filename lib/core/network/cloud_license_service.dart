import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/device_info_service.dart';
import '../services/secure_storage_service.dart';
import 'api_client.dart';
import 'hmac_signer.dart';

final cloudLicenseServiceProvider = Provider<CloudLicenseService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = SecureStorageService();
  final deviceInfo = DeviceInfoService(secureStorage);
  return CloudLicenseService(
    apiClient: apiClient,
    secureStorage: secureStorage,
    deviceInfo: deviceInfo,
  );
});

class CloudRegistrationResult {
  final bool success;
  final String? pharmacyId;
  final String? pharmacyName;
  final String? licenseKey;
  final String? clientSecret;
  final String? verificationStatus;
  final String? message;

  const CloudRegistrationResult({
    required this.success,
    this.pharmacyId,
    this.pharmacyName,
    this.licenseKey,
    this.clientSecret,
    this.verificationStatus,
    this.message,
  });
}

class CloudValidationResult {
  final bool success;
  final String? pharmacyName;
  final String? licenseStatus;
  final int? sessionDaysRemaining;
  final String? validUntil;
  final String? sessionToken;
  final String? message;

  const CloudValidationResult({
    required this.success,
    this.pharmacyName,
    this.licenseStatus,
    this.sessionDaysRemaining,
    this.validUntil,
    this.sessionToken,
    this.message,
  });
}

class CloudStatusResult {
  final bool success;
  final String? verificationStatus;
  final bool isApproved;
  final String? licenseStatus;
  final int? daysRemaining;
  final String? validUntil;
  final String? message;

  const CloudStatusResult({
    required this.success,
    this.verificationStatus,
    this.isApproved = false,
    this.licenseStatus,
    this.daysRemaining,
    this.validUntil,
    this.message,
  });
}

class CloudBackupResult {
  final bool success;
  final String? backupId;
  final String? timestamp;
  final String? message;

  const CloudBackupResult({
    required this.success,
    this.backupId,
    this.timestamp,
    this.message,
  });
}

/// Service managing cloud license activation, status checks, and backup archiving.
class CloudLicenseService {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;
  final DeviceInfoService deviceInfo;

  CloudLicenseService({
    required this.apiClient,
    required this.secureStorage,
    required this.deviceInfo,
  });

  /// Registers pharmacy with cloud backend and permanently binds device hardware lock.
  Future<CloudRegistrationResult> registerPharmacy({
    required String pharmacyName,
    required String tradeLicenseNumber,
    required String pharmacyAddress,
    required String pharmacyPhone,
    String? mapLocationUrl,
    required String ownerName,
    required String ownerPhone,
    String? ownerEmail,
    String? ownerAddress,
    required String password,
    required String passwordConfirmation,
  }) async {
    final devicePayload = await deviceInfo.getDevicePayload();

    final body = {
      'pharmacy_name': pharmacyName.trim(),
      'trade_license_number': tradeLicenseNumber.trim(),
      'pharmacy_address': pharmacyAddress.trim(),
      'pharmacy_phone': pharmacyPhone.trim(),
      if (mapLocationUrl != null && mapLocationUrl.trim().isNotEmpty)
        'map_location_url': mapLocationUrl.trim(),
      'owner_name': ownerName.trim(),
      'owner_phone': ownerPhone.trim(),
      if (ownerEmail != null && ownerEmail.trim().isNotEmpty)
        'owner_email': ownerEmail.trim(),
      if (ownerAddress != null && ownerAddress.trim().isNotEmpty)
        'owner_address': ownerAddress.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
      ...devicePayload,
    };

    try {
      final res = await apiClient.post('/pharmacy/register', body: body);

      final data = res['data'] as Map<String, dynamic>?;
      final creds = data?['credentials'] as Map<String, dynamic>?;

      final licenseKey = creds?['license_key'] as String?;
      final clientSecret = creds?['client_secret'] as String?;
      final pharmacyId = data?['pharmacy_id'] as String?;
      final verificationStatus = data?['verification_status'] as String?;

      if (licenseKey != null && clientSecret != null) {
        await secureStorage.saveCloudCredentials(
          licenseKey: licenseKey,
          clientSecret: clientSecret,
          pharmacyId: pharmacyId,
        );
      }

      return CloudRegistrationResult(
        success: true,
        pharmacyId: pharmacyId,
        pharmacyName: data?['pharmacy_name'] as String? ?? pharmacyName,
        licenseKey: licenseKey,
        clientSecret: clientSecret,
        verificationStatus: verificationStatus,
        message: res['message']?.toString() ?? 'Pharmacy registered successfully and device bound.',
      );
    } catch (e) {
      return CloudRegistrationResult(
        success: false,
        message: e.toString().replaceFirst('AppException: ', ''),
      );
    }
  }

  /// Validates license with HMAC-SHA256 signature and issues a cloud session token.
  Future<CloudValidationResult> validateLicense({
    String? licenseKey,
    String? clientSecret,
  }) async {
    final key = licenseKey ?? await secureStorage.getCloudLicenseKey();
    final secret = clientSecret ?? await secureStorage.getCloudClientSecret();

    if (key == null || key.isEmpty) {
      return const CloudValidationResult(
        success: false,
        message: 'No license key configured on this device.',
      );
    }

    if (secret == null || secret.isEmpty) {
      return const CloudValidationResult(
        success: false,
        message: 'Missing HMAC client secret for authentication.',
      );
    }

    final devicePayload = await deviceInfo.getDevicePayload();
    final body = {
      'license_key': key,
      ...devicePayload,
    };
    final jsonPayload = jsonEncode(body);

    final hmacHeaders = HmacSigner.generateHeaders(
      clientId: key,
      clientSecret: secret,
      payload: jsonPayload,
    );

    try {
      final res = await apiClient.post(
        '/license/validate',
        body: body,
        headers: hmacHeaders,
      );

      final data = res['data'] as Map<String, dynamic>?;
      final sessionToken = data?['session_token'] as String?;

      if (sessionToken != null) {
        await secureStorage.saveCloudCredentials(
          licenseKey: key,
          clientSecret: secret,
          sessionToken: sessionToken,
        );
      }

      return CloudValidationResult(
        success: true,
        pharmacyName: data?['pharmacy_name'] as String?,
        licenseStatus: data?['license_status'] as String? ?? 'ACTIVE',
        sessionDaysRemaining: data?['session_days_remaining'] as int?,
        validUntil: data?['valid_until'] as String?,
        sessionToken: sessionToken,
        message: 'License validated successfully.',
      );
    } catch (e) {
      return CloudValidationResult(
        success: false,
        message: e.toString().replaceFirst('AppException: ', ''),
      );
    }
  }

  /// Checks verification and hardware binding status on the server.
  Future<CloudStatusResult> checkStatus({String? licenseKey}) async {
    final key = licenseKey ?? await secureStorage.getCloudLicenseKey();
    final deviceUuid = await deviceInfo.getDeviceUuid();

    try {
      final res = await apiClient.get(
        '/pharmacy/status',
        queryParameters: {
          'device_uuid': deviceUuid,
          if (key != null && key.isNotEmpty) 'license_key': key,
        },
      );

      final data = res['data'] as Map<String, dynamic>?;
      final license = data?['license'] as Map<String, dynamic>?;

      return CloudStatusResult(
        success: true,
        verificationStatus: data?['verification_status'] as String?,
        isApproved: data?['is_approved'] == true,
        licenseStatus: license?['status'] as String?,
        daysRemaining: license?['days_remaining'] as int?,
        validUntil: license?['valid_until'] as String?,
        message: 'Status check succeeded.',
      );
    } catch (e) {
      return CloudStatusResult(
        success: false,
        message: e.toString().replaceFirst('AppException: ', ''),
      );
    }
  }

  /// Uploads SQLite backup archive to the cloud server via multipart form-data.
  Future<CloudBackupResult> uploadCloudBackup({
    required File backupFile,
    String? notes,
  }) async {
    if (!backupFile.existsSync()) {
      return const CloudBackupResult(
        success: false,
        message: 'Backup file does not exist on disk.',
      );
    }

    final sessionToken = await secureStorage.getCloudSessionToken();
    final licenseKey = await secureStorage.getCloudLicenseKey();
    final clientSecret = await secureStorage.getCloudClientSecret();
    final deviceUuid = await deviceInfo.getDeviceUuid();

    final uri = Uri.parse(AppConfig.buildUrl('/backup/upload'));
    final request = http.MultipartRequest('POST', uri);

    request.fields['device_uuid'] = deviceUuid;
    if (notes != null && notes.isNotEmpty) {
      request.fields['backup_notes'] = notes;
    }

    request.files.add(
      await http.MultipartFile.fromPath('backup_file', backupFile.path),
    );

    if (sessionToken != null && sessionToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $sessionToken';
    } else if (licenseKey != null && clientSecret != null) {
      // Fallback: HMAC authentication headers
      final hmacHeaders = HmacSigner.generateHeaders(
        clientId: licenseKey,
        clientSecret: clientSecret,
      );
      request.headers.addAll(hmacHeaders);
    }

    request.headers['Accept'] = 'application/json';

    try {
      final streamedResponse = await request.send().timeout(
            Duration(seconds: AppConfig.apiTimeoutSeconds * 2),
          );
      final response = await http.Response.fromStream(streamedResponse);

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CloudBackupResult(
          success: true,
          backupId: decoded['backup_id'] as String?,
          timestamp: decoded['timestamp'] as String?,
          message: decoded['message']?.toString() ?? 'Database backup safely archived.',
        );
      }

      final msg = decoded['message']?.toString() ?? 'Upload failed (HTTP ${response.statusCode})';
      return CloudBackupResult(success: false, message: msg);
    } catch (e) {
      return CloudBackupResult(success: false, message: 'Upload error: $e');
    }
  }
}

