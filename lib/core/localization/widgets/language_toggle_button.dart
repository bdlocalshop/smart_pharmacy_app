import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../app_strings.dart';
import '../language_controller.dart';

/// Interactive animated language toggle button (English <-> বাংলা).
class LanguageToggleButton extends ConsumerWidget {
  final bool isCompact;

  const LanguageToggleButton({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final isBn = currentLang == AppLanguage.bn;

    return Tooltip(
      message: isBn ? 'Switch to English' : 'বাংলা ভাষায় পরিবর্তন করুন',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ref.read(appLanguageProvider.notifier).toggleLanguage(),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                _buildSegment(
                  label: 'EN',
                  isActive: !isBn,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 1,
                  height: 12,
                  color: AppColors.border,
                ),
                _buildSegment(
                  label: 'বাং',
                  isActive: isBn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
