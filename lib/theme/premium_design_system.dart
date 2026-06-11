import 'package:flutter/material.dart';

/// Premium Design System Tokens
/// Combining Linear/Notion layout structure with Headspace/Calm emotional tones

class PremiumDesignSystem {
  // Light Palette
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimaryAccent = Color(0xFF6366F1);
  static const Color lightSecondary = Color(0xFFDDD6FE);
  static const Color lightStructuralBorder = Color(0xFFE5E7EB);

  // Dark Palette
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkPrimaryAccent = Color(0xFF818CF8);
  static const Color darkStructuralBorder = Color(0xFF1F2937);

  // Design Tokens
  static const double borderRadius = 16.0;
  static const double borderWidth = 1.2;
  static const double cardPadding = 16.0;
  static const double cardPaddingLarge = 20.0;
  static const double modalTopRadius = 24.0;

  // Elevation
  static BoxShadow get subtleElevation => const BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 24,
        offset: Offset(0, 4),
      );

  static BoxShadow get subtleElevationDark => const BoxShadow(
        color: Color(0x05000000),
        blurRadius: 24,
        offset: Offset(0, 4),
      );

  // Typography
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}

/// Light Theme Configuration
class PremiumLightTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: PremiumDesignSystem.lightBackground,
        cardColor: PremiumDesignSystem.lightSurface,
        dividerColor: PremiumDesignSystem.lightStructuralBorder,
        primaryColor: PremiumDesignSystem.lightPrimaryAccent,
        colorScheme: const ColorScheme.light(
          primary: PremiumDesignSystem.lightPrimaryAccent,
          secondary: PremiumDesignSystem.lightSecondary,
          surface: PremiumDesignSystem.lightSurface,
          background: PremiumDesignSystem.lightBackground,
          outline: PremiumDesignSystem.lightStructuralBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: PremiumDesignSystem.lightBackground,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: PremiumDesignSystem.lightSurface,
          selectedItemColor: PremiumDesignSystem.lightPrimaryAccent,
          unselectedItemColor: Color(0xFF9CA3AF),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PremiumDesignSystem.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PremiumDesignSystem.borderRadius),
            borderSide: const BorderSide(
              color: PremiumDesignSystem.lightStructuralBorder,
              width: PremiumDesignSystem.borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PremiumDesignSystem.borderRadius),
            borderSide: const BorderSide(
              color: PremiumDesignSystem.lightStructuralBorder,
              width: PremiumDesignSystem.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PremiumDesignSystem.borderRadius),
            borderSide: const BorderSide(
              color: PremiumDesignSystem.lightPrimaryAccent,
              width: PremiumDesignSystem.borderWidth,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: PremiumDesignSystem.displayLarge,
          displayMedium: PremiumDesignSystem.displayMedium,
          headlineMedium: PremiumDesignSystem.headline,
          bodyLarge: PremiumDesignSystem.bodyLarge,
          bodyMedium: PremiumDesignSystem.bodyMedium,
          bodySmall: PremiumDesignSystem.bodySmall,
          labelMedium: PremiumDesignSystem.label,
        ),
      );
}

/// Dark Theme Configuration
class PremiumDarkTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PremiumDesignSystem.darkBackground,
        cardColor: PremiumDesignSystem.darkSurface,
        dividerColor: PremiumDesignSystem.darkStructuralBorder,
        primaryColor: PremiumDesignSystem.darkPrimaryAccent,
        colorScheme: const ColorScheme.dark(
          primary: PremiumDesignSystem.darkPrimaryAccent,
          secondary: PremiumDesignSystem.lightSecondary,
          surface: PremiumDesignSystem.darkSurface,
          background: PremiumDesignSystem.darkBackground,
          outline: PremiumDesignSystem.darkStructuralBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: PremiumDesignSystem.darkBackground,
          foregroundColor: Color(0xFFF9FAFB),
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: PremiumDesignSystem.darkSurface,
          selectedItemColor: PremiumDesignSystem.darkPrimaryAccent,
          unselectedItemColor: Color(0xFF6B7280),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PremiumDesignSystem.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PremiumDesignSystem.borderRadius),
            borderSide: const BorderSide(
              color: PremiumDesignSystem.darkStructuralBorder,
              width: PremiumDesignSystem.borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PremiumDesignSystem.borderRadius),
            borderSide: const BorderSide(
              color: PremiumDesignSystem.darkStructuralBorder,
              width: PremiumDesignSystem.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(PremiumDesignSystem.borderRadius),
            borderSide: const BorderSide(
              color: PremiumDesignSystem.darkPrimaryAccent,
              width: PremiumDesignSystem.borderWidth,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: PremiumDesignSystem.displayLarge,
          displayMedium: PremiumDesignSystem.displayMedium,
          headlineMedium: PremiumDesignSystem.headline,
          bodyLarge: PremiumDesignSystem.bodyLarge,
          bodyMedium: PremiumDesignSystem.bodyMedium,
          bodySmall: PremiumDesignSystem.bodySmall,
          labelMedium: PremiumDesignSystem.label,
        ),
      );
}
