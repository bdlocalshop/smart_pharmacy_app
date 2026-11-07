import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/network/cloud_license_service.dart';
import 'package:smart_pharmacy_app/core/network/hmac_signer.dart';
import 'package:smart_pharmacy_app/core/services/secure_storage_service.dart';

void main() {
  group('HmacSigner & Cloud License Authentication Tests', () {
    test('generateHeaders computes valid HMAC-SHA256 signature matching API spec', () {
      const clientId = 'PHARMA-TEST-1234';
      const clientSecret = 'super_secret_client_key_32bytes';
      const timestamp = 1730000000;
      final payload = jsonEncode({'license_key': clientId, 'device_uuid': 'hw_device_001'});

      final headers = HmacSigner.generateHeaders(
        clientId: clientId,
        clientSecret: clientSecret,
        payload: payload,
        timestampSeconds: timestamp,
      );

      expect(headers['X-Client-Id'], equals(clientId));
      expect(headers['X-Timestamp'], equals('1730000000'));
      expect(headers['X-Signature'], isNotEmpty);
      expect(headers['X-Signature']!.length, equals(64)); // SHA-256 hex length
    });

    test('SecureStorageService saves and retrieves cloud credentials correctly', () async {
      final storage = SecureStorageService(InMemorySecureStorageClient());

      expect(await storage.getCloudLicenseKey(), isNull);

      await storage.saveCloudCredentials(
        licenseKey: 'PHARMA-1111-2222',
        clientSecret: 'secret_32_chars_long_key_demo',
        pharmacyId: 'pharm-001',
        sessionToken: '1|sanctum_token_abc',
      );

      expect(await storage.getCloudLicenseKey(), equals('PHARMA-1111-2222'));
      expect(await storage.getCloudClientSecret(), equals('secret_32_chars_long_key_demo'));
      expect(await storage.getCloudPharmacyId(), equals('pharm-001'));
      expect(await storage.getCloudSessionToken(), equals('1|sanctum_token_abc'));

      // Device UUID persistent generation
      final deviceUuid1 = await storage.getOrCreateDeviceUuid();
      expect(deviceUuid1.startsWith('hw_'), isTrue);

      final deviceUuid2 = await storage.getOrCreateDeviceUuid();
      expect(deviceUuid2, equals(deviceUuid1)); // Must remain consistent
    });

    test('isConnectionError accurately identifies network down and unreachable server', () {
      expect(CloudLicenseService.isConnectionError('SocketException: OS Error: Network unreachable'), isTrue);
      expect(CloudLicenseService.isConnectionError('ClientException: Connection refused, uri=http://127.0.0.1:8000/api/v1/pharmacy/register'), isTrue);
      expect(CloudLicenseService.isConnectionError('TimeoutException after 0:00:15.000000'), isTrue);
      expect(CloudLicenseService.isConnectionError('AppException: HTTP Error 503'), isTrue);
      expect(CloudLicenseService.isConnectionError('ValidationException: The trade license is already registered'), isFalse);
    });

    test('sanitizeErrorMessage strips sensitive API endpoints and returns friendly message', () {
      final sanitized1 = CloudLicenseService.sanitizeErrorMessage(
        'ClientException with SocketException: Connection refused (OS Error: Connection refused, errno = 111), address = 127.0.0.1, port = 8000, uri=http://127.0.0.1:8000/api/v1/pharmacy/register',
      );
      expect(sanitized1, equals('Unable to reach the registration server. Please check your internet connection and try again.'));
      expect(sanitized1.contains('127.0.0.1'), isFalse);
      expect(sanitized1.contains('/api/v1'), isFalse);

      final sanitized2 = CloudLicenseService.sanitizeErrorMessage(
        'AppException: Trade license number has already been taken.',
      );
      expect(sanitized2, equals('Trade license number has already been taken.'));
      expect(sanitized2.contains('AppException'), isFalse);
    });
  });
}

