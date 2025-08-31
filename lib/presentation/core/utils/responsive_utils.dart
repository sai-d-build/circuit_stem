import 'package:flutter/material.dart';

/// Responsive design utilities for SparkCircuit
class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    if (width < desktopBreakpoint) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final type = getScreenType(context);
    return type == ScreenType.tablet;
  }

  /// Check if device is desktop or larger
  static bool isDesktop(BuildContext context) {
    final type = getScreenType(context);
    return type == ScreenType.desktop || type == ScreenType.largeDesktop;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return const EdgeInsets.all(8);
      case ScreenType.tablet:
        return const EdgeInsets.all(12);
      case ScreenType.desktop:
        return const EdgeInsets.all(16);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(24);
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {double base = 8}) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return base * 0.75;
      case ScreenType.tablet:
        return base;
      case ScreenType.desktop:
        return base * 1.25;
      case ScreenType.largeDesktop:
        return base * 1.5;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return baseSize * 0.9;
      case ScreenType.tablet:
        return baseSize;
      case ScreenType.desktop:
        return baseSize * 1.1;
      case ScreenType.largeDesktop:
        return baseSize * 1.2;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return baseSize * 0.8;
      case ScreenType.tablet:
        return baseSize;
      case ScreenType.desktop:
        return baseSize * 1.2;
      case ScreenType.largeDesktop:
        return baseSize * 1.4;
    }
  }

  /// Get responsive component size
  static double getResponsiveComponentSize(BuildContext context, double baseSize) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return baseSize * 0.8;
      case ScreenType.tablet:
        return baseSize;
      case ScreenType.desktop:
        return baseSize * 1.2;
      case ScreenType.largeDesktop:
        return baseSize * 1.4;
    }
  }

  /// Get responsive palette height
  static double getPaletteHeight(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 100;
      case ScreenType.tablet:
        return 120;
      case ScreenType.desktop:
        return 140;
      case ScreenType.largeDesktop:
        return 160;
    }
  }

  /// Get responsive HUD height
  static double getHudHeight(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 60;
      case ScreenType.tablet:
        return 70;
      case ScreenType.desktop:
        return 80;
      case ScreenType.largeDesktop:
        return 90;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return isLandscape(context) ? 6 : 4;
      case ScreenType.tablet:
        return isLandscape(context) ? 8 : 6;
      case ScreenType.desktop:
        return 8;
      case ScreenType.largeDesktop:
        return 10;
    }
  }

  /// Get responsive aspect ratio for components
  static double getComponentAspectRatio(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 1.0;
      case ScreenType.tablet:
        return 1.2;
      case ScreenType.desktop:
        return 1.5;
      case ScreenType.largeDesktop:
        return 1.8;
    }
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Extension methods for responsive design
extension ResponsiveExtension on BuildContext {
  ScreenType get screenType => ResponsiveUtils.getScreenType(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  double responsiveSpacing([double base = 8]) => ResponsiveUtils.getResponsiveSpacing(this, base: base);
  double responsiveFontSize(double baseSize) => ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  double responsiveIconSize(double baseSize) => ResponsiveUtils.getResponsiveIconSize(this, baseSize);
  double responsiveComponentSize(double baseSize) => ResponsiveUtils.getResponsiveComponentSize(this, baseSize);
  double get paletteHeight => ResponsiveUtils.getPaletteHeight(this);
  double get hudHeight => ResponsiveUtils.getHudHeight(this);
  int get gridColumns => ResponsiveUtils.getGridColumns(this);
  double get componentAspectRatio => ResponsiveUtils.getComponentAspectRatio(this);
}