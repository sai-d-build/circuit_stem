import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/application/services/gestures/gesture_state_machine.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart';

void main() {
  late GestureStateMachine stateMachine;

  setUp(() {
    stateMachine = GestureStateMachine();
  });

  group('GestureStateMachine', () {
    group('Idle state transitions', () {
      test('should handle tap on component correctly', () {
        // Arrange
        final initialState = GameCanvasState.initial();
        final event = GestureInputEvent.tap(const Offset(100, 100))
            .copyWith(hitTestResult: HitTestResult.component('comp-1'));

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.selectedComponentId, 'comp-1');
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<FeedbackSideEffect>());
        expect((result.sideEffects.first as FeedbackSideEffect).feedbackType,
            FeedbackType.selection);
      });

      test('should handle tap on empty space correctly', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.idle,
            selectedComponentId: 'existing-selection',
          ),
        );
        final event = GestureInputEvent.tap(const Offset(100, 100))
            .copyWith(hitTestResult: HitTestResult.empty());

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.selectedComponentId, null);
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<FeedbackSideEffect>());
        expect((result.sideEffects.first as FeedbackSideEffect).feedbackType,
            FeedbackType.light);
      });

      test('should start dragging component when drag starts on component', () {
        // Arrange
        final initialState = GameCanvasState.initial();
        final event =
            GestureInputEvent.dragStart(const Offset(100, 100)).copyWith(
          hitTestResult: HitTestResult.component('comp-1'),
          gridPosition: const GridPosition(row: 1, col: 1),
        );

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode,
            GestureMode.draggingExistingComponent);
        expect(result.newState.interactionState.draggedComponentId, 'comp-1');
        expect(result.newState.interactionState.dragStartPosition,
            const GridPosition(row: 1, col: 1));
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<FeedbackSideEffect>());
      });

      test('should start canvas panning when drag starts on empty space', () {
        // Arrange
        final initialState = GameCanvasState.initial();
        final event =
            GestureInputEvent.dragStart(const Offset(100, 100)).copyWith(
          hitTestResult: HitTestResult.empty(),
          gridPosition: const GridPosition(row: 1, col: 1),
        );

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode, GestureMode.panning);
        expect(result.newState.interactionState.dragStartPosition,
            const GridPosition(row: 1, col: 1));
        expect(result.sideEffects.length, 0);
      });
    });

    group('Component dragging transitions', () {
      test('should update drag position during component drag', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.draggingExistingComponent,
            draggedComponentId: 'comp-1',
            dragStartPosition: GridPosition(row: 1, col: 1),
          ),
        );
        final event = GestureInputEvent.dragUpdate(
                const Offset(150, 150), const Offset(50, 50))
            .copyWith(gridPosition: const GridPosition(row: 2, col: 2));

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.currentDragPosition,
            const GridPosition(row: 2, col: 2));
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<ComponentDragUpdateSideEffect>());
        final sideEffect =
            result.sideEffects.first as ComponentDragUpdateSideEffect;
        expect(sideEffect.componentId, 'comp-1');
        expect(sideEffect.newPosition, const GridPosition(row: 2, col: 2));
      });

      test('should end component drag and return to idle', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.draggingExistingComponent,
            draggedComponentId: 'comp-1',
            dragStartPosition: GridPosition(row: 1, col: 1),
          ),
        );
        final event = GestureInputEvent.dragEnd(const Offset(150, 150))
            .copyWith(gridPosition: const GridPosition(row: 2, col: 2));

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode, GestureMode.idle);
        expect(result.newState.interactionState.draggedComponentId, null);
        expect(result.newState.interactionState.dragStartPosition, null);
        expect(result.newState.interactionState.currentDragPosition, null);
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<ComponentDragEndSideEffect>());
      });
    });

    group('Canvas panning transitions', () {
      test('should update viewport during pan', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.panning,
            dragStartPosition: GridPosition(row: 1, col: 1),
          ),
        );
        final event = GestureInputEvent.dragUpdate(
            const Offset(150, 150), const Offset(50, 50));

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<ViewportUpdateSideEffect>());
      });

      test('should end panning and return to idle', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.panning,
            dragStartPosition: GridPosition(row: 1, col: 1),
          ),
        );
        final event = GestureInputEvent.dragEnd(const Offset(150, 150));

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode, GestureMode.idle);
        expect(result.newState.interactionState.dragStartPosition, null);
        expect(result.sideEffects.length, 0);
      });
    });

    group('Multi-touch scaling transitions', () {
      test('should start multi-touch scaling', () {
        // Arrange
        final initialState = GameCanvasState.initial();
        final event = GestureInputEvent.scaleStart(const Offset(100, 100), 2);

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode,
            GestureMode.multiTouchScaling);
        expect(result.sideEffects.length, 0);
      });

      test('should update scale during multi-touch', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState:
              const InteractionState(mode: GestureMode.multiTouchScaling),
        );
        final event =
            GestureInputEvent.scaleUpdate(const Offset(100, 100), 1.5, 2);

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<ViewportUpdateSideEffect>());
      });

      test('should end multi-touch scaling', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState:
              const InteractionState(mode: GestureMode.multiTouchScaling),
        );
        final event = GestureInputEvent.scaleEnd(const Offset(100, 100), 2);

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode, GestureMode.idle);
        expect(result.sideEffects.length, 0);
      });
    });

    group('Unknown transitions', () {
      test('should return no change for unknown transitions', () {
        // Arrange
        final initialState = GameCanvasState.initial();
        final event = GestureInputEvent(
          type: GestureEventType.scaleEnd, // This might not match current state
          position: const Offset(100, 100),
        );

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState, initialState);
        expect(result.sideEffects.length, 0);
      });
    });

    group('Edge cases and error handling', () {
      test('should handle null grid position gracefully', () {
        // Arrange
        final initialState = GameCanvasState.initial();
        final event = GestureInputEvent.tap(const Offset(100, 100)).copyWith(
            hitTestResult: HitTestResult.component('comp-1'),
            gridPosition: null);

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.selectedComponentId, 'comp-1');
        expect(result.sideEffects.length, 1);
      });

      test('should handle rapid consecutive gestures', () {
        // Arrange
        var state = GameCanvasState.initial();

        // First tap
        final tap1 = GestureInputEvent.tap(const Offset(100, 100))
            .copyWith(hitTestResult: HitTestResult.component('comp-1'));
        var result = stateMachine.process(tap1, state);
        state = result.newState;

        // Second tap on different component
        final tap2 = GestureInputEvent.tap(const Offset(200, 200))
            .copyWith(hitTestResult: HitTestResult.component('comp-2'));
        result = stateMachine.process(tap2, state);

        // Assert
        expect(result.newState.interactionState.selectedComponentId, 'comp-2');
        expect(result.sideEffects.length, 1);
      });

      test('should handle gesture cancellation during drag', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.draggingExistingComponent,
            draggedComponentId: 'comp-1',
            dragStartPosition: GridPosition(row: 1, col: 1),
          ),
        );

        // Simulate drag end without proper cleanup
        final event = GestureInputEvent.dragEnd(const Offset(150, 150))
            .copyWith(gridPosition: null); // Null grid position

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode, GestureMode.idle);
        expect(result.newState.interactionState.draggedComponentId, null);
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<ComponentDragEndSideEffect>());
      });

      test('should handle multi-touch gesture interruption', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState:
              const InteractionState(mode: GestureMode.multiTouchScaling),
        );

        // Simulate scale end with different pointer count
        final event = GestureInputEvent.scaleEnd(
            const Offset(100, 100), 1); // Changed from 2 to 1

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.newState.interactionState.mode, GestureMode.idle);
        expect(result.sideEffects.length, 0);
      });
    });

    group('Complex interaction scenarios', () {
      test('should handle component selection during drag operation', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.draggingExistingComponent,
            draggedComponentId: 'comp-1',
            selectedComponentId: 'comp-1',
          ),
        );

        // Simulate tap on same component during drag
        final event = GestureInputEvent.tap(const Offset(100, 100))
            .copyWith(hitTestResult: HitTestResult.component('comp-1'));

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert - should maintain drag state but update selection
        expect(result.newState.interactionState.mode,
            GestureMode.draggingExistingComponent);
        expect(result.newState.interactionState.draggedComponentId, 'comp-1');
        expect(result.newState.interactionState.selectedComponentId, 'comp-1');
      });

      test('should handle long press to context menu during component drag',
          () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.draggingExistingComponent,
            draggedComponentId: 'comp-1',
          ),
        );

        // Simulate long press during drag
        final event = GestureInputEvent(
          type: GestureEventType.longPress,
          position: const Offset(100, 100),
        ).copyWith(hitTestResult: HitTestResult.component('comp-1'));

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert - should transition to idle and show context menu
        expect(result.newState.interactionState.mode, GestureMode.idle);
        expect(result.newState.interactionState.draggedComponentId, null);
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.length, 1); // Context menu side effect
      });

      test('should handle viewport constraints during pan operations', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.panning,
            dragStartPosition: GridPosition(row: 0, col: 0),
          ),
        );

        // Simulate pan beyond viewport bounds
        final event = GestureInputEvent.dragUpdate(
          const Offset(100, 100),
          const Offset(-1000, -1000), // Large negative offset
        );

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<ViewportUpdateSideEffect>());
        final sideEffect = result.sideEffects.first as ViewportUpdateSideEffect;
        // Viewport should be constrained to valid bounds
        expect(
            sideEffect.newViewportState.panOffset.dx, greaterThanOrEqualTo(0));
        expect(
            sideEffect.newViewportState.panOffset.dy, greaterThanOrEqualTo(0));
      });

      test('should handle scale limits during multi-touch operations', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState:
              const InteractionState(mode: GestureMode.multiTouchScaling),
        );

        // Simulate extreme scale values
        final event = GestureInputEvent.scaleUpdate(
            const Offset(100, 100), 10, 2); // 10x zoom

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert
        expect(result.sideEffects.length, 1);
        expect(result.sideEffects.first, isA<ViewportUpdateSideEffect>());
        final sideEffect = result.sideEffects.first as ViewportUpdateSideEffect;
        // Scale should be constrained to valid range
        expect(sideEffect.newViewportState.scale, lessThanOrEqualTo(3.0));
        expect(sideEffect.newViewportState.scale, greaterThanOrEqualTo(0.5));
      });
    });

    group('Performance and memory leak prevention', () {
      test('should not accumulate side effects on repeated operations', () {
        // Arrange
        var state = GameCanvasState.initial();

        // Perform multiple operations
        for (var i = 0; i < 10; i++) {
          final event = GestureInputEvent.tap(const Offset(100, 100))
              .copyWith(hitTestResult: HitTestResult.component('comp-1'));
          final result = stateMachine.process(event, state);
          state = result.newState;

          // Assert that side effects don't accumulate
          expect(result.sideEffects.length, 1);
        }
      });

      test('should properly clean up drag state on interruption', () {
        // Arrange
        final initialState = GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
            mode: GestureMode.draggingExistingComponent,
            draggedComponentId: 'comp-1',
            dragStartPosition: GridPosition(row: 1, col: 1),
            currentDragPosition: GridPosition(row: 2, col: 2),
          ),
        );

        // Simulate unexpected state reset (like app going to background)
        final event = GestureInputEvent(
          type: GestureEventType.tap,
          position: const Offset(100, 100),
        );

        // Act
        final result = stateMachine.process(event, initialState);

        // Assert - should return to idle state and clean up
        expect(result.newState.interactionState.mode, GestureMode.idle);
        expect(result.newState.interactionState.draggedComponentId, null);
        expect(result.newState.interactionState.dragStartPosition, null);
        expect(result.newState.interactionState.currentDragPosition, null);
      });
    });
  });
}
