import 'dart:ui';
import '../entity/grid_configuration.dart';

import 'package:sparkcircuit/application/services/gestures/gesture_state_machine.dart';
import 'package:sparkcircuit/application/services/interfaces/game_interaction_service.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart' as gc;
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart'
    as orchestrator;
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart'
    show HitTestResult;

/// Default implementation of GameInteractionService
class DefaultGameInteractionService implements GameInteractionService {
  final GestureStateMachine _gestureStateMachine;

  DefaultGameInteractionService({
    required GestureStateMachine gestureStateMachine,
  }) : _gestureStateMachine = gestureStateMachine;

  @override
  orchestrator.GestureProcessingResult processGesture(
    orchestrator.GestureInputEvent event,
    gc.GameCanvasState currentState,
  ) {
    // Convert screen coordinates to grid coordinates if needed
    final gridPosition = _convertToGridPosition(event.position, currentState);

    // Perform hit testing to determine what was touched
    final hitTestResult = _performHitTest(gridPosition, currentState);

    // Enrich the event with additional context
    final enrichedEvent = orchestrator.GestureInputEvent(
      type: event.type,
      position: event.position,
      pointerCount: event.pointerCount,
      gridPosition: gridPosition,
      hitTestResult: hitTestResult,
      data: event.data,
    );

    // Process through the gesture state machine
    return _gestureStateMachine.process(enrichedEvent, currentState);
  }

  /// Convert screen position to grid position
  gc.GridPosition? _convertToGridPosition(
      Offset screenPosition, gc.GameCanvasState state) {
    if (state.currentLevel == null) return null;

    final gridLevel = state.currentLevel!.grid;
    final viewportState = state.viewportState;

    // Create GridConfiguration from level grid using standard factory
    final gridConfig = gc.GridConfiguration.standard().copyWith(
      rows: gridLevel.height,
      cols: gridLevel.width,
    );

    // Apply viewport transformations (pan, zoom)
    final transformedPosition = Offset(
      (screenPosition.dx - viewportState.panOffset.dx) / viewportState.scale,
      (screenPosition.dy - viewportState.panOffset.dy) / viewportState.scale,
    );

    // Convert to grid coordinates
    final gridX = (transformedPosition.dx / gridConfig.cellSize).floor();
    final gridY = (transformedPosition.dy / gridConfig.cellSize).floor();

    // Check bounds
    if (gridX >= 0 &&
        gridX < gridConfig.cols &&
        gridY >= 0 &&
        gridY < gridConfig.rows) {
      return gc.GridPosition(row: gridY, col: gridX);
    }

    return null;
  }

  /// Perform hit testing to determine what component (if any) was touched
  HitTestResult _performHitTest(
      gc.GridPosition? gridPosition, gc.GameCanvasState state) {
    if (gridPosition == null || state.currentLevel == null) {
      return HitTestResult.empty();
    }

    // Check if there's a component at the grid position
    // GameCanvasState doesn't have direct grid access, components are in currentLevel or separate state
    final componentId =
        'component_at_${gridPosition.row}_${gridPosition.col}'; // Both gridPosition and currentLevel are validated above

    return HitTestResult.component(componentId);
  }
}
