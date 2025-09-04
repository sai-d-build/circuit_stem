// App theme configuration for SparkCircuit educational gaming platform
// Defines colors, typography, and visual styling

import 'package:flutter/material.dart';

class AppTheme {
  // Primary color palette
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFFFC107);
  static const Color secondaryVariant = Color(0xFFFF8F00);

  // Educational color scheme
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Circuit component colors
  static const Color batteryColor = Color(0xFF4CAF50);
  static const Color resistorColor = Color(0xFF9C27B0);
  static const Color capacitorColor = Color(0xFFFF5722);
  static const Color inductorColor = Color(0xFF3F51B5);
  static const Color diodeColor = Color(0xFFE91E63);
  static const Color transistorColor = Color(0xFF607D8B);
  static const Color switchColor = Color(0xFF795548);
  static const Color bulbColor = Color(0xFFFFEB3B);
  static const Color wireColor = Color(0xFF9E9E9E);

  // Background colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color canvasBackground = Color(0xFFF5F5F5);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Grid and UI colors
  static const Color gridLineColor = Color(0xFFE0E0E0);
  static const Color gridHighlightColor = Color(0xFFBBDEFB);
  static const Color selectionColor = Color(0xFF90CAF9);

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Border radius
  static const double smallBorderRadius = 4.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;

  // Shadows
  static const BoxShadow lightShadow = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x29000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryVariant,
        secondary: secondaryColor,
        secondaryContainer: secondaryVariant,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      // Component themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(mediumBorderRadius),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumBorderRadius),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallBorderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),

      // Custom properties for educational gaming
      extensions: [
        CircuitColorScheme.light(),
      ],
    );
  }

  // Dark theme (for future implementation)
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      extensions: [
        CircuitColorScheme.dark(),
      ],
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color(0xFF121212),
      ),
    );
  }
}

@immutable
class CircuitColorScheme extends ThemeExtension<CircuitColorScheme> {
  // Standard Palette
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color error;
  final Color onError;
  final Color surface;
  final Color onSurface;
  final Color outline;
  
  // Neon Palette
  final Color neonPrimary;
  final Color neonAccent;
  final Color errorGlow;
  final Color energyPulse;
  final Color highlightAccent;

  // Functional Colors
  final Color wireActive;
  final Color wireInactive;
  final Color componentBase;
  final Color gridLine;
  final Color glowEffect;

  const CircuitColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.error,
    required this.onError,
    required this.surface,
    required this.onSurface,
    required this.outline,
    required this.neonPrimary,
    required this.neonAccent,
    required this.errorGlow,
    required this.energyPulse,
    required this.highlightAccent,
    required this.wireActive,
    required this.wireInactive,
    required this.componentBase,
    required this.gridLine,
    required this.glowEffect,
  });

  factory CircuitColorScheme.light() {
    return const CircuitColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFC107),
      onSecondary: Colors.black,
      error: Color(0xFFF44336),
      onError: Colors.white,
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF212121),
      outline: Color(0xFFBDBDBD),
      neonPrimary: Color(0xFF00FFFF), // Electric Cyan
      neonAccent: Color(0xFFFF00FF), // Neon Magenta
      errorGlow: Color(0xFFFF0040), // Neon Red
      energyPulse: Color(0xFF39FF14), // Bright Green
      highlightAccent: Color(0xFFFFFF00), // Yellow
      wireActive: Color(0xFF00E676),
      wireInactive: Color(0xFF616161),
      componentBase: Color(0xFF2196F3),
      gridLine: Color(0xFFE0E0E0),
      glowEffect: Color(0xFF00E5FF),
    );
  }

  factory CircuitColorScheme.dark() {
    return const CircuitColorScheme(
      primary: Color(0xFF2196F3),
      onPrimary: Colors.white,
      secondary: Color(0xFFFFC107),
      onSecondary: Colors.black,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE0E0E0),
      outline: Color(0xFF424242),
      neonPrimary: Color(0xFF00FFFF), // Electric Cyan
      neonAccent: Color(0xFFFF00FF), // Neon Magenta
      errorGlow: Color(0xFFFF0040), // Neon Red
      energyPulse: Color(0xFF39FF14), // Bright Green
      highlightAccent: Color(0xFFFFFF00), // Yellow
      wireActive: Color(0xFF39FF14),
      wireInactive: Color(0xFF757575),
      componentBase: Color(0xFF0D47A1),
      gridLine: Color(0xFF303030),
      glowEffect: Color(0xFF00E5FF),
    );
  }

  @override
  CircuitColorScheme copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? error,
    Color? onError,
    Color? surface,
    Color? onSurface,
    Color? outline,
    Color? neonPrimary,
    Color? neonAccent,
    Color? errorGlow,
    Color? energyPulse,
    Color? highlightAccent,
    Color? wireActive,
    Color? wireInactive,
    Color? componentBase,
    Color? gridLine,
    Color? glowEffect,
  }) {
    return CircuitColorScheme(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      outline: outline ?? this.outline,
      neonPrimary: neonPrimary ?? this.neonPrimary,
      neonAccent: neonAccent ?? this.neonAccent,
      errorGlow: errorGlow ?? this.errorGlow,
      energyPulse: energyPulse ?? this.energyPulse,
      highlightAccent: highlightAccent ?? this.highlightAccent,
      wireActive: wireActive ?? this.wireActive,
      wireInactive: wireInactive ?? this.wireInactive,
      componentBase: componentBase ?? this.componentBase,
      gridLine: gridLine ?? this.gridLine,
      glowEffect: glowEffect ?? this.glowEffect,
    );
  }

  @override
  CircuitColorScheme lerp(ThemeExtension<CircuitColorScheme>? other, double t) {
    if (other is! CircuitColorScheme) {
      return this;
    }
    return CircuitColorScheme(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      neonPrimary: Color.lerp(neonPrimary, other.neonPrimary, t)!,
      neonAccent: Color.lerp(neonAccent, other.neonAccent, t)!,
      errorGlow: Color.lerp(errorGlow, other.errorGlow, t)!,
      energyPulse: Color.lerp(energyPulse, other.energyPulse, t)!,
      highlightAccent: Color.lerp(highlightAccent, other.highlightAccent, t)!,
      wireActive: Color.lerp(wireActive, other.wireActive, t)!,
      wireInactive: Color.lerp(wireInactive, other.wireInactive, t)!,
      componentBase: Color.lerp(componentBase, other.componentBase, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      glowEffect: Color.lerp(glowEffect, other.glowEffect, t)!,
    );
  }
}

// Enums for type safety (these would normally be imported from domain entities)
enum ComponentType {
  battery,
  resistor,
  capacitor,
  inductor,
  diode,
  transistor,
  switch_,
  bulb,
  buzzer,
  timer,
  wire,
  ground,
}

enum LevelDifficulty {
  tutorial,
  beginner,
  intermediate,
  advanced,
  expert,
}