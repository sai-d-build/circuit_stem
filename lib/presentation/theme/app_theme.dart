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
        background: backgroundColor,
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
        EducationalThemeExtension(
          successColor: successColor,
          warningColor: warningColor,
          infoColor: infoColor,
          batteryColor: batteryColor,
          resistorColor: resistorColor,
          capacitorColor: capacitorColor,
          inductorColor: inductorColor,
          diodeColor: diodeColor,
          transistorColor: transistorColor,
          switchColor: switchColor,
          bulbColor: bulbColor,
          wireColor: wireColor,
          gridLineColor: gridLineColor,
          gridHighlightColor: gridHighlightColor,
          selectionColor: selectionColor,
          canvasBackground: canvasBackground,
        ),
      ],
    );
  }

  // Dark theme (for future implementation)
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
      ),
    );
  }

  // Utility methods
  static Color getComponentColor(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return batteryColor;
      case ComponentType.resistor:
        return resistorColor;
      case ComponentType.capacitor:
        return capacitorColor;
      case ComponentType.inductor:
        return inductorColor;
      case ComponentType.diode:
        return diodeColor;
      case ComponentType.transistor:
        return transistorColor;
      case ComponentType.switch_:
        return switchColor;
      case ComponentType.bulb:
        return bulbColor;
      case ComponentType.wire:
        return wireColor;
      default:
        return wireColor;
    }
  }

  static Color getDifficultyColor(LevelDifficulty difficulty) {
    switch (difficulty) {
      case LevelDifficulty.tutorial:
        return successColor;
      case LevelDifficulty.beginner:
        return infoColor;
      case LevelDifficulty.intermediate:
        return warningColor;
      case LevelDifficulty.advanced:
        return errorColor;
      case LevelDifficulty.expert:
        return secondaryColor;
    }
  }
}

// Educational theme extension for custom properties
class EducationalThemeExtension extends ThemeExtension<EducationalThemeExtension> {
  final Color successColor;
  final Color warningColor;
  final Color infoColor;
  final Color batteryColor;
  final Color resistorColor;
  final Color capacitorColor;
  final Color inductorColor;
  final Color diodeColor;
  final Color transistorColor;
  final Color switchColor;
  final Color bulbColor;
  final Color wireColor;
  final Color gridLineColor;
  final Color gridHighlightColor;
  final Color selectionColor;
  final Color canvasBackground;

  const EducationalThemeExtension({
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.batteryColor,
    required this.resistorColor,
    required this.capacitorColor,
    required this.inductorColor,
    required this.diodeColor,
    required this.transistorColor,
    required this.switchColor,
    required this.bulbColor,
    required this.wireColor,
    required this.gridLineColor,
    required this.gridHighlightColor,
    required this.selectionColor,
    required this.canvasBackground,
  });

  @override
  EducationalThemeExtension copyWith({
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? batteryColor,
    Color? resistorColor,
    Color? capacitorColor,
    Color? inductorColor,
    Color? diodeColor,
    Color? transistorColor,
    Color? switchColor,
    Color? bulbColor,
    Color? wireColor,
    Color? gridLineColor,
    Color? gridHighlightColor,
    Color? selectionColor,
    Color? canvasBackground,
  }) {
    return EducationalThemeExtension(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      batteryColor: batteryColor ?? this.batteryColor,
      resistorColor: resistorColor ?? this.resistorColor,
      capacitorColor: capacitorColor ?? this.capacitorColor,
      inductorColor: inductorColor ?? this.inductorColor,
      diodeColor: diodeColor ?? this.diodeColor,
      transistorColor: transistorColor ?? this.transistorColor,
      switchColor: switchColor ?? this.switchColor,
      bulbColor: bulbColor ?? this.bulbColor,
      wireColor: wireColor ?? this.wireColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      gridHighlightColor: gridHighlightColor ?? this.gridHighlightColor,
      selectionColor: selectionColor ?? this.selectionColor,
      canvasBackground: canvasBackground ?? this.canvasBackground,
    );
  }

  @override
  EducationalThemeExtension lerp(
    EducationalThemeExtension? other,
    double t,
  ) {
    if (other is! EducationalThemeExtension) {
      return this;
    }
    return EducationalThemeExtension(
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      batteryColor: Color.lerp(batteryColor, other.batteryColor, t)!,
      resistorColor: Color.lerp(resistorColor, other.resistorColor, t)!,
      capacitorColor: Color.lerp(capacitorColor, other.capacitorColor, t)!,
      inductorColor: Color.lerp(inductorColor, other.inductorColor, t)!,
      diodeColor: Color.lerp(diodeColor, other.diodeColor, t)!,
      transistorColor: Color.lerp(transistorColor, other.transistorColor, t)!,
      switchColor: Color.lerp(switchColor, other.switchColor, t)!,
      bulbColor: Color.lerp(bulbColor, other.bulbColor, t)!,
      wireColor: Color.lerp(wireColor, other.wireColor, t)!,
      gridLineColor: Color.lerp(gridLineColor, other.gridLineColor, t)!,
      gridHighlightColor: Color.lerp(gridHighlightColor, other.gridHighlightColor, t)!,
      selectionColor: Color.lerp(selectionColor, other.selectionColor, t)!,
      canvasBackground: Color.lerp(canvasBackground, other.canvasBackground, t)!,
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