import 'dart:convert';
import 'user_role.dart';

/// Active authenticated user session metadata cached in secure desktop storage.
class UserSession {
  final String userId;
  final String username;
  final String fullName;
  final UserRole role;
  final String pharmacyUid;
  final String pharmacyName;
  final String currencySymbol;
  final String token;
  final DateTime loginTimestamp;

  const UserSession({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    required this.pharmacyUid,
    required this.pharmacyName,
    required this.currencySymbol,
    required this.token,
    required this.loginTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'full_name': fullName,
      'role': role.code,
      'pharmacy_uid': pharmacyUid,
      'pharmacy_name': pharmacyName,
      'currency_symbol': currencySymbol,
      'token': token,
      'login_timestamp': loginTimestamp.toIso8601String(),
    };
  }

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      userId: map['user_id'] as String,
      username: map['username'] as String,
      fullName: map['full_name'] as String,
      role: UserRole.fromCode(map['role'] as String),
      pharmacyUid: map['pharmacy_uid'] as String,
      pharmacyName: map['pharmacy_name'] as String,
      currencySymbol: (map['currency_symbol'] as String?) ?? '৳',
      token: map['token'] as String,
      loginTimestamp: DateTime.parse(map['login_timestamp'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserSession.fromJson(String source) =>
      UserSession.fromMap(jsonDecode(source) as Map<String, dynamic>);

  UserSession copyWith({
    String? userId,
    String? username,
    String? fullName,
    UserRole? role,
    String? pharmacyUid,
    String? pharmacyName,
    String? currencySymbol,
    String? token,
    DateTime? loginTimestamp,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      pharmacyUid: pharmacyUid ?? this.pharmacyUid,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      token: token ?? this.token,
      loginTimestamp: loginTimestamp ?? this.loginTimestamp,
    );
  }
}

