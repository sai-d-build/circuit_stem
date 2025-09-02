import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _lightCircuitColors = CircuitColorScheme(
    primary: Color(0xFF1E88E5), // Electric Blue
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE3F2FD),
    onPrimaryContainer: Color(0xFF0D47A1),
    secondary: Color(0xFF43A047), // Circuit Green
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFFFF8F00), // Resistor Orange
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F), // Warning Red
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFFB71C1C),
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1C1C1C),
    surfaceContainer: Color(0xFFEFEFEF),
    onSurfaceVariant: Color(0xFF424242),
    shadow: Color(0xFF000000),
    outline: Color(0xFFBDBDBD),
    // Circuit-specific colors
    wireActive: Color(0xFF00E676),
    wireInactive: Color(0xFF616161),
    componentBase: Color(0xFF2196F3),
    gridLine: Color(0xFFE0E0E0),
    glowEffect: Color(0xFF00E5FF),
    // Neon colors
    neonPrimary: Color(0xFF00FFFF), // Electric Cyan
    neonAccent: Color(0xFFFF00FF), // Neon Magenta
    errorGlow: Color(0xFFFF0040), // Neon Red
    energyPulse: Color(0xFF39FF14), // Bright Green
    highlightAccent: Color(0xFFFFFF00), // Yellow
  );

  static const _darkCircuitColors = CircuitColorScheme(
    primary: Color(0xFF90CAF9), // Brighter Electric Blue
    onPrimary: Color(0xFF0D47A1),
    primaryContainer: Color(0xFF1565C0),
    onPrimaryContainer: Color(0xFFE3F2FD),
    secondary: Color(0xFF81C784), // Brighter Circuit Green
    onSecondary: Color(0xFF1B5E20),
    tertiary: Color(0xFFFFB74D), // Brighter Resistor Orange
    onTertiary: Color(0xFFE65100),
    error: Color(0xFFEF5350), // Brighter Warning Red
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFD32F2F),
    onErrorContainer: Color(0xFFFFCDD2),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    surfaceContainer: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFFBDBDBD),
    shadow: Color(0xFF000000),
    outline: Color(0xFF424242),
    // Circuit-specific colors
    wireActive: Color(0xFF00FF88),
    wireInactive: Color(0xFF757575),
    componentBase: Color(0xFF42A5F5),
    gridLine: Color(0xFF424242),
    glowEffect: Color(0xFF00E5FF),
    // Neon colors
    neonPrimary: Color(0xFF00FFFF), // Electric Cyan
    neonAccent: Color(0xFFFF00FF), // Neon Magenta
    errorGlow: Color(0xFFFF0040), // Neon Red
    energyPulse: Color(0xFF39FF14), // Bright Green
    highlightAccent: Color(0xFFFFFF00), // Yellow
  );

  static const _highContrastColors = CircuitColorScheme(
    primary: Color(0xFF000000),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFF000000),
    secondary: Color(0xFF000000),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF000000),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFFF0000),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF000000),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    surfaceContainer: Color(0xFFE0E0E0),
    onSurfaceVariant: Color(0xFF000000),
    shadow: Color(0xFF000000),
    outline: Color(0xFF000000),
    // Circuit-specific colors
    wireActive: Color(0xFF00FF00),
    wireInactive: Color(0xFF808080),
    componentBase: Color(0xFF0000FF),
    gridLine: Color(0xFF000000),
    glowEffect: Color(0xFF00FFFF),
    // Neon colors
    neonPrimary: Color(0xFF00FFFF), // Electric Cyan
    neonAccent: Color(0xFFFF00FF), // Neon Magenta
    errorGlow: Color(0xFFFF0040), // Neon Red
    energyPulse: Color(0xFF39FF14), // Bright Green
    highlightAccent: Color(0xFFFFFF00), // Yellow
  );

  static ThemeData get lightTheme => _buildTheme(_lightCircuitColors, Brightness.light);
  static ThemeData get darkTheme => _buildTheme(_darkCircuitColors, Brightness.dark);
  static ThemeData get highContrastTheme => _buildTheme(_highContrastColors, Brightness.light);

  static ThemeData _buildTheme(CircuitColorScheme colors, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      onSurfaceVariant: colors.onSurfaceVariant,
      shadow: colors.shadow,
      outline: colors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.onPrimaryContainer,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: colors.shadow.withValues(alpha: 0.3),
        surfaceTintColor: colors.primary.withValues(alpha: 0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: colors.shadow.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        highlightElevation: 8,
        shape: const CircleBorder(),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      extensions: [colors],
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      displaySmall: GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class CircuitColorScheme extends ThemeExtension<CircuitColorScheme> {
  const CircuitColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainer,
    required this.onSurfaceVariant,
    required this.shadow,
    required this.outline,
    required this.wireActive,
    required this.wireInactive,
    required this.componentBase,
    required this.gridLine,
    required this.glowEffect,
    required this.neonPrimary,
    required this.neonAccent,
    required this.errorGlow,
    required this.energyPulse,
    required this.highlightAccent,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainer;
  final Color onSurfaceVariant;
  final Color shadow;
  final Color outline;
  
  // Circuit-specific colors
  final Color wireActive;
  final Color wireInactive;
  final Color componentBase;
  final Color gridLine;
  final Color glowEffect;

  // Neon colors
  final Color neonPrimary;
  final Color neonAccent;
  final Color errorGlow;
  final Color energyPulse;
  final Color highlightAccent;

  @override
  CircuitColorScheme copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? tertiary,
    Color? onTertiary,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainer,
    Color? onSurfaceVariant,
    Color? shadow,
    Color? outline,
    Color? wireActive,
    Color? wireInactive,
    Color? componentBase,
    Color? gridLine,
    Color? glowEffect,
    Color? neonPrimary,
    Color? neonAccent,
    Color? errorGlow,
    Color? energyPulse,
    Color? highlightAccent,
  }) {
    return CircuitColorScheme(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      shadow: shadow ?? this.shadow,
      outline: outline ?? this.outline,
      wireActive: wireActive ?? this.wireActive,
      wireInactive: wireInactive ?? this.wireInactive,
      componentBase: componentBase ?? this.componentBase,
      gridLine: gridLine ?? this.gridLine,
      glowEffect: glowEffect ?? this.glowEffect,
      neonPrimary: neonPrimary ?? this.neonPrimary,
      neonAccent: neonAccent ?? this.neonAccent,
      errorGlow: errorGlow ?? this.errorGlow,
      energyPulse: energyPulse ?? this.energyPulse,
      highlightAccent: highlightAccent ?? this.highlightAccent,
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
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      wireActive: Color.lerp(wireActive, other.wireActive, t)!,
      wireInactive: Color.lerp(wireInactive, other.wireInactive, t)!,
      componentBase: Color.lerp(componentBase, other.componentBase, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      glowEffect: Color.lerp(glowEffect, other.glowEffect, t)!,
      neonPrimary: Color.lerp(neonPrimary, other.neonPrimary, t)!,
      neonAccent: Color.lerp(neonAccent, other.neonAccent, t)!,
      errorGlow: Color.lerp(errorGlow, other.errorGlow, t)!,
      energyPulse: Color.lerp(energyPulse, other.energyPulse, t)!,
      highlightAccent: Color.lerp(highlightAccent, other.highlightAccent, t)!,
    );
  }
}