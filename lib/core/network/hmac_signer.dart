import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Helper for generating HMAC-SHA256 authenticated request headers
/// compliant with the Smart Pharmacy Cloud License Manager specification.
class HmacSigner {
  HmacSigner._();

  /// Generates the required X-Client-Id, X-Timestamp, and X-Signature headers.
  static Map<String, String> generateHeaders({
    required String clientId,
    required String clientSecret,
    String payload = '',
    int? timestampSeconds,
  }) {
    final timestamp = timestampSeconds ?? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
    final message = '$clientId$timestamp$payload';
    final keyBytes = utf8.encode(clientSecret);
    final messageBytes = utf8.encode(message);
    final hmac = Hmac(sha256, keyBytes);
    final signature = hmac.convert(messageBytes).toString();

    return {
      'X-Client-Id': clientId,
      'X-Timestamp': timestamp.toString(),
      'X-Signature': signature,
    };
  }
}

