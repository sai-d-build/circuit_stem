import 'dart:ui';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Gesture state machine for handling canvas interactions
class GestureStateMachine {
  GestureProcessingResult process(GestureInputEvent event, GameCanvasState state) {
    StructuredLogger.debug('Processing gesture in state machine', context: {
      'gestureType': event.type.toString(),
      'currentMode': state.interactionState.mode.toString(),
      'position': event.position.toString(),
    });

    return switch ((state.interactionState.mode, event.type)) {
      // Idle state transitions
      (GestureMode.idle, GestureEventType.tap) =>
        _handleIdleTap(event, state),
      (GestureMode.idle, GestureEventType.longPress) =>
        _handleIdleLongPress(event, state),
      (GestureMode.idle, GestureEventType.dragStart) =>
        _handleIdleDragStart(event, state),

      // Component dragging transitions
      (GestureMode.draggingExistingComponent, GestureEventType.dragUpdate) =>
        _handleComponentDragUpdate(event, state),
      (GestureMode.draggingExistingComponent, GestureEventType.dragEnd) =>
        _handleComponentDragEnd(event, state),

      // Canvas panning transitions
      (GestureMode.panning, GestureEventType.dragUpdate) =>
        _handleCanvasPanUpdate(event, state),
      (GestureMode.panning, GestureEventType.dragEnd) =>
        _handleCanvasPanEnd(event, state),

      // Multi-touch scaling
      (_, GestureEventType.scaleStart) when event.pointerCount > 1 =>
        _handleMultiTouchScaleStart(event, state),
      (GestureMode.multiTouchScaling, GestureEventType.scaleUpdate) =>
        _handleMultiTouchScaleUpdate(event, state),
      (GestureMode.multiTouchScaling, GestureEventType.scaleEnd) =>
        _handleMultiTouchScaleEnd(event, state),

      // Wire drawing transitions
      (GestureMode.drawingWire, GestureEventType.dragUpdate) =>
        _handleWireDrawingUpdate(event, state),
      (GestureMode.drawingWire, GestureEventType.dragEnd) =>
        _handleWireDrawingEnd(event, state),

      // Default case
      _ => _handleUnknownTransition(event, state),
    };
  }

