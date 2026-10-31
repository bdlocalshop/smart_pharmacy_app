import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage_service.dart';

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  // Can be watched from Riverpod
  return DeviceInfoService(SecureStorageService());
});

/// Service responsible for device hardware identification and metadata.
class DeviceInfoService {
  final SecureStorageService _secureStorage;

  DeviceInfoService(this._secureStorage);

  /// Hardware device UUID used for strict 1-device hardware binding.
  Future<String> getDeviceUuid() async {
    return _secureStorage.getOrCreateDeviceUuid();
  }

  /// Friendly workstation machine name (hostname).
  String getDeviceName() {
    try {
      return Platform.localHostname;
    } catch (_) {
      return 'Windows-Workstation';
    }
  }

  /// Platform type string as required by the API ('desktop' | 'mobile').
  String getPlatform() {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'desktop';
    }
    return 'mobile';
  }

  /// Application semantic version.
  String getAppVersion() => '1.0.0';

  /// Complete device metadata payload matching the API requirements.
  Future<Map<String, String>> getDevicePayload() async {
    return {
      'device_uuid': await getDeviceUuid(),
      'device_name': getDeviceName(),
      'platform': getPlatform(),
      'app_version': getAppVersion(),
    };
  }
}

