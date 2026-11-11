import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';

/// Pops up dialog informing user that their license validation period is expired
/// and prompts them to update their license validation time in EN or BN.
Future<void> showLicenseExpiredRestrictionDialog(
  BuildContext context,
  AppStrings strings,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.alertCritical, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.licenseExpiredNoticeTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        strings.licenseExpiredNotice,
        style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.textPrimary),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(strings.okBtn),
        ),
      ],
    ),
  );
}

