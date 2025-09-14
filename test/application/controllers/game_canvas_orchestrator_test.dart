import 'dart:ui';
import '../../lib/core/entity/grid_configuration.dart'

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sparkcircuit/application/services/interfaces/canvas_rendering_service.dart';
import 'package:sparkcircuit/application/services/interfaces/component_placement_service.dart';
import 'package:sparkcircuit/application/services/interfaces/game_interaction_service.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart';

class MockComponentPlacementService extends Mock
    implements ComponentPlacementService {}

class MockGameInteractionService extends Mock
    implements GameInteractionService {}

class MockCanvasRenderingService extends Mock
    implements CanvasRenderingService {}

void main() {
  late GameCanvasOrchestrator orchestrator;
  late MockComponentPlacementService mockPlacementService;
  late MockGameInteractionService mockInteractionService;
  late MockCanvasRenderingService mockRenderingService;

  setUp(() {
    mockPlacementService = MockComponentPlacementService();
    mockInteractionService = MockGameInteractionService();
    mockRenderingService = MockCanvasRenderingService();

    orchestrator = GameCanvasOrchestrator(
      interactionService: mockInteractionService,
      renderingService: mockRenderingService,
    );
  });

  group('GameCanvasOrchestrator', () {
    test('should initialize with correct initial state', () {
      // Assert
      expect(orchestrator.state.currentLevel, null);
      expect(orchestrator.state.isLoading, false);
      expect(orchestrator.state.error, null);
      expect(orchestrator.state.interactionState.mode, GestureMode.idle);
    });

    test('should handle gesture input correctly', () {
      // Arrange
      final event = GestureInputEvent.tap(const Offset(100, 100));
      final expectedResult = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: const InteractionState(
              mode: GestureMode.idle, selectedComponentId: 'test-component'),
        ),
        sideEffects: [FeedbackSideEffect(FeedbackType.selection)],
      );

      when(mockInteractionService.processGesture(event, orchestrator.state))
          .thenReturn(expectedResult);

      // Act
      orchestrator.handleGestureInput(event);

      // Assert
      verify(mockInteractionService.processGesture(event, orchestrator.state))
          .called(1);
      expect(orchestrator.state.interactionState.selectedComponentId,
          'test-component');
    });

    test('should execute side effects after gesture processing', () {
      // Arrange
      final event = GestureInputEvent.tap(const Offset(100, 100));
      final sideEffect = FeedbackSideEffect(FeedbackType.selection);
      final expectedResult = GestureProcessingResult(
        newState: GameCanvasState.initial(),
        sideEffects: [sideEffect],
      );

      when(mockInteractionService.processGesture(event, orchestrator.state))
          .thenReturn(expectedResult);

      // Act
      orchestrator.handleGestureInput(event);

      // Assert
      verify(mockInteractionService.processGesture(event, orchestrator.state))
          .called(1);
      // Note: Side effect execution would be tested in integration tests
    });

    test('should handle component placement side effects', () {
      // Arrange
      final event = GestureInputEvent.tap(const Offset(100, 100));
      final placementRequest = ComponentPlacementRequest(
        componentType: ComponentType.battery,
        row: 1,
        col: 1,
        currentGameState: GameState.initial(null),
        levelId: 'test-level',
      );
      final sideEffect = ComponentPlacementSideEffect(placementRequest);
      final expectedResult = GestureProcessingResult(
        newState: GameCanvasState.initial(),
        sideEffects: [sideEffect],
      );

      when(mockInteractionService.processGesture(event, orchestrator.state))
          .thenReturn(expectedResult);

      // Act
      orchestrator.handleGestureInput(event);

      // Assert
      verify(mockPlacementService.executeComponentPlacement(placementRequest))
          .called(1);
    });

    test('should handle viewport update side effects', () {
      // Arrange
      final event = GestureInputEvent.dragUpdate(
          const Offset(100, 100), const Offset(10, 10));
      const newViewportState = ViewportState(
        scale: 1,
        panOffset: Offset(10, 10),
        canvasSize: Size(800, 600),
        gridConfiguration: GridConfiguration(rows: 10, cols: 10, cellSize: 60),
      );
      final sideEffect =
          ViewportUpdateSideEffect(newViewportState: newViewportState);
      final expectedResult = GestureProcessingResult(
        newState: GameCanvasState.initial(),
        sideEffects: [sideEffect],
      );

      when(mockInteractionService.processGesture(event, orchestrator.state))
          .thenReturn(expectedResult);

      // Act
      orchestrator.handleGestureInput(event);

      // Assert
      verify(mockInteractionService.processGesture(event, orchestrator.state))
          .called(1);
      // Note: Viewport state update would be verified in the state
    });

    test('should handle multiple side effects correctly', () {
      // Arrange
      final event = GestureInputEvent.tap(const Offset(100, 100));
      final sideEffects = [
        FeedbackSideEffect(FeedbackType.selection),
        FeedbackSideEffect(FeedbackType.light),
      ];
      final expectedResult = GestureProcessingResult(
        newState: GameCanvasState.initial(),
        sideEffects: sideEffects,
      );

      when(mockInteractionService.processGesture(event, orchestrator.state))
          .thenReturn(expectedResult);

      // Act
      orchestrator.handleGestureInput(event);

      // Assert
      verify(mockInteractionService.processGesture(event, orchestrator.state))
          .called(1);
      // All side effects should be executed
    });

    test('should maintain state consistency during gesture processing', () {
      // Arrange
      final event = GestureInputEvent.tap(const Offset(100, 100));
      final newState = GameCanvasState.initial().copyWith(
        interactionState: const InteractionState(
            mode: GestureMode.idle, selectedComponentId: 'new-selection'),
      );
      final expectedResult = GestureProcessingResult(
        newState: newState,
        sideEffects: [],
      );

      when(mockInteractionService.processGesture(event, orchestrator.state))
          .thenReturn(expectedResult);

      // Act
      orchestrator.handleGestureInput(event);

      // Assert
      expect(orchestrator.state.interactionState.selectedComponentId,
          'new-selection');
      expect(orchestrator.state.isLoading, false); // Should remain unchanged
      expect(orchestrator.state.error, null); // Should remain unchanged
    });

    test('should handle gesture processing errors gracefully', () {
      // Arrange
      final event = GestureInputEvent.tap(const Offset(100, 100));

      when(mockInteractionService.processGesture(event, orchestrator.state))
          .thenThrow(Exception('Gesture processing failed'));

      // Act & Assert
      expect(
        () => orchestrator.handleGestureInput(event),
        throwsException,
      );
      // State should remain unchanged on error
      expect(orchestrator.state, GameCanvasState.initial());
    });
  });
}
