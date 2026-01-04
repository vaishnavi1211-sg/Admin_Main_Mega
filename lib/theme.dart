import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF77BEF0);      // Light Blue
  static const secondary = Color(0xFF34699A);    // Dark Blue
  static const background = Colors.white;        // White
  static const text = Colors.black87;            // Main text color
  static const subtitle = Colors.black54;        // Subtext
  static const border = Color(0xFFE0E0E0);

  static var cardBg;       // Light grey border only
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // MAIN COLORS
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    // strict color scheme – NO EXTRA COLORS
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
    ),

    // TEXT THEMES
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.text,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: AppColors.text,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppColors.subtitle,
        fontSize: 12,
      ),
    ),

    // APPBAR
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.secondary,
      iconTheme: IconThemeData(color: AppColors.secondary),
      titleTextStyle: TextStyle(
        color: AppColors.secondary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // BUTTONS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.primary),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevation: const WidgetStatePropertyAll(2),
      ),
    ),

    // INPUT FIELDS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      labelStyle: const TextStyle(color: AppColors.subtitle),
      hintStyle: const TextStyle(color: AppColors.subtitle),
    ),

    // CARD STYLE (pure white)
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      shadowColor: Colors.black.withOpacity(0.08),
    ),

    // ICONS
    iconTheme: const IconThemeData(
      color: AppColors.secondary,
      size: 22,
    ),
  );
}
