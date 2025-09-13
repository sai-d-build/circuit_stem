/// Game constants for the Circuit STEM application
/// This file contains all the constants used throughout the game for consistent rendering and behavior
library;

import 'package:flutter/material.dart';

class GameConstants {
  // Grid and cell dimensions
  static const double gridCellSize = 60;
  static const double componentWidth = 50;
  static const double componentHeight = 50;

  // Border and radius constants
  static const double componentBorderRadius = 8;
  static const double gridBoundsOffset = 100;

  // Stroke widths
  static const double normalStroke = 1;
  static const double thickStroke = 2;
  static const double extraThickStroke = 3;
  static const double gridLineStroke = 0.5;
  static const double majorGridStroke = 1.5;

  // Opacity values
  static const double lowOpacity = 0.3;
  static const double mediumOpacity = 0.6;
  static const double highOpacity = 0.8;

  // Glow and effect constants
  static const double glowRadius = 8;
  static const double selectionGlowRadius = 12;
  static const double wireGlowRadius = 6;

  // Grid intervals
  static const int majorGridInterval = 5;

  // Mathematical constants
  static const double piRadians = 3.141592653589793;

  // Animation durations (in milliseconds)
  static const int componentFadeDuration = 300;
  static const int wireAnimationDuration = 200;

  // Component limits
  static const int maxComponentsPerLevel = 50;
  static const int maxWireLength = 20;

  // UI spacing
  static const double componentSpacing = 10;
  static const double palettePadding = 16;
}

/// UI constants for consistent styling across the application
class UIConstants {
  // Font sizes
  static const double smallFontSize = 12;
  static const double normalFontSize = 14;
  static const double largeFontSize = 18;
  static const double extraLargeFontSize = 24;

  // Spacing
  static const double smallSpacing = 8;
  static const double normalSpacing = 16;
  static const double largeSpacing = 24;
  static const double extraLargeSpacing = 32;
  static const double standardSpacing = 16;

  // Border radius
  static const double smallBorderRadius = 4;
  static const double normalBorderRadius = 8;
  static const double largeBorderRadius = 16;

  // Elevation
  static const double lowElevation = 2;
  static const double normalElevation = 4;
  static const double highElevation = 8;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Icon sizes
  static const double smallIconSize = 16;
  static const double normalIconSize = 24;
  static const double largeIconSize = 32;

  // Wire thickness
  static const double wireThickness = 2;

  // Grid layout
  static const int levelGridCrossAxisCount = 3;
  static const double levelGridAspectRatio = 1.2;

  // HUD padding
  static const double progressHudHorizontalPadding = 16;
  static const double progressHudVerticalPadding = 8;
  static const double progressHudSpacing = 12;

  // Standard insets
  static const EdgeInsets standardInsets = EdgeInsets.all(16);
}
