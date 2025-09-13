import 'dart:ui';

import 'package:sparkcircuit/application/services/interfaces/component_placement_service.dart';
import 'package:sparkcircuit/application/services/interfaces/game_interaction_service.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart'
    as orchestrator;

// Import orchestrator classes
typedef GestureInputEvent = orchestrator.GestureInputEvent;
typedef GestureEventType = orchestrator.GestureEventType;
typedef FeedbackSideEffect = orchestrator.FeedbackSideEffect;
typedef FeedbackType = orchestrator.FeedbackType;
typedef ComponentPlacementSideEffect
    = orchestrator.ComponentPlacementSideEffect;

/// Implementation of the GameInteractionService
/// Handles gesture processing and interaction state management
class GameInteractionServiceImpl implements GameInteractionService {
  GameInteractionServiceImpl();

  @override
  GestureProcessingResult processGesture(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    StructuredLogger.debug('Processing gesture event', context: {
      'type': event.type.toString(),
      'position': event.position.toString(),
      'currentMode': currentState.interactionState.mode.toString(),
    });

    try {
      switch (event.type) {
        case GestureEventType.tap:
          return _handleTap(event, currentState);
        case GestureEventType.longPress:
          return _handleLongPress(event, currentState);
        case GestureEventType.dragStart:
          return _handleDragStart(event, currentState);
        case GestureEventType.dragUpdate:
          return _handleDragUpdate(event, currentState);
        case GestureEventType.dragEnd:
          return _handleDragEnd(event, currentState);
        case GestureEventType.scaleStart:
          return _handleScaleStart(event, currentState);
        case GestureEventType.scaleUpdate:
          return _handleScaleUpdate(event, currentState);
        case GestureEventType.scaleEnd:
          return _handleScaleEnd(event, currentState);
      }
    } catch (e, stackTrace) {
      StructuredLogger.error('Gesture processing error',
          context: {
            'gestureType': event.type.toString(),
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
          },
          error: e);

      // Return current state with error
      return GestureProcessingResult(
        newState: currentState.copyWith(
          error: 'Gesture processing failed: $e',
        ),
        sideEffects: [],
      );
    }
  }

  GestureProcessingResult _handleTap(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    final gridPosition = _convertToGridPosition(event.position, currentState);
    if (gridPosition == null) {
      return GestureProcessingResult.noChange(currentState);
    }

    // Check for component at tap position
    final component = _findComponentAtPosition(gridPosition, currentState);

    if (component != null) {
      // Component tapped - select it
      final newState = currentState.copyWith(
        interactionState: currentState.interactionState.copyWith(
          selectedComponentId: component.id,
          mode: GestureMode.idle,
        ),
      );

      return GestureProcessingResult(
        newState: newState,
        sideEffects: [
          FeedbackSideEffect(FeedbackType.selection),
        ],
      );
    } else {
      // Empty space tapped - clear selection
      final newState = currentState.copyWith(
        interactionState: currentState.interactionState.copyWith(
          selectedComponentId: null,
          mode: GestureMode.idle,
        ),
      );

      return GestureProcessingResult(
        newState: newState,
        sideEffects: [
          FeedbackSideEffect(FeedbackType.light),
        ],
      );
    }
  }

  GestureProcessingResult _handleLongPress(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    final gridPosition = _convertToGridPosition(event.position, currentState);
    if (gridPosition == null) {
      return GestureProcessingResult.noChange(currentState);
    }

    final component = _findComponentAtPosition(gridPosition, currentState);
    if (component != null) {
      // Component long pressed - show context menu
      final newState = currentState.copyWith(
        interactionState: currentState.interactionState.copyWith(
          selectedComponentId: component.id,
          mode: GestureMode.idle,
        ),
      );

      return GestureProcessingResult(
        newState: newState,
        sideEffects: [
          FeedbackSideEffect(FeedbackType.medium),
          // Note: Context menu would be handled by UI layer
        ],
      );
    }

    return GestureProcessingResult.noChange(currentState);
  }

  GestureProcessingResult _handleDragStart(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    final gridPosition = _convertToGridPosition(event.position, currentState);
    if (gridPosition == null) {
      return GestureProcessingResult.noChange(currentState);
    }

    final component = _findComponentAtPosition(gridPosition, currentState);

    if (component != null) {
      // Start dragging existing component
      final newState = currentState.copyWith(
        interactionState: currentState.interactionState.copyWith(
          draggedComponentId: component.id,
          dragStartPosition: gridPosition,
          currentDragPosition: gridPosition,
          mode: GestureMode.draggingExistingComponent,
        ),
      );

      return GestureProcessingResult(
        newState: newState,
        sideEffects: [],
      );
    } else {
      // Start panning canvas
      final newState = currentState.copyWith(
        interactionState: currentState.interactionState.copyWith(
          mode: GestureMode.panning,
          dragStartPosition: gridPosition,
          currentDragPosition: gridPosition,
        ),
      );

      return GestureProcessingResult(
        newState: newState,
        sideEffects: [],
      );
    }
  }

