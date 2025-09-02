import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class ColorContrast {
  // Calculate contrast ratio between two colors
  static double ratio(Color foreground, Color background) {
    final double l1 = _relativeLuminance(foreground);
    final double l2 = _relativeLuminance(background);

    final double lighter = max(l1, l2);
    final double darker = min(l1, l2);

    return (lighter + 0.05) / (darker + 0.05);
  }

  // Calculate relative luminance of a color
  static double _relativeLuminance(Color color) {
    double toLinear(double channel) {
      channel = channel / 255.0;
      return channel <= 0.03928
          ? channel / 12.92
          : pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    final r = toLinear(color.red.toDouble());
    final g = toLinear(color.green.toDouble());
    final b = toLinear(color.blue.toDouble());

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  // Get a contrasting color for a given background
  static Color getContrastingColor(Color background) {
    final brightness = _relativeLuminance(background);
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  // Validate if a color combination meets WCAG standards
  static bool meetsWCAGStandard(Color foreground, Color background, {bool isLargeText = false}) {
    final contrastRatio = ratio(foreground, background);
    final minRatio = isLargeText ? 3.0 : 4.5; // AA standard
    return contrastRatio >= minRatio;
  }

  // Get accessible color alternatives
  static List<Color> getAccessibleAlternatives(Color original, Color background) {
    final alternatives = <Color>[];

    // Try different shades
    for (double factor = 0.1; factor <= 0.9; factor += 0.1) {
      final lighter = Color.fromRGBO(
        (original.red + (255 - original.red) * factor).round().clamp(0, 255),
        (original.green + (255 - original.green) * factor).round().clamp(0, 255),
        (original.blue + (255 - original.blue) * factor).round().clamp(0, 255),
        original.opacity,
      );

      final darker = Color.fromRGBO(
        (original.red * (1 - factor)).round().clamp(0, 255),
        (original.green * (1 - factor)).round().clamp(0, 255),
        (original.blue * (1 - factor)).round().clamp(0, 255),
        original.opacity,
      );

      if (meetsWCAGStandard(lighter, background)) {
        alternatives.add(lighter);
      }
      if (meetsWCAGStandard(darker, background)) {
        alternatives.add(darker);
      }
    }

    return alternatives;
  }
}