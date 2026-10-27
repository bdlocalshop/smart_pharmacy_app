import 'package:flutter/material.dart';

/// Desktop UI Theme Colors (Colorful, Modern & Vibrant Palette)
/// High-energy, visually attractive color system designed for optimal readability,
/// modern aesthetics, and eye comfort during long shifts.
class AppColors {
  AppColors._();

  // Primary: Vibrant Electric Royal Indigo & Violet
  static const Color primary = Color(0xFF4F46E5); // Indigo 600 - High energy & modern
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800 - Deep & professional
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500 - Electric violet-indigo
  static const Color primarySubtle = Color(0xFFEEF2FF); // Indigo 50 - Soft highlight

  // Vibrant Accents & Categories
  static const Color accent = Color(0xFF10B981); // Emerald 500 - Success, Sales & In-Stock
  static const Color accentDark = Color(0xFF059669); // Emerald 600
  static const Color accentLight = Color(0xFF34D399); // Emerald 400
  static const Color accentSubtle = Color(0xFFECFDF5); // Emerald 50

  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500 - Shelf locators & search
  static const Color accentCyanLight = Color(0xFF38BDF8); // Sky 400
  static const Color accentCyanSubtle = Color(0xFFF0FDF4);

  static const Color accentPurple = Color(0xFF8B5CF6); // Purple 500 - Manager role & analytics
  static const Color accentPurpleDark = Color(0xFF7C3AED); // Purple 600
  static const Color accentPurpleSubtle = Color(0xFFF5F3FF);

  static const Color accentAmber = Color(0xFFF59E0B); // Amber 500 - Owner badge & warnings
  static const Color accentAmberDark = Color(0xFFD97706); // Amber 600
  static const Color accentAmberSubtle = Color(0xFFFFFBEB);

  static const Color accentRose = Color(0xFFF43F5E); // Rose 500 - Discounts & critical tags
  static const Color accentRoseSubtle = Color(0xFFFFF1F2);

  // Convenient Aliases
  static const Color cyan = accentCyan;
  static const Color purple = accentPurple;
  static const Color warning = accentAmber;
  static const Color rose = accentRose;

  // Neutral background & surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50 - Crisp modern canvas
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceElevated = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderHighlight = Color(0xFFCBD5E1); // Slate 300

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Alert colors (Expiry radar & inventory status)
  static const Color alertCritical = Color(0xFFEF4444); // Red 500 (Expired)
  static const Color alertUrgent = Color(0xFFF59E0B); // Amber 500 (<30 days)
  static const Color alertWarning = Color(0xFFF97316); // Orange 500 (<60 days)
  static const Color alertCaution = Color(0xFFEAB308); // Yellow 500 (<90 days)
  static const Color alertSafe = Color(0xFF10B981); // Green 500 (Safe)

  // Rich Visual Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentDark, accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandHeroGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurpleDark, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [accentAmberDark, accentAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFE11D48), accentRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF0284C7), accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
