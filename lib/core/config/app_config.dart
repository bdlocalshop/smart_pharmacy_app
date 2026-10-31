/// Application configuration for environment, networking, and API URLs.
///
/// Configure values at runtime or build time using:
/// `--dart-define=API_BASE_URL="http://127.0.0.1:8000/api/v1"`
/// or using a JSON config file:
/// `--dart-define-from-file=config.json`
class AppConfig {
  AppConfig._();

  /// Default API base URL pointing to the Laravel backend API v1.
  /// Matches the documentation at http://127.0.0.1:8000/admin/api-docs/embed
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  /// Application environment ('development', 'staging', 'production').
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Network timeout for API requests in seconds.
  static const int apiTimeoutSeconds = int.fromEnvironment(
    'API_TIMEOUT_SECONDS',
    defaultValue: 15,
  );

  /// Helper to determine if running in development mode.
  static bool get isDevelopment => environment == 'development';

  /// Helper to determine if running in production mode.
  static bool get isProduction => environment == 'production';

  /// Returns full URL for a given relative API route.
  static String buildUrl(String endpoint) {
    final cleanBase = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$cleanBase$cleanEndpoint';
  }
}

