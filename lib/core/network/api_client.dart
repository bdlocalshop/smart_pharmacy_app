import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../errors/exceptions.dart';

/// Provider for the centralized API client.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Reusable HTTP client configured with AppConfig base URL and JSON defaults.
class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  /// Default headers sent with all requests.
  Map<String, String> get _defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Duration get _timeout => Duration(seconds: AppConfig.apiTimeoutSeconds);

  /// Executes GET request against configured API.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(AppConfig.buildUrl(endpoint)).replace(
      queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())),
    );

    try {
      final response = await _httpClient
          .get(
            uri,
            headers: {..._defaultHeaders, ...?headers},
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw AppException('API connection failed: $e');
    }
  }

  /// Executes POST request against configured API.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(AppConfig.buildUrl(endpoint));

    try {
      final response = await _httpClient
          .post(
            uri,
            headers: {..._defaultHeaders, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw AppException('API request failed: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = {'raw': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    final message = (decoded is Map && decoded['message'] != null)
        ? decoded['message'].toString()
        : 'HTTP Error ${response.statusCode}';
    throw AppException(message);
  }

  void close() {
    _httpClient.close();
  }
}

