import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pharmacy_app/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('apiBaseUrl defaults to local Laravel backend API v1', () {
      expect(AppConfig.apiBaseUrl, equals('http://127.0.0.1:8000/api/v1'));
      expect(AppConfig.environment, equals('development'));
      expect(AppConfig.apiTimeoutSeconds, equals(15));
      expect(AppConfig.isDevelopment, isTrue);
      expect(AppConfig.isProduction, isFalse);
    });

    test('buildUrl formats endpoints properly without duplicate slashes', () {
      expect(
        AppConfig.buildUrl('/pharmacy/register'),
        equals('http://127.0.0.1:8000/api/v1/pharmacy/register'),
      );
      expect(
        AppConfig.buildUrl('pharmacy/status'),
        equals('http://127.0.0.1:8000/api/v1/pharmacy/status'),
      );
    });
  });
}

