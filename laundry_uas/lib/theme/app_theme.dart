import 'package:flutter/material.dart';

class AppTheme {
  static const purple = Color(0xFF6C63FF);
  static const purpleDark = Color(0xFF4F46D8);
  static const background = Color(0xFFF5F6FA);
  static const textDark = Color(0xFF1A1A2E);

  static const radiusSm = 10.0;
  static const radiusMd = 14.0;
  static const radiusLg = 16.0;
  static const radiusXl = 20.0;

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
