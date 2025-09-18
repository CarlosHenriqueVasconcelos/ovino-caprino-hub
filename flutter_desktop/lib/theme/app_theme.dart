import 'package:flutter/material.dart';

class AppTheme {
  // Cores BEGO Agritech - Sistema rural/natureza inspirado
  static const Color primaryGreen = Color(0xFF22C55E); // Verde pastoral/natureza HSL(142, 76%, 36%)
  static const Color primaryGlow = Color(0xFF4ADE80); // Verde brilhante HSL(142, 86%, 46%)
  static const Color secondaryBrown = Color(0xFFD6C7A8); // Terra/marrom HSL(25, 45%, 85%)
  static const Color accentGold = Color(0xFFEAB308); // Dourado/cereal HSL(45, 93%, 47%)
  static const Color backgroundLight = Color(0xFFFAFDF9); // HSL(120, 20%, 98%)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardLight = Color(0xFFF8FBF6); // HSL(120, 15%, 97%)
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color destructive = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryBrown,
        tertiary: accentGold,
        surface: backgroundLight,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: const Color(0xFF78716C),
        onSurface: textPrimary,
        onBackground: textPrimary,
        error: destructive,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      appBarTheme: AppBarTheme(
        backgroundColor: cardLight.withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primaryGreen),
      ),
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 2,
        shadowColor: primaryGreen.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: BorderSide(color: borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryGreen.withOpacity(0.1),
        labelStyle: const TextStyle(color: primaryGreen),
        side: BorderSide(color: primaryGreen.withOpacity(0.2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryGlow,
        secondary: const Color(0xFF64748B),
        tertiary: accentGold,
        surface: backgroundDark,
        background: backgroundDark,
        onPrimary: backgroundDark,
        onSecondary: Colors.white70,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: destructive,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark.withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primaryGlow),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 2,
        shadowColor: primaryGlow.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}