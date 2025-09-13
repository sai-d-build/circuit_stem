import 'dart:math';
import 'package:flutter/material.dart';

class ColorContrast {
  // Calculate contrast ratio between two colors
  static double ratio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);

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

    final r = toLinear(((color.toARGB32() >> 16) & 0xFF).toDouble());
    final g = toLinear(((color.toARGB32() >> 8) & 0xFF).toDouble());
    final b = toLinear((color.toARGB32() & 0xFF).toDouble());

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  // Get a contrasting color for a given background
  static Color getContrastingColor(Color background) {
    final brightness = _relativeLuminance(background);
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  // Validate if a color combination meets WCAG standards
  static bool meetsWCAGStandard(Color foreground, Color background,
      {bool isLargeText = false}) {
    final contrastRatio = ratio(foreground, background);
    final minRatio = isLargeText ? 3.0 : 4.5; // AA standard
    return contrastRatio >= minRatio;
  }

  // Get accessible color alternatives
  static List<Color> getAccessibleAlternatives(
      Color original, Color background) {
    final alternatives = <Color>[];
    final originalRed = (original.toARGB32() >> 16) & 0xFF;
    final originalGreen = (original.toARGB32() >> 8) & 0xFF;
    final originalBlue = original.toARGB32() & 0xFF;
    final originalOpacity = ((original.toARGB32() >> 24) & 0xFF) / 255.0;

    // Try different shades
    for (var factor = 0.1; factor <= 0.9; factor += 0.1) {
      final lighter = Color.fromRGBO(
        (originalRed + (255 - originalRed) * factor).round().clamp(0, 255),
        (originalGreen + (255 - originalGreen) * factor).round().clamp(0, 255),
        (originalBlue + (255 - originalBlue) * factor).round().clamp(0, 255),
        originalOpacity,
      );

      final darker = Color.fromRGBO(
        (originalRed * (1 - factor)).round().clamp(0, 255),
        (originalGreen * (1 - factor)).round().clamp(0, 255),
        (originalBlue * (1 - factor)).round().clamp(0, 255),
        originalOpacity,
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
