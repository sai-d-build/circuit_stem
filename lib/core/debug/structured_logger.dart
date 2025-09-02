// lib/core/debug/structured_logger.dart
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:io' as io show stdout, Platform;
import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/debug/debug_overlay.dart';
import 'package:sparkcircuit/core/performance/performance_monitor.dart';

// TEMPORARY: Keeping old logger methods for backward compatibility
class Logger {
  static bool get enableDebug => true;

  static void log(String message) {
    if (enableDebug) {
      StructuredLogger.log(StructuredLogger.levelInfo, message);
    }
  }

  static void debug(String message) {
    if (enableDebug) {
      StructuredLogger.log(StructuredLogger.levelDebug, message);
    }
  }

  static void error(String message) {
    StructuredLogger.log(StructuredLogger.levelError, message);
  }

  static void warn(String message) {
    StructuredLogger.log(StructuredLogger.levelWarning, message);
  }
}

/// Enhanced logging system with contextual data and conditional compilation
class StructuredLogger {
  static bool _isEnabled = true;

  /// Configuration
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static bool get isEnabled => _isEnabled;

  /// Log levels for structured logging
  static const String levelTrace = 'TRACE';
  static const String levelDebug = 'DEBUG';
  static const String levelInfo = 'INFO';
  static const String levelWarning = 'WARNING';
  static const String levelError = 'ERROR';
  static const String levelFatal = 'FATAL';

  /// Core logging methods with context
  static void log(String level, String message, {Map<String, dynamic>? context, Object? error}) {
    if (!_isEnabled) return;

    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' | Context: $context' : '';
    final errorStr = error != null ? ' | Error: $error' : '';

    final logMessage = '[$level] $timestamp - $message$contextStr$errorStr';

    // Debug print only in development mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      io.stdout.writeln(logMessage);
    }
  }

  static void trace(String message, {Map<String, dynamic>? context, Object? error}) {
    return log(levelTrace, message, context: context, error: error);
  }

  static void debug(String message, {Map<String, dynamic>? context, Object? error}) {
    return log(levelDebug, message, context: context, error: error);
  }

  static void info(String message, {Map<String, dynamic>? context, Object? error}) {
    return log(levelInfo, message, context: context, error: error);
  }

  static void warning(String message, {Map<String, dynamic>? context, Object? error}) {
    return log(levelWarning, message, context: context, error: error);
  }

  static void error(String message, {Map<String, dynamic>? context, Object? error}) {
    return log(levelError, message, context: context, error: error);
  }

  static void fatal(String message, {Map<String, dynamic>? context, Object? error}) {
    return log(levelFatal, message, context: context, error: error);
  }
}

/// Game-specific constants extracted from magic numbers
abstract class GameConstants {
  // 🎮 GAME PHYSICS CONSTANTS
  static const double gridCellSize = 60.0;
  static const double componentSnapDistance = 0.8;
  static const double snapThreshold = 0.8;
  static const double rotationStepDegrees = 90.0;
  static const double piRadians = 3.141592653589793;

  // 🎨 COMPONENT DIMENSIONS
  static const double componentWidth = 60.0;
  static const double componentHeight = 60.0;
  static const double halfComponentSize = 30.0;
  static const Size defaultComponentSize = Size(60, 60);
  static const double componentBorderRadius = 8.0;

  // 🎯 INTERACTION CONSTANTS
  static const double dragDistanceThreshold = 10.0;
  static const double tapThreshold = 10.0;
  static const double longPressThreshold = 500;
  static const Duration longPressDuration = Duration(milliseconds: 500);

  // 🌟 VISUAL EFFECTS
  static const double glowRadius = 12.0;
  static const double wireGlowRadius = 20.0;
  static const double selectionGlowRadius = 8.0;

  // ⚡ PERFORMANCE THRESHOLDS
  static const double targetFrameTime = 16.67; // 60fps
  static const double poorPerformanceThreshold = 25.0;
  static const double goodPerformanceThreshold = 16.67;
  static const int maxPerformanceFrameSamples = 60;

