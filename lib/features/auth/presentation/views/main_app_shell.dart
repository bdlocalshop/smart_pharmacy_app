import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pharmacy_app/core/constants/app_colors.dart';
import 'package:smart_pharmacy_app/core/database/app_database.dart';
import 'package:smart_pharmacy_app/core/localization/app_strings.dart';
import 'package:smart_pharmacy_app/core/localization/language_controller.dart';
import 'package:smart_pharmacy_app/core/localization/widgets/language_toggle_button.dart';
import 'package:smart_pharmacy_app/features/alerts/presentation/views/expiry_radar_view.dart';
import 'package:smart_pharmacy_app/features/auth/domain/user_role.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_pharmacy_app/features/auth/presentation/widgets/rbac_guard.dart';
import 'package:smart_pharmacy_app/features/inventory/presentation/views/medicines_master_view.dart';
import 'package:smart_pharmacy_app/features/pos/presentation/views/pos_billing_view.dart';
import 'package:smart_pharmacy_app/features/reports/presentation/views/reports_view.dart';

/// Main Desktop App Shell with responsive sidebar and dynamic RBAC menu items.
class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentUserSessionProvider);
    final role = session?.role ?? UserRole.salesman;
    final strings = ref.watch(appStringsProvider);

    // Define navigation items filtered by RBAC permissions
    final menuItems = <_NavItem>[
      _NavItem(
        index: 0,
        title: strings.navPosBilling,
        subtitle: strings.navPosSubtitle,
        icon: Icons.point_of_sale,
        color: AppColors.accent,
      ),
      _NavItem(
        index: 1,
        title: strings.navMedicineMaster,
        subtitle: strings.navMedicineSubtitle,
        icon: Icons.medication_outlined,
        color: AppColors.primary,
      ),
      _NavItem(
        index: 2,
        title: strings.navExpiryRadar,
        subtitle: strings.navExpirySubtitle,
        icon: Icons.radar,
        color: AppColors.warning,
      ),
      if (role.canViewReports)
        _NavItem(
          index: 3,
          title: strings.navReports,
          subtitle: strings.navReportsSubtitle,
          icon: Icons.query_stats,
          color: AppColors.purple,
        ),
      if (role.canManageUsers)
        _NavItem(
          index: 4,
          title: strings.navStaffManagement,
          subtitle: strings.navStaffSubtitle,
          icon: Icons.manage_accounts_outlined,
          color: AppColors.cyan,
        ),
      if (role.canManageBackups)
        _NavItem(
          index: 5,
          title: strings.navDatabaseBackups,
          subtitle: strings.navDatabaseSubtitle,
          icon: Icons.settings_backup_restore,
          color: AppColors.rose,
        ),
    ];

    // Ensure selected index is valid if user switched roles
    final currentIndex = menuItems.any((m) => m.index == _selectedTabIndex)
        ? _selectedTabIndex
        : menuItems.first.index;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Desktop Left Sidebar
          Container(
            width: 270,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              children: [
                // Top Brand Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                        ),
                        child: Image.asset(
                          'assets/images/Smart-Pharmacy-logo.png',
                          height: 34,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.local_pharmacy, color: AppColors.primary, size: 30),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session?.pharmacyName ?? 'Smart Pharmacy',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${strings.tenantPrefix} ${session?.pharmacyUid.substring(0, 10)}...',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Items List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    children: [
                      for (final item in menuItems)
                        _buildSidebarTile(
                          item: item,
                          isSelected: item.index == currentIndex,
                          onTap: () => setState(() => _selectedTabIndex = item.index),
                        ),
                    ],
                  ),
                ),

                // Bottom Session & Logout Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceElevated,
                    border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: _getRoleColor(role).withValues(alpha: 0.2),
                            child: Icon(Icons.person, color: _getRoleColor(role), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session?.fullName ?? 'Staff User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                _buildRoleBadge(role),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.alertCritical,
                            side: BorderSide(color: AppColors.alertCritical.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.logout, size: 16),
                          label: Text(strings.signOut, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content View
          Expanded(
            child: Column(
              children: [
                // Top Action Bar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getTabColor(currentIndex).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_getTabIcon(currentIndex), color: _getTabColor(currentIndex), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _getTabTitle(currentIndex, strings),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Language Switcher (EN <-> বাং)
                            const LanguageToggleButton(),
                            const SizedBox(width: 14),

                            // SQLite Offline status pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, color: AppColors.accent, size: 8),
                                  const SizedBox(width: 6),
                                  Text(
                                    strings.offlineModeWal,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            _buildRoleBadge(role, isDetailed: true, strings: strings),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // View Body
                Expanded(
                  child: (currentIndex == 0 || currentIndex == 3)
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: _buildTabContent(currentIndex, role),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _buildTabContent(currentIndex, role),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile({
    required _NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [item.color, item.color.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.22)
                        : item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected ? Colors.white : item.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role, {bool isDetailed = false, AppStrings? strings}) {
    final color = _getRoleColor(role);
    final text = strings != null && isDetailed
        ? strings.roleLabel(role.code)
        : (isDetailed ? 'Role: ${role.label} (${role.code})' : role.code);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDetailed ? 10 : 8, vertical: isDetailed ? 4 : 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: isDetailed ? 12 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    return switch (role) {
      UserRole.owner => AppColors.warning,
      UserRole.manager => AppColors.purple,
      UserRole.salesman => AppColors.cyan,
    };
  }

  Color _getTabColor(int index) {
    return switch (index) {
      0 => AppColors.accent,
      1 => AppColors.primary,
      2 => AppColors.warning,
      3 => AppColors.purple,
      4 => AppColors.cyan,
      5 => AppColors.rose,
      _ => AppColors.primary,
    };
  }

  String _getTabTitle(int index, [AppStrings? strings]) {
    if (strings != null) return strings.tabTitle(index);
    return switch (index) {
      0 => 'Point of Sale (POS) Billing',
      1 => 'Medicine Master Catalog',
      2 => 'Expiry Radar & Stock Alerts',
      3 => 'Financial Analytics & Gross Profit Reporting',
      4 => 'User Accounts & Staff Management (Owner Only)',
      5 => 'Database Maintenance & System Backups',
      _ => 'Smart Pharmacy',
    };
  }

  IconData _getTabIcon(int index) {
    return switch (index) {
      0 => Icons.point_of_sale,
      1 => Icons.medication_outlined,
      2 => Icons.radar,
      3 => Icons.query_stats,
      4 => Icons.manage_accounts_outlined,
      5 => Icons.settings_backup_restore,
      _ => Icons.dashboard,
    };
  }

  Widget _buildTabContent(int index, UserRole role) {
    return switch (index) {
      0 => const PosBillingView(),
      1 => const MedicinesMasterView(),
      2 => const ExpiryRadarView(),
      3 => RbacGuard.managerAndAbove(
          child: const ReportsView(),
        ),
      4 => RbacGuard.ownerOnly(
          child: _buildStaffManagementTab(),
        ),
      5 => RbacGuard.ownerOnly(
          child: _buildDatabaseTab(),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  // --- Tab 4: Staff Management (Owner Only) ---
  Widget _buildStaffManagementTab() {
    final authRepo = ref.watch(authRepositoryProvider);
    final session = ref.watch(currentUserSessionProvider);

    return FutureBuilder(
      future: authRepo.getUsers(session?.pharmacyUid ?? ''),
      builder: (context, snapshot) {
        final users = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Staff & Role Administration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Only the Owner can create, inspect, and deactivate staff logins.', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Staff User'),
                  onPressed: () => _showAddUserDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final u = users[i];
                  final uRole = UserRole.fromCode(u.role);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(uRole).withValues(alpha: 0.15),
                      child: Icon(Icons.person, color: _getRoleColor(uRole)),
                    ),
                    title: Row(
                      children: [
                        Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        _buildRoleBadge(uRole),
                      ],
                    ),
                    subtitle: Text(
                      'Username: @${u.username}${u.phone != null && u.phone!.isNotEmpty ? ' • Phone: ${u.phone}' : ''} • Added: ${u.createdAt.toIso8601String().substring(0, 10)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                          tooltip: 'Edit Staff User',
                          onPressed: () => _showEditUserDialog(context, u),
                        ),
                        const SizedBox(width: 8),
                        u.role == 'OWNER'
                            ? const Chip(label: Text('Master Owner', style: TextStyle(fontSize: 11)))
                            : Switch(
                                value: u.isActive,
                                activeThumbColor: AppColors.accent,
                                onChanged: (val) async {
                                  await authRepo.setUserActiveState(u.id, val);
                                  setState(() {});
                                },
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Tab 5: Database Maintenance (Owner Only) ---
  Widget _buildDatabaseTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Text('Database Recovery & Rolling Backups', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Automated rolling snapshots occur on every startup with 14-day rolling retention. As the Owner, you can perform immediate hot snapshots, USB flash exports, or verified database restorations.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.save_alt, size: 18),
                  label: const Text('Export Immediate Backup (.sqlite)'),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.alertCritical),
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Restore Database Archive'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtl = TextEditingController();
    final userCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final passCtl = TextEditingController();
    UserRole selectedRole = UserRole.salesman;
    bool obscurePassword = true;
    bool isSubmitting = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.person_add, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Add Staff User (Owner Access)'),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dialogError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.alertCritical.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.alertCritical, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dialogError!,
                                style: const TextStyle(color: AppColors.alertCritical, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    TextFormField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter full name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: userCtl,
                      decoration: const InputDecoration(
                        labelText: 'Username *',
                        prefixIcon: Icon(Icons.alternate_email, size: 20),
                        hintText: 'e.g. john or john_pos',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter username';
                        if (v.trim().length < 3) return 'Username must be at least 3 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        hintText: 'e.g. +880 1717-449639',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passCtl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password (min 6 chars) *',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter a password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<UserRole>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Role',
                        prefixIcon: Icon(Icons.shield_outlined, size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: UserRole.manager, child: Text('Store Manager')),
                        DropdownMenuItem(value: UserRole.salesman, child: Text('POS Salesman')),
                      ],
                      onChanged: (r) {
                        if (r != null) setDialogState(() => selectedRole = r);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        isSubmitting = true;
                        dialogError = null;
                      });

                      try {
                        final session = ref.read(currentUserSessionProvider);
                        final repo = ref.read(authRepositoryProvider);
                        await repo.registerUser(
                          pharmacyUid: session!.pharmacyUid,
                          fullName: nameCtl.text,
                          username: userCtl.text,
                          password: passCtl.text,
                          role: selectedRole,
                          phone: phoneCtl.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Staff user @${userCtl.text.trim()} created successfully! They can now log in.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSubmitting = false;
                          dialogError = e.toString().replaceFirst('AppException: ', '');
                        });
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final formKey = GlobalKey<FormState>();
    final nameCtl = TextEditingController(text: user.fullName);
    final userCtl = TextEditingController(text: user.username);
    final phoneCtl = TextEditingController(text: user.phone ?? '');
    final passCtl = TextEditingController();
    UserRole selectedRole = UserRole.fromCode(user.role);
    bool isActive = user.isActive;
    bool obscurePassword = true;
    bool isSubmitting = false;
    String? dialogError;
    final isMasterOwner = user.role == 'OWNER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.manage_accounts, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('Edit Staff User (@${user.username})'),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dialogError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.alertCritical.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.alertCritical, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dialogError!,
                                style: const TextStyle(color: AppColors.alertCritical, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    TextFormField(
                      controller: nameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter full name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: userCtl,
                      decoration: const InputDecoration(
                        labelText: 'Username *',
                        prefixIcon: Icon(Icons.alternate_email, size: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter username';
                        if (v.trim().length < 3) return 'Username must be at least 3 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        hintText: 'e.g. +880 1717-449639',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passCtl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Reset Password (optional)',
                        hintText: 'Leave blank to keep existing password',
                        helperText: 'Enter 6+ characters only if resetting password',
                        prefixIcon: const Icon(Icons.lock_reset, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6) {
                          return 'New password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    if (!isMasterOwner) ...[
                      DropdownButtonFormField<UserRole>(
                        initialValue: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Role',
                          prefixIcon: Icon(Icons.shield_outlined, size: 20),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: UserRole.manager, child: Text('Store Manager')),
                          DropdownMenuItem(value: UserRole.salesman, child: Text('POS Salesman')),
                        ],
                        onChanged: (r) {
                          if (r != null) setDialogState(() => selectedRole = r);
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Account Active Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          isActive ? 'Active (User can sign in)' : 'Deactivated (Login blocked)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? AppColors.alertSafe : AppColors.alertCritical,
                          ),
                        ),
                        value: isActive,
                        activeColor: AppColors.accent,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setDialogState(() => isActive = val),
                      ),
                    ] else ...[
                      const Text(
                        'Master Owner account role and active state cannot be modified.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        isSubmitting = true;
                        dialogError = null;
                      });

                      try {
                        final repo = ref.read(authRepositoryProvider);
                        await repo.updateUser(
                          userId: user.id,
                          fullName: nameCtl.text,
                          username: userCtl.text,
                          role: selectedRole,
                          phone: phoneCtl.text,
                          newPassword: passCtl.text.isEmpty ? null : passCtl.text,
                          isActive: isMasterOwner ? true : isActive,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Staff user @${userCtl.text.trim()} updated successfully!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() {
                          isSubmitting = false;
                          dialogError = e.toString().replaceFirst('AppException: ', '');
                        });
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _NavItem({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
