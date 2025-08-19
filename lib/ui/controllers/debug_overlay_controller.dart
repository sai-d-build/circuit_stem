
// lib/ui/controllers/debug_overlay_controller.dart
import 'package:flutter/material.dart';


/// Manages the state and visibility of the debug overlay.
class DebugOverlayController extends ChangeNotifier {
  bool _isVisible = false;
  EvaluationResult? _lastEvaluation;

  /// Whether the debug overlay should be visible.
  bool get isVisible => _isVisible;

  /// The last evaluation result from the LogicEngine.
  EvaluationResult? get lastEvaluation => _lastEvaluation;

  /// Toggles the visibility of the debug overlay.
  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  /// Updates the controller with the latest evaluation result from the game engine.
  void updateEvaluation(EvaluationResult evaluation) {
    _lastEvaluation = evaluation;
    // We only notify listeners if the overlay is visible, to avoid unnecessary rebuilds.
    if (_isVisible) {
      notifyListeners();
    }
  }
}
