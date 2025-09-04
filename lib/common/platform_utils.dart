import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformUtils {
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  // Device capability detection
  static bool get isHighEndDevice {
    // This would be expanded with actual device detection
    // For now, use screen size and pixel ratio as proxy
    final pixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final screenSize = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    final width = screenSize.width / pixelRatio;
        // final height = screenSize.height / pixelRatio;

    // Consider devices with screen width > 400dp and pixel ratio > 2.5 as high-end
    return width > 400 && pixelRatio > 2.5;
  }

  static bool get isLowEndDevice => !isHighEndDevice;

  // Platform-specific rendering adjustments
  static double get platformBlurMultiplier {
    if (isIOS) return 0.8; // iOS Metal handles blur differently
    if (isAndroid) return 1.0; // Android OpenGL baseline
    return 1.0;
  }

  static Color getPlatformAdjustedColor(Color color) {
    if (isIOS) {
      // iOS color adjustments for Metal rendering
      return Color.fromRGBO(
        (color.r * 0.95).round().clamp(0, 255),
        (color.g * 0.95).round().clamp(0, 255),
        (color.b * 0.95).round().clamp(0, 255),
        color.a,
      );
    }
    return color;
  }

  // Memory management hints
  static bool get shouldConserveMemory {
    // Low-end devices or when memory pressure is detected
    return isLowEndDevice;
  }

  // Animation performance hints
  static bool get supportsComplexAnimations {
    return isHighEndDevice && !shouldConserveMemory;
  }

  // Gesture handling preferences
  static bool get prefersPreciseGestures {
    return isIOS; // iOS users expect precise gesture handling
  }

  static bool get allowsSloppyGestures {
    return isAndroid; // Android users are more tolerant of imprecise gestures
  }
}