  // 🔄 ANIMATION CONSTANTS
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration celebrationAnimation = Duration(milliseconds: 800);

  // 🎭 UI DIMENSIONS
  static const double iconSize = 20.0;
  static const double largeIconSize = 24.0;
  static const double extraLargeIconSize = 48.0;
  static const double dragPreviewOffset = 25.0;

  // 📍 GRID CONSTANTS
  static const int defaultGridRows = 8;
  static const int defaultGridCols = 10;
  static const double gridOriginOffset = 20.0;
  static const double panBoundary = 50.0;
  static const double gridBoundsOffset = 1.0;
  static const int majorGridInterval = 5;

  // 🔧 GRID STROKE WIDTHS
  static const double gridLineStroke = 0.5;
  static const double majorGridStroke = 1.0;

  // 📶 CIRCUIT PROPERTIES (DOMAIN-SPECIFIC)
  static const double defaultBatteryVoltage = 9.0;
  static const double batteryInternalResistance = 0.1;
  static const double defaultResistorResistance = 1000.0;
  static const double resistorTolerance = 0.05;
  static const double ledForwardVoltage = 2.0;

  // 🔧 STROKE WIDTHS
  static const double thinStroke = 1.0;
  static const double normalStroke = 1.5;
  static const double thickStroke = 2.0;
  static const double extraThickStroke = 3.0;

  // 🟦 OPACITY VALUES
  static const double lowOpacity = 0.3;
  static const double mediumOpacity = 0.5;
  static const double highOpacity = 0.7;
  static const double veryHighOpacity = 0.8;
  static const double fullOpacity = 1.0;

  // 🎯 TOLERANCE VALUES
  static const double positionTolerance = 0.1;
  static const double currentTolerance = 0.01;
  static const double validationTolerance = 0.01;
}

// Component-specific constants
abstract class ComponentConstants {
  // Battery Rendering
  static const double batteryTerminalSpacing = 0.25;
  static const double batteryPositiveBarLength = 0.66;
  static const double batteryNegativeBarLength = 0.66;

  // Resistor Symbol proportions
  static const int resistorZigzagCount = 4;
  static const double resistorZigzagAmplitude = 0.25;

  // LED Symbol proportions
  static const double ledTriangleRatio = 0.3;
  static const int ledRays = 3;

  // Capacitor plate spacing
  static const double capacitorPlateOffset = 0.166;
  static const double capacitorContactSize = 2.5;
}

// UI-specific constants
abstract class UIConstants {
  // Card Dimensions & Spacing
  static const double cardBorderRadius = 12.0;
  static const double standardMargin = 16.0;
  static const double standardPadding = 16.0;
  static const double standardSpacing = 16.0;
  static const EdgeInsets cardInsets = EdgeInsets.all(16);
  static const EdgeInsets standardInsets = EdgeInsets.all(16);

  // Menu Button Sizing
  static const double menuButtonHeight = 50.0;
  static const double menuButtonBorderRadius = 12.0;

  // Drawing Parameters
  static const double wireThickness = 4.0;
  static const double connectionPointRadius = 6.0;

  // Shadow Parameters
  static const double shadowBlurRadius = 24.0;
  static const double shadowOffsetY = 8.0;
  static const Offset shadowOffset = Offset(0, 8);

  // Grid Layout Constants
  static const int levelGridCrossAxisCount = 2;
  static const double levelGridAspectRatio = 1.2;

  // Button/Icon Sizing
  static const double iconSizeMedium = 16.0;
  static const double iconSizeLarge = 20.0;
  static const double iconSizeExtraLarge = 24.0;
  static const double circularProgressSize = 20.0;

  // Progress HUD Spacing
  static const double progressHudHorizontalPadding = 16.0;
  static const double progressHudVerticalPadding = 8.0;
  static const double progressHudSpacing = 16.0;
  static const double starIndicatorSpacing = 2.0;
  static const double iconTextSpacing = 4.0;
  static const double glowBlurRadius = 5.0;
}