

import 'package:flutter/material.dart';
/*
class AppColors {
 // Brand
  static const primary = Color(0xFF6B73FF);
  static const primaryDark = Color(0xFF000DFF);

  // Text
  static const textPrimary = Color(0xFF2C3E50);
  static const textSecondary = Color(0xFF6C757D);

  // Backgrounds
  static const background = Color(0xFFF8F9FB);
  static const surface = Colors.white;

  // Borders & dividers
  static const border = Color(0xFFE0E0E0);

  // Status
  static const success = Color(0xFF4ECDC4);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFFF6B6B);
  static const info = Color(0xFF6B73FF);
}

*/



class AppColors {
  // Brand
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryDark = Color(0xFF000DFF);
  static const Color primarySoft = Color(0xFFEEF0FF);

  // Success
  static const Color success = Color(0xFF4ECDC4);
  static const Color successSoft = Color(0xFFE6FAF8);

  // Warning
  static const Color warning = Color(0xFFFFE66D);
  static const Color warningSoft = Color(0xFFFFF8D6);

  // Error
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorSoft = Color(0xFFFFECEC);

  // Text
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textDisabled = Color(0xFFBDC3C7);

  // UI
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceSoft = Color(0xFFF3F4F6);

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF1F3F5);

  // Icons
  static const Color iconActive = primary;
  static const Color iconInactive = Color(0xFFADB5BD);
  static const Color iconDisabled = Color(0xFFDEE2E6);

  // Achievement Badge
  static const Color achievementStart = Color(0xFFF093FB);
  static const Color achievementEnd = Color(0xFFF5576C);

  // Gradients
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryDark],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static LinearGradient get achievementGradient => LinearGradient(
        colors: [achievementStart, achievementEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Health Score Color Helper
  static Color getHealthScoreColor(int score) {
    if (score >= 71) return success;
    if (score >= 41) return warning;
    return error;
  }

  static String getHealthScoreLabel(int score) {
    if (score >= 71) return 'Good';
    if (score >= 41) return 'Fair';
    return 'Poor';
  }

  // Health Score Emoji Helper
  static String getHealthScoreEmoji(int score) {
    if (score >= 71) return '🟢';
    if (score >= 41) return '🟡';
    return '🔴';
  }
}