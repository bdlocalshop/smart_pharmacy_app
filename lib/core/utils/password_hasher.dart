import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Secure password hashing and verification using salted SHA-256 rounds.
class PasswordHasher {
  PasswordHasher._();

  /// Generates a random cryptographic salt hex string.
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Hashes [password] with an optional [salt].
  /// Returns in format: `$salt$hash`
  static String hashPassword(String password, {String? salt}) {
    final effectiveSalt = salt ?? generateSalt();
    final key = utf8.encode(effectiveSalt);
    final bytes = utf8.encode(password);

    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(bytes);

    // Apply 1000 iteration stretching
    for (int i = 0; i < 1000; i++) {
      digest = sha256.convert(digest.bytes + key);
    }

    return '\$$effectiveSalt\$${digest.toString()}';
  }

  /// Verifies [candidatePassword] against [storedHash].
  static bool verifyPassword(String candidatePassword, String storedHash) {
    if (!storedHash.startsWith('\$')) return false;

    final parts = storedHash.split('\$');
    if (parts.length != 3) return false;

    final salt = parts[1];
    final expectedDigest = parts[2];

    final candidateCalculated = hashPassword(candidatePassword, salt: salt);
    final candidateDigest = candidateCalculated.split('\$')[2];

    return candidateDigest == expectedDigest;
  }
}