  GestureProcessingResult _handleIdleTap(GestureInputEvent event, GameCanvasState state) {
    StructuredLogger.debug('Handling idle tap', context: {
      'position': event.position.toString(),
      'gridPosition': event.gridPosition?.toString(),
    });

    // Check if tapping on a component
    if (event.hitTestResult?.hasComponent ?? false) {
      final componentId = event.hitTestResult!.componentId!;
      final newInteractionState = state.interactionState.copyWith(
        selectedComponentId: componentId,
      );

      StructuredLogger.info('Component selected via tap', context: {
        'componentId': componentId,
      });

      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [
          FeedbackSideEffect(FeedbackType.selection),
        ],
      );
    } else {
      // Clear selection if tapping empty space
      final newInteractionState = state.interactionState.copyWith(
        selectedComponentId: null,
      );

      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [
          FeedbackSideEffect(FeedbackType.light),
        ],
      );
    }
  }

  GestureProcessingResult _handleIdleLongPress(GestureInputEvent event, GameCanvasState state) {
    StructuredLogger.debug('Handling idle long press', context: {
      'position': event.position.toString(),
    });

    // Could show context menu or enter different mode
    return GestureProcessingResult.noChange(state);
  }

  GestureProcessingResult _handleIdleDragStart(GestureInputEvent event, GameCanvasState state) {
    StructuredLogger.debug('Handling idle drag start', context: {
      'position': event.position.toString(),
      'hasComponent': event.hitTestResult?.hasComponent ?? false,
    });

    if (event.hitTestResult?.hasComponent ?? false) {
      // Start dragging existing component
      final componentId = event.hitTestResult!.componentId!;
      final newInteractionState = state.interactionState.copyWith(
        mode: GestureMode.draggingExistingComponent,
        draggedComponentId: componentId,
        dragStartPosition: event.gridPosition,
        currentDragPosition: event.gridPosition,
      );

      StructuredLogger.info('Started dragging component', context: {
        'componentId': componentId,
        'startPosition': event.gridPosition.toString(),
      });

      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [
          FeedbackSideEffect(FeedbackType.selection),
        ],
      );
    } else {
      // Start canvas panning
      final newInteractionState = state.interactionState.copyWith(
        mode: GestureMode.panning,
        dragStartPosition: event.gridPosition,
      );

      StructuredLogger.debug('Started canvas panning');

      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [],
      );
    }
  }

  GestureProcessingResult _handleComponentDragUpdate(GestureInputEvent event, GameCanvasState state) {
    final newInteractionState = state.interactionState.copyWith(
      currentDragPosition: event.gridPosition,
    );

    return GestureProcessingResult(
      newState: state.copyWith(interactionState: newInteractionState),
      sideEffects: [
        ComponentDragUpdateSideEffect(
          componentId: state.interactionState.draggedComponentId!,
          newPosition: event.gridPosition!,
        ),
      ],
    );
  }

  GestureProcessingResult _handleComponentDragEnd(GestureInputEvent event, GameCanvasState state) {
    StructuredLogger.debug('Handling component drag end', context: {
      'componentId': state.interactionState.draggedComponentId,
      'endPosition': event.gridPosition.toString(),
    });

    // Return to idle state
    final newInteractionState = state.interactionState.copyWith(
      mode: GestureMode.idle,
      draggedComponentId: null,
      dragStartPosition: null,
      currentDragPosition: null,
    );

    return GestureProcessingResult(
      newState: state.copyWith(interactionState: newInteractionState),
      sideEffects: [
        ComponentDragEndSideEffect(
          componentId: state.interactionState.draggedComponentId!,
          finalPosition: event.gridPosition!,
        ),
      ],
    );
  }

  GestureProcessingResult _handleCanvasPanUpdate(GestureInputEvent event, GameCanvasState state) {
    // Calculate pan delta from drag event
    final delta = event.data as Offset? ?? Offset.zero;

    return GestureProcessingResult(
      newState: state,
      sideEffects: [
        ViewportUpdateSideEffect(
          newViewportState: state.viewportState.copyWith(
            panOffset: state.viewportState.panOffset + delta,
          ),
        ),
      ],
    );
  }

  GestureProcessingResult _handleCanvasPanEnd(GestureInputEvent event, GameCanvasState state) {
    final newInteractionState = state.interactionState.copyWith(
      mode: GestureMode.idle,
      dragStartPosition: null,
    );

    return GestureProcessingResult(
      newState: state.copyWith(interactionState: newInteractionState),
      sideEffects: [],
    );
  }

  GestureProcessingResult _handleMultiTouchScaleStart(GestureInputEvent event, GameCanvasState state) {
    final newInteractionState = state.interactionState.copyWith(
      mode: GestureMode.multiTouchScaling,
    );

    return GestureProcessingResult(
      newState: state.copyWith(interactionState: newInteractionState),
      sideEffects: [],
    );
  }

  GestureProcessingResult _handleMultiTouchScaleUpdate(GestureInputEvent event, GameCanvasState state) {
    final scale = event.data as double? ?? 1.0;

    return GestureProcessingResult(
      newState: state,
      sideEffects: [
        ViewportUpdateSideEffect(
          newViewportState: state.viewportState.copyWith(
            scale: state.viewportState.scale * scale,
          ),
        ),
      ],
    );
  }

  GestureProcessingResult _handleMultiTouchScaleEnd(GestureInputEvent event, GameCanvasState state) {
    final newInteractionState = state.interactionState.copyWith(
      mode: GestureMode.idle,
    );

    return GestureProcessingResult(
      newState: state.copyWith(interactionState: newInteractionState),
      sideEffects: [],
    );
  }

  GestureProcessingResult _handleWireDrawingUpdate(GestureInputEvent event, GameCanvasState state) {
    // Update wire drawing preview
    return GestureProcessingResult(
      newState: state,
      sideEffects: [
        WireDrawingUpdateSideEffect(
          endPosition: event.gridPosition!,
        ),
      ],
    );
  }

  GestureProcessingResult _handleWireDrawingEnd(GestureInputEvent event, GameCanvasState state) {
    final newInteractionState = state.interactionState.copyWith(
      mode: GestureMode.idle,
    );

    return GestureProcessingResult(
      newState: state.copyWith(interactionState: newInteractionState),
      sideEffects: [
        WireDrawingEndSideEffect(
          endPosition: event.gridPosition!,
        ),
      ],
    );
  }

  GestureProcessingResult _handleUnknownTransition(GestureInputEvent event, GameCanvasState state) {
    StructuredLogger.warning('Unknown gesture transition', context: {
      'currentMode': state.interactionState.mode.toString(),
      'gestureType': event.type.toString(),
    });

    return GestureProcessingResult.noChange(state);
  }
}

// Additional side effect classes for gesture handling
class ComponentDragUpdateSideEffect extends SideEffect {
  final String componentId;
  final GridPosition newPosition;

  ComponentDragUpdateSideEffect({
    required this.componentId,
    required this.newPosition,
  });
}

class ComponentDragEndSideEffect extends SideEffect {
  final String componentId;
  final GridPosition finalPosition;

  ComponentDragEndSideEffect({
    required this.componentId,
    required this.finalPosition,
  });
}

class WireDrawingUpdateSideEffect extends SideEffect {
  final GridPosition endPosition;

  WireDrawingUpdateSideEffect({required this.endPosition});
}

class WireDrawingEndSideEffect extends SideEffect {
  final GridPosition endPosition;

  WireDrawingEndSideEffect({required this.endPosition});
}