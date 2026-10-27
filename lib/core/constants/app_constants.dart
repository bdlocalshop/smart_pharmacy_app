/// Application-wide constants for Smart Pharmacy.
class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Pharmacy';
  static const String appVersion = '2.0.0';
  static const String defaultCurrencySymbol = '\$';
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Database configuration
  static const String databaseFileName = 'smart_pharmacy.sqlite';
  static const String backupDirectoryName = 'backups';
  static const int backupRetentionDays = 14;

  // Sync statuses
  static const String syncPendingInsert = 'pending_insert';
  static const String syncPendingUpdate = 'pending_update';
  static const String syncPendingDelete = 'pending_delete';
  static const String syncSynced = 'synced';

  // User roles
  static const String roleOwner = 'OWNER';
  static const String roleManager = 'MANAGER';
  static const String roleSalesman = 'SALESMAN';

  static const List<String> userRoles = [
    roleOwner,
    roleManager,
    roleSalesman,
  ];

  // Payment methods
  static const String paymentCash = 'Cash';
  static const String paymentCard = 'Card';
  static const String paymentMobile = 'Mobile';
  static const String paymentDue = 'Due';

  // Expiry thresholds in days
  static const int expiryCriticalThresholdDays = 30;
  static const int expiryWarningThresholdDays = 60;
  static const int expiryCautionThresholdDays = 90;
}

