/// Role-Based Access Control (RBAC) role definition for Smart Pharmacy.
enum UserRole {
  owner('OWNER', 'Owner / Administrator'),
  manager('MANAGER', 'Store Manager'),
  salesman('SALESMAN', 'POS Salesman / Cashier');

  final String code;
  final String label;

  const UserRole(this.code, this.label);

  static UserRole fromCode(String code) {
    return switch (code.toUpperCase()) {
      'OWNER' => UserRole.owner,
      'MANAGER' => UserRole.manager,
      'SALESMAN' => UserRole.salesman,
      _ => throw ArgumentError('Unknown user role code: $code'),
    };
  }

  // --- Granular RBAC Permission Helpers ---

  /// Owner only: Creating, editing, or deactivating other staff accounts.
  bool get canManageUsers => this == UserRole.owner;

  /// Owner & Manager: View cost prices, gross profit calculations, and financial KPIs.
  bool get canViewProfits => this == UserRole.owner || this == UserRole.manager;

  /// Owner & Manager: Add new medicines, create batches, and adjust stock counts.
  /// Salesman has view-only access.
  bool get canManageInventory => this == UserRole.owner || this == UserRole.manager;

  /// Owner & Manager: Manage suppliers and ledger due records.
  bool get canManageSuppliers => this == UserRole.owner || this == UserRole.manager;

  /// Owner & Manager: View full financial audit reports and sales summaries.
  bool get canViewReports => this == UserRole.owner || this == UserRole.manager;

  /// Owner only: Onboarding reconfiguration, printer hardware configuration.
  bool get canManageSettings => this == UserRole.owner;

  /// Owner only: Trigger manual database export, USB sync, or database restoration.
  bool get canManageBackups => this == UserRole.owner;

  /// All roles: POS terminal checkout, cart operations, receipt generation.
  bool get canAccessPos => true;

  /// All roles: Real-time stock availability and physical shelf locator search.
  bool get canLookupStock => true;
}

