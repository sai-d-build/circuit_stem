
import 'package:flutter/material.dart';

/// Manages the state and visibility of the debug overlay.
class DebugOverlayController extends ChangeNotifier {
  bool _isVisible = false;

  /// Whether the debug overlay should be visible.
  bool get isVisible => _isVisible;

  /// Toggles the visibility of the debug overlay.
  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  // Note: The update logic has been removed as EvaluationResult is deprecated.
  // The debug overlay will need to be refactored to work with the new engine state.
}
