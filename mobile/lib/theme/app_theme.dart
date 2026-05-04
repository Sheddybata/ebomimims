import 'package:flutter/material.dart';

/// Red-forward brand theme (aligned with IMS web accent).
class AppTheme {
  static const Color brandRed = Color(0xFFB91C1C); // red-700
  static const Color brandRedDark = Color(0xFF991B1B); // red-800
  static const Color brandRedLight = Color(0xFFFEF2F2); // subtle surfaces

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: brandRed,
      brightness: Brightness.light,
    );

    final scheme = base.copyWith(
      primary: brandRed,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFE4E6),
      onPrimaryContainer: const Color(0xFF450A0A),
      secondary: brandRedDark,
      onSecondary: Colors.white,
      tertiary: const Color(0xFFDC2626),
      surface: Colors.white,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: brandRedLight,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: brandRed.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w600,
              color: brandRed,
              fontSize: 12,
            );
          }
          return TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: brandRed);
          }
          return IconThemeData(color: Colors.grey.shade600);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandRed,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        focusColor: brandRed,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandRed, width: 2),
        ),
      ),
    );
  }
}
