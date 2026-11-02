import 'package:flutter/material.dart';

/// Design tokens. NTS papers are printed sheets marked on an answer bubble
/// sheet, so the look is paper-white with deep green chrome and one amber accent.
abstract final class AppColors {
  static const green = Color(0xFF0B5D4B);
  static const amber = Color(0xFFE39A1C);
  static const correct = Color(0xFF1E7B45);
  static const incorrect = Color(0xFFB3261E);
  static const flagged = Color(0xFFD97F00);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.green, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? AppColors.green : scheme.surface,
        foregroundColor: brightness == Brightness.light ? Colors.white : scheme.onSurface,
      ),
      cardTheme: const CardThemeData(margin: EdgeInsetsDirectional.only(bottom: AppSpacing.sm)),
    );
  }
}
