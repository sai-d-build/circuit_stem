import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart';

/// Service interface for handling game interactions and gestures
abstract class GameInteractionService {
  /// Process a gesture input event and return the updated state
  GestureProcessingResult processGesture(
    GestureInputEvent event,
    GameCanvasState currentState,
  );
}

/// Result of processing a gesture
class GestureProcessingResult {
  final GameCanvasState newState;
  final List<SideEffect> sideEffects;

  const GestureProcessingResult({
    required this.newState,
    this.sideEffects = const [],
  });

  factory GestureProcessingResult.noChange(GameCanvasState currentState) {
    return GestureProcessingResult(
      newState: currentState,
      sideEffects: [],
    );
  }
}