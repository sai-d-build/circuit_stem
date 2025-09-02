import 'dart:ui';
import 'package:flutter/material.dart';
import 'color_contrast.dart';

class AccessibilityManager {
  static final AccessibilityManager _instance = AccessibilityManager._internal();
  factory AccessibilityManager() => _instance;
  AccessibilityManager._internal();

  // Accessibility preferences
  bool _isHighContrastMode = false;
  bool _isReducedMotion = false;
  bool _isScreenReaderEnabled = false;

  // Getters
  static bool get isHighContrastMode => _instance._isHighContrastMode;
  static bool get isReducedMotion => _instance._isReducedMotion;
  static bool get isScreenReaderEnabled => _instance._isScreenReaderEnabled;

  // Setters
  static set isHighContrastMode(bool value) {
    _instance._isHighContrastMode = value;
  }

  static set isReducedMotion(bool value) {
    _instance._isReducedMotion = value;
  }

  static set isScreenReaderEnabled(bool value) {
    _instance._isScreenReaderEnabled = value;
  }

  // Color utilities
  static Color getAccessibleColor(Color originalColor) {
    if (_instance._isHighContrastMode) {
      return _getHighContrastAlternative(originalColor);
    }
    return originalColor;
  }

  static Color _getHighContrastAlternative(Color color) {
    // Convert to high contrast equivalents
    if (_isBrightColor(color)) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  static bool _isBrightColor(Color color) {
    // Calculate perceived brightness
    final double brightness = (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) / 255;
    return brightness > 0.5;
  }

  // Motion utilities
  static Duration getAccessibleDuration(Duration originalDuration) {
    if (_instance._isReducedMotion) {
      return originalDuration * 0.1; // Much faster for reduced motion
    }
    return originalDuration;
  }

  // Contrast validation
  static bool meetsContrastRatio(Color foreground, Color background) {
    return ColorContrast.ratio(foreground, background) >= 4.5;
  }

  static Color getContrastingColor(Color background) {
    return ColorContrast.getContrastingColor(background);
  }

  // Initialize from system settings
  static Future<void> initializeFromSystem(BuildContext context) async {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    _instance._isHighContrastMode = platformBrightness == Brightness.dark;

    // Check for screen reader (this is a simplified check)
    // In a real implementation, you'd use platform-specific APIs
    _instance._isScreenReaderEnabled = false; // Placeholder
  }
}