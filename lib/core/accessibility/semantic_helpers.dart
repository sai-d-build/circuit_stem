import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class SemanticHelpers {
  // Enhanced Semantics for custom controls
  static Semantics buildAccessibleButton({
    required String label,
    required String hint,
    required VoidCallback onPressed,
    required Widget child,
    bool enabled = true,
    bool selected = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: enabled,
      selected: selected,
      button: true,
      onTap: enabled ? onPressed : null,
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }

  // Slider semantics
  static Semantics buildAccessibleSlider({
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required Widget child,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      value: valueLabel,
      slider: true,
      enabled: enabled,
      increasedValue:
          (value + (max - min) * 0.1).clamp(min, max).toStringAsFixed(1),
      decreasedValue:
          (value - (max - min) * 0.1).clamp(min, max).toStringAsFixed(1),
      onIncrease: enabled
          ? () => onChanged((value + (max - min) * 0.1).clamp(min, max))
          : null,
      onDecrease: enabled
          ? () => onChanged((value - (max - min) * 0.1).clamp(min, max))
          : null,
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }

  // Switch semantics
  static Semantics buildAccessibleSwitch({
    required String label,
    required String hint,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget child,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      toggled: value,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }

  // Live region for dynamic content
  static Semantics buildLiveRegion({
    required String message,
    required Widget child,
    LiveRegionMode mode = LiveRegionMode.polite,
  }) {
    return Semantics(
      liveRegion: true,
      namesRoute: mode == LiveRegionMode.assertive,
      child: child,
    );
  }

  // Announce important events
  static void announce(String message,
      {LiveRegionMode mode = LiveRegionMode.polite}) {
    try {
      // Use SemanticsService.announce with proper parameters
      // Note: The API only supports 2 parameters, assertiveness is handled via live regions
      SemanticsService.announce(message, TextDirection.ltr);
    } catch (e) {
      // Fallback: Print to console for debugging if SemanticsService fails
      debugPrint('Accessibility announcement: $message');
      debugPrint('SemanticsService error: $e');
    }
  }
}

enum LiveRegionMode {
  polite,
  assertive,
}

extension LiveRegionModeExtension on LiveRegionMode {
  Assertiveness toAssertiveness() {
    switch (this) {
      case LiveRegionMode.polite:
        return Assertiveness.polite;
      case LiveRegionMode.assertive:
        return Assertiveness.assertive;
    }
  }
}
