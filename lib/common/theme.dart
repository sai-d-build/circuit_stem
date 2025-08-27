import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightModeColors {
  static const lightPrimary = Color(0xFF2E7D32);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFE8F5E8);
  static const lightOnPrimaryContainer = Color(0xFF1B5E20);
  static const lightSecondary = Color(0xFF1976D2);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFFBBDEFB); // Added
  static const lightTertiary = Color(0xFFFF6F00);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightError = Color(0xFFD32F2F);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFCDD2);
  static const lightOnErrorContainer = Color(0xFF8B0000);
  static const lightInversePrimary = Color(0xFF81C784);
  static const lightShadow = Color(0xFF000000);
  static const lightSurface = Color(0xFFF8F9FA);
  static const lightOnSurface = Color(0xFF1A1A1A);
  static const lightAppBarBackground = Color(0xFFE8F5E8);

  // Circuit-specific colors
  static const circuitBoard = Color(0xFF2E3B2E);
  static const wirePowered = Color(0xFF4CAF50);
  static const wireUnpowered = Color(0xFF757575);
  static const componentActive = Color(0xFFFFC107);
  static const componentInactive = Color(0xFF9E9E9E);
  static const gridLines = Color(0xFFE0E0E0);
}

class DarkModeColors {
  static const darkPrimary = Color(0xFF81C784);
  static const darkOnPrimary = Color(0xFF1B5E20);
  static const darkPrimaryContainer = Color(0xFF2E7D32);
  static const darkOnPrimaryContainer = Color(0xFFE8F5E8);
  static const darkSecondary = Color(0xFF64B5F6);
  static const darkOnSecondary = Color(0xFF0D47A1);
  static const darkSecondaryContainer = Color(0xFF1565C0); // Added
  static const darkTertiary = Color(0xFFFFAB40);
  static const darkOnTertiary = Color(0xFFE65100);
  static const darkError = Color(0xFFEF5350);
  static const darkOnError = Color(0xFF8B0000);
  static const darkErrorContainer = Color(0xFFB71C1C);
  static const darkOnErrorContainer = Color(0xFFB71C1C);
  static const darkInversePrimary = Color(0xFF2E7D32);
  static const darkShadow = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkOnSurface = Color(0xFFE0E0E0);
  static const darkAppBarBackground = Color(0xFF1B1B1B);

  // Circuit-specific colors for dark mode
  static const circuitBoard = Color(0xFF1A1A1A);
  static const wirePowered = Color(0xFF66BB6A);
  static const wireUnpowered = Color(0xFF616161);
  static const componentActive = Color(0xFFFFD54F);
  static const componentInactive = Color(0xFF757575);
  static const gridLines = Color(0xFF303030);
}

class AppGradients {
  static const LinearGradient mainMenuBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      LightModeColors.lightPrimaryContainer,
      LightModeColors.lightSurface,
      LightModeColors.lightSecondaryContainer,
    ],
  );

  static const LinearGradient levelSelectBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      LightModeColors.lightPrimaryContainer,
      LightModeColors.lightSurface,
    ],
  );
}

extension CustomTextStyles on TextTheme {
  TextStyle? get appTitle => headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      );

  TextStyle? get sectionTitle => titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      );

  TextStyle? get bodyTextSecondary => bodyMedium?.copyWith(
        color: const Color(0xFF616161), // A neutral gray for secondary text
        height: 1.4,
      );

  TextStyle? get bodyTextSmallSecondary => bodySmall?.copyWith(
        color: const Color(0xFF616161), // A neutral gray for secondary text
      );
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: LightModeColors.lightPrimary,
        onPrimary: LightModeColors.lightOnPrimary,
        primaryContainer: LightModeColors.lightPrimaryContainer,
        onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
        secondary: LightModeColors.lightSecondary,
        onSecondary: LightModeColors.lightOnSecondary,
        tertiary: LightModeColors.lightTertiary,
        onTertiary: LightModeColors.lightOnTertiary,
        error: LightModeColors.lightError,
        onError: LightModeColors.lightOnError,
        errorContainer: LightModeColors.lightErrorContainer,
        onErrorContainer: LightModeColors.lightOnErrorContainer,
        inversePrimary: LightModeColors.lightInversePrimary,
        shadow: LightModeColors.lightShadow,
        surface: LightModeColors.lightSurface,
        onSurface: LightModeColors.lightOnSurface,
      ),
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: LightModeColors.lightAppBarBackground,
        foregroundColor: LightModeColors.lightOnPrimaryContainer,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: LightModeColors.lightOnPrimary,
          backgroundColor: LightModeColors.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LightModeColors.lightPrimary,
          side: const BorderSide(color: LightModeColors.lightPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LightModeColors.lightOnSurface,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: FontSizes.displayLarge,
          fontWeight: FontWeight.normal,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: FontSizes.displayMedium,
          fontWeight: FontWeight.normal,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: FontSizes.displaySmall,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: FontSizes.headlineLarge,
          fontWeight: FontWeight.normal,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: FontSizes.headlineMedium,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: FontSizes.headlineSmall,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: FontSizes.titleLarge,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: FontSizes.titleMedium,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: FontSizes.titleSmall,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: FontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: FontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: FontSizes.labelSmall,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: FontSizes.bodyLarge,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: FontSizes.bodyMedium,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: FontSizes.bodySmall,
          fontWeight: FontWeight.normal,
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: DarkModeColors.darkPrimary,
        onPrimary: DarkModeColors.darkOnPrimary,
        primaryContainer: DarkModeColors.darkPrimaryContainer,
        onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
        secondary: DarkModeColors.darkSecondary,
        onSecondary: DarkModeColors.darkOnSecondary,
        tertiary: DarkModeColors.darkTertiary,
        onTertiary: DarkModeColors.darkOnTertiary,
        error: DarkModeColors.darkError,
        onError: DarkModeColors.darkOnError,
        errorContainer: DarkModeColors.darkErrorContainer,
        onErrorContainer: DarkModeColors.darkOnErrorContainer,
        inversePrimary: DarkModeColors.darkInversePrimary,
        shadow: DarkModeColors.darkShadow,
        surface: DarkModeColors.darkSurface,
        onSurface: DarkModeColors.darkOnSurface,
      ),
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkModeColors.darkAppBarBackground,
        foregroundColor: DarkModeColors.darkOnPrimaryContainer,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: DarkModeColors.darkOnPrimary,
          backgroundColor: DarkModeColors.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DarkModeColors.darkPrimary,
          side: const BorderSide(color: DarkModeColors.darkPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DarkModeColors.darkOnSurface,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: FontSizes.displayLarge,
          fontWeight: FontWeight.normal,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: FontSizes.displayMedium,
          fontWeight: FontWeight.normal,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: FontSizes.displaySmall,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: FontSizes.headlineLarge,
          fontWeight: FontWeight.normal,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: FontSizes.headlineMedium,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: FontSizes.headlineSmall,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: FontSizes.titleLarge,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: FontSizes.titleMedium,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: FontSizes.titleSmall,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: FontSizes.labelLarge,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: FontSizes.labelMedium,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: FontSizes.labelSmall,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: FontSizes.bodyLarge,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: FontSizes.bodyMedium,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: FontSizes.bodySmall,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
