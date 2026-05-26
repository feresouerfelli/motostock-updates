import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkSurfaceVariant = Color(0xFF222638);
  static const Color darkBorder = Color(0xFF2A2D3E);
  static const Color darkText = Color(0xFFE8EAF0);
  static const Color darkTextSecondary = Color(0xFF8B8FA8);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF4F7FE);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFEBEEF5);
  static const Color lightBorder = Color(0xFFDCE1E7);
  static const Color lightText = Color(0xFF2D3748);
  static const Color lightTextSecondary = Color(0xFF718096);

  // Brand Colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color primaryDark = Color(0xFFE5501A);
  static const Color secondary = Color(0xFF4A90E2);
  static const Color info = Color(0xFF00B8D9);

  // Status Colors
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFBE33);
  static const Color danger = Color(0xFFFF4757);

  // Legacy mappings for compatibility
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceVariant = darkSurfaceVariant;
  static const Color border = darkBorder;
  static const Color textPrimary = darkText;
  static const Color textSecondary = darkTextSecondary;

  // Stock Status Colors
  static const Color stockOk = Colors.green;
  static const Color stockLow = Colors.orange;
  static const Color stockCritical = Colors.deepOrange;
  static const Color stockOut = Colors.red;

  // Chart Colors
  static const List<Color> chartColors = [
    primary,
    secondary,
    info,
    success,
    warning,
    danger,
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF8A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