  GestureProcessingResult _handleDragUpdate(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    final gridPosition = _convertToGridPosition(event.position, currentState);
    if (gridPosition == null) {
      return GestureProcessingResult.noChange(currentState);
    }

    final updatedState = currentState.copyWith(
      interactionState: currentState.interactionState.copyWith(
        currentDragPosition: gridPosition,
      ),
    );

    // Handle drag delta for panning if in pan mode
    if (currentState.interactionState.mode == GestureMode.panning) {
      final delta = event.data as Offset? ?? Offset.zero;
      final newPanOffset = currentState.viewportState.panOffset + delta;

      return GestureProcessingResult(
        newState: updatedState.copyWith(
          viewportState: currentState.viewportState.copyWith(
            panOffset: newPanOffset,
          ),
        ),
        sideEffects: [],
      );
    }

    return GestureProcessingResult(
      newState: updatedState,
      sideEffects: [],
    );
  }

  GestureProcessingResult _handleDragEnd(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    final dragStart = currentState.interactionState.dragStartPosition;
    final dragEnd = currentState.interactionState.currentDragPosition;

    if (currentState.interactionState.draggedComponentId != null &&
        dragStart != null &&
        dragEnd != null) {
      // Component was dragged - create placement side effect
      // TODO: Convert GameCanvasState to GameState for component placement
      // For now, skip the side effect until proper conversion is implemented
      final moveSideEffect = ComponentPlacementSideEffect(
        ComponentPlacementRequest(
          componentType: ComponentType
              .wire, // This would need to be determined from the component
          row: dragEnd.row,
          col: dragEnd.col,
          currentGameState: GameState.initial(currentState
              .currentLevel), // Placeholder - needs proper conversion
          levelId: currentState.currentLevel?.levelId ?? '',
        ),
      );

      final newState = currentState.copyWith(
        interactionState: currentState.interactionState.copyWith(
          draggedComponentId: null,
          dragStartPosition: null,
          currentDragPosition: null,
          mode: GestureMode.idle,
        ),
      );

      return GestureProcessingResult(
        newState: newState,
        sideEffects: [moveSideEffect],
      );
    }

    // End pan mode
    final newState = currentState.copyWith(
      interactionState: currentState.interactionState.copyWith(
        mode: GestureMode.idle,
        dragStartPosition: null,
        currentDragPosition: null,
      ),
    );

    return GestureProcessingResult(
      newState: newState,
      sideEffects: [],
    );
  }

  GestureProcessingResult _handleScaleStart(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    final newState = currentState.copyWith(
      interactionState: currentState.interactionState.copyWith(
        mode: event.pointerCount > 1
            ? GestureMode.multiTouchScaling
            : GestureMode.idle,
      ),
    );

    return GestureProcessingResult(
      newState: newState,
      sideEffects: [],
    );
  }

  GestureProcessingResult _handleScaleUpdate(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    if (event.pointerCount > 1 && event.data is double) {
      // Multi-touch scaling
      final newScale =
          currentState.viewportState.scale * (event.data as double);

      final newState = currentState.copyWith(
        viewportState: currentState.viewportState.copyWith(
          scale: newScale.clamp(0.1, 5.0), // Reasonable scale limits
        ),
      );

      return GestureProcessingResult(
        newState: newState,
        sideEffects: [],
      );
    } else {
      // Single-touch gesture handled by drag methods
      return GestureProcessingResult.noChange(currentState);
    }
  }

  GestureProcessingResult _handleScaleEnd(
    GestureInputEvent event,
    GameCanvasState currentState,
  ) {
    final newState = currentState.copyWith(
      interactionState: currentState.interactionState.copyWith(
        mode: GestureMode.idle,
      ),
    );

    return GestureProcessingResult(
      newState: newState,
      sideEffects: [],
    );
  }

  /// Convert screen position to grid position
  GridPosition? _convertToGridPosition(
    Offset screenPosition,
    GameCanvasState currentState,
  ) {
    // Simplified conversion for now - TODO: Implement proper coordinate transformation
    const cellSize = 60.0; // Default cell size
    final scaledX =
        (screenPosition.dx - currentState.viewportState.panOffset.dx) /
            currentState.viewportState.scale;
    final scaledY =
        (screenPosition.dy - currentState.viewportState.panOffset.dy) /
            currentState.viewportState.scale;

    final gridX = (scaledX / cellSize).floor();
    final gridY = (scaledY / cellSize).floor();

    // Convert to GridPosition
    return GridPosition(
      row: gridY,
      col: gridX,
    );
  }

  /// Find component at grid position
  dynamic _findComponentAtPosition(
    GridPosition gridPosition,
    GameCanvasState currentState,
  ) {
    try {
      return currentState.renderingData.components.firstWhere(
        (component) =>
            component.row == gridPosition.row &&
            component.col == gridPosition.col,
      );
    } catch (e) {
      return null;
    }
  }
}
