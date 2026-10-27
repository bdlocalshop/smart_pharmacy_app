import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/user_role.dart';
import '../controllers/auth_controller.dart';

/// Role-Based Access Control (RBAC) Guard widget.
/// Conditionally renders [child] if the authenticated user has sufficient role permissions,
/// or renders [fallback] / an accessible restriction message.
class RbacGuard extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final bool Function(UserRole role)? customCheck;
  final Widget child;
  final Widget? fallback;
  final String? restrictedMessage;

  const RbacGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.restrictedMessage,
  }) : customCheck = null;

  /// Shorthand constructor for Owner-only views (User management, system settings, backup restore).
  const RbacGuard.ownerOnly({
    super.key,
    required this.child,
    this.fallback,
    this.restrictedMessage = 'Master Administrative Access: This section is restricted to the Pharmacy Owner.',
  })  : allowedRoles = const [UserRole.owner],
        customCheck = null;

  /// Shorthand constructor for Owner & Manager views (Profit reporting, batch management, supplier ledgers).
  const RbacGuard.managerAndAbove({
    super.key,
    required this.child,
    this.fallback,
    this.restrictedMessage = 'Manager Access Required: Financial margins and inventory adjustments are hidden for Salesmen.',
  })  : allowedRoles = const [UserRole.owner, UserRole.manager],
        customCheck = null;

  /// Custom rule validator.
  const RbacGuard.custom({
    super.key,
    required bool Function(UserRole role) check,
    required this.child,
    this.fallback,
    this.restrictedMessage,
  })  : customCheck = check,
        allowedRoles = const [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);

    if (role == null) {
      return fallback ?? const SizedBox.shrink();
    }

    final hasPermission = customCheck != null
        ? customCheck!(role)
        : allowedRoles.contains(role);

    if (hasPermission) {
      return child;
    }

    if (fallback != null) {
      return fallback!;
    }

    return RbacRestrictedBanner(
      message: restrictedMessage ?? 'You do not have permission to view or modify this resource.',
      requiredRoles: allowedRoles,
      currentRole: role,
    );
  }
}

/// Visual banner displayed when an operation is blocked by RBAC.
class RbacRestrictedBanner extends StatelessWidget {
  final String message;
  final List<UserRole> requiredRoles;
  final UserRole currentRole;

  const RbacRestrictedBanner({
    super.key,
    required this.message,
    required this.requiredRoles,
    required this.currentRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.alertCritical.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gpp_bad_outlined, color: AppColors.alertCritical, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Access Restricted (RBAC Policy)',
                  style: TextStyle(
                    color: AppColors.alertCritical,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Role: ${currentRole.label} (${currentRole.code})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

