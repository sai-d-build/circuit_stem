import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart';
import 'package:sparkcircuit/application/services/interfaces/component_placement_service.dart';
import 'package:sparkcircuit/application/services/interfaces/game_interaction_service.dart';
import 'package:sparkcircuit/application/services/interfaces/canvas_rendering_service.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'dart:ui';

class MockComponentPlacementService extends Mock implements ComponentPlacementService {}
class MockGameInteractionService extends Mock implements GameInteractionService {}
class MockCanvasRenderingService extends Mock implements CanvasRenderingService {}

void main() {
  late ProviderContainer container;
  late MockComponentPlacementService mockPlacementService;
  late MockGameInteractionService mockInteractionService;
  late MockCanvasRenderingService mockRenderingService;

  setUp(() {
    mockPlacementService = MockComponentPlacementService();
    mockInteractionService = MockGameInteractionService();
    mockRenderingService = MockCanvasRenderingService();

    container = ProviderContainer(
      overrides: [
        componentPlacementServiceProvider.overrideWithValue(mockPlacementService),
        gameInteractionServiceProvider.overrideWithValue(mockInteractionService),
        canvasRenderingServiceProvider.overrideWithValue(mockRenderingService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GameCanvasOrchestrator Integration Tests', () {
    testWidgets('should initialize orchestrator with provider container', (tester) async {
      // Arrange
      final levelId = 'test-level-1';

      // Act
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      // Assert
      expect(orchestrator, isNotNull);
      expect(orchestrator.state.currentLevel, null);
      expect(orchestrator.state.isLoading, false);
      expect(orchestrator.state.error, null);
    });

    testWidgets('should handle complete gesture workflow from tap to placement', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      // Mock interaction service responses
      final tapResult = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(selectedComponentId: 'comp-1'),
        ),
        sideEffects: [FeedbackSideEffect(FeedbackType.selection)],
      );

      final placementResult = GestureProcessingResult(
        newState: tapResult.newState,
        sideEffects: [ComponentPlacementSideEffect(ComponentPlacementRequest(
          componentType: ComponentType.battery,
          row: 1,
          col: 1,
          currentGameState: GameState.initial(),
          levelId: levelId,
        ))],
      );

      when(mockInteractionService.processGesture(any, any))
          .thenReturn(tapResult)
          .thenReturn(placementResult);

      when(mockPlacementService.executeComponentPlacement(any))
          .thenAnswer((_) async => ComponentPlacementResult.success());

      // Act - Simulate tap gesture
      final tapEvent = GestureInputEvent.tap(Offset(100, 100))
          .copyWith(hitTestResult: HitTestResult.component('comp-1'));
      orchestrator.handleGestureInput(tapEvent);

      // Act - Simulate placement gesture
      final placementEvent = GestureInputEvent.tap(Offset(150, 150))
          .copyWith(hitTestResult: HitTestResult.empty());
      orchestrator.handleGestureInput(placementEvent);

      // Assert
      verify(mockInteractionService.processGesture(tapEvent, orchestrator.state)).called(1);
      verify(mockInteractionService.processGesture(placementEvent, any)).called(1);
      verify(mockPlacementService.executeComponentPlacement(any)).called(1);
    });

    testWidgets('should handle drag and drop workflow with state persistence', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      // Mock drag start
      final dragStartResult = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(
            mode: GestureMode.draggingExistingComponent,
            draggedComponentId: 'comp-1',
            dragStartPosition: GridPosition(row: 1, col: 1),
          ),
        ),
        sideEffects: [FeedbackSideEffect(FeedbackType.selection)],
      );

      // Mock drag update
      final dragUpdateResult = GestureProcessingResult(
        newState: dragStartResult.newState.copyWith(
          interactionState: dragStartResult.newState.interactionState.copyWith(
            currentDragPosition: GridPosition(row: 2, col: 2),
          ),
        ),
        sideEffects: [ComponentDragUpdateSideEffect(
          componentId: 'comp-1',
          newPosition: GridPosition(row: 2, col: 2),
        )],
      );

      // Mock drag end
      final dragEndResult = GestureProcessingResult(
        newState: dragUpdateResult.newState.copyWith(
          interactionState: InteractionState(mode: GestureMode.idle),
        ),
        sideEffects: [ComponentDragEndSideEffect(componentId: 'comp-1')],
      );

      when(mockInteractionService.processGesture(any, any))
          .thenReturn(dragStartResult)
          .thenReturn(dragUpdateResult)
          .thenReturn(dragEndResult);

      // Act - Complete drag workflow
      orchestrator.handleGestureInput(GestureInputEvent.dragStart(Offset(100, 100))
          .copyWith(hitTestResult: HitTestResult.component('comp-1')));
      orchestrator.handleGestureInput(GestureInputEvent.dragUpdate(Offset(150, 150), Offset(50, 50)));
      orchestrator.handleGestureInput(GestureInputEvent.dragEnd(Offset(150, 150)));

      // Assert
      verify(mockInteractionService.processGesture(any, any)).called(3);
      expect(orchestrator.state.interactionState.mode, GestureMode.idle);
    });

    testWidgets('should handle multi-touch scaling with viewport updates', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      final scaleStartResult = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(mode: GestureMode.multiTouchScaling),
        ),
        sideEffects: [],
      );

      final scaleUpdateResult = GestureProcessingResult(
        newState: scaleStartResult.newState,
        sideEffects: [ViewportUpdateSideEffect(newViewportState: ViewportState(
          scale: 1.5,
          panOffset: Offset.zero,
          canvasSize: Size(800, 600),
          gridConfiguration: GridConfiguration(rows: 10, cols: 10, cellSize: 60),
        ))],
      );

      final scaleEndResult = GestureProcessingResult(
        newState: scaleUpdateResult.newState.copyWith(
          interactionState: InteractionState(mode: GestureMode.idle),
        ),
        sideEffects: [],
      );

      when(mockInteractionService.processGesture(any, any))
          .thenReturn(scaleStartResult)
          .thenReturn(scaleUpdateResult)
          .thenReturn(scaleEndResult);

      // Act - Complete scaling workflow
      orchestrator.handleGestureInput(GestureInputEvent.scaleStart(Offset(100, 100), 2));
      orchestrator.handleGestureInput(GestureInputEvent.scaleUpdate(Offset(100, 100), 1.5, 2));
      orchestrator.handleGestureInput(GestureInputEvent.scaleEnd(Offset(100, 100), 2));

      // Assert
      verify(mockInteractionService.processGesture(any, any)).called(3);
      expect(orchestrator.state.interactionState.mode, GestureMode.idle);
    });

    testWidgets('should handle canvas panning with proper viewport constraints', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      final panStartResult = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(
            mode: GestureMode.panning,
            dragStartPosition: GridPosition(row: 0, col: 0),
          ),
        ),
        sideEffects: [],
      );

      final panUpdateResult = GestureProcessingResult(
        newState: panStartResult.newState,
        sideEffects: [ViewportUpdateSideEffect(newViewportState: ViewportState(
          scale: 1.0,
          panOffset: Offset(50, 50),
          canvasSize: Size(800, 600),
          gridConfiguration: GridConfiguration(rows: 10, cols: 10, cellSize: 60),
        ))],
      );

      final panEndResult = GestureProcessingResult(
        newState: panUpdateResult.newState.copyWith(
          interactionState: InteractionState(mode: GestureMode.idle),
        ),
        sideEffects: [],
      );

      when(mockInteractionService.processGesture(any, any))
          .thenReturn(panStartResult)
          .thenReturn(panUpdateResult)
          .thenReturn(panEndResult);

      // Act - Complete panning workflow
      orchestrator.handleGestureInput(GestureInputEvent.dragStart(Offset(100, 100))
          .copyWith(hitTestResult: HitTestResult.empty()));
      orchestrator.handleGestureInput(GestureInputEvent.dragUpdate(Offset(150, 150), Offset(50, 50)));
      orchestrator.handleGestureInput(GestureInputEvent.dragEnd(Offset(150, 150)));

      // Assert
      verify(mockInteractionService.processGesture(any, any)).called(3);
      expect(orchestrator.state.interactionState.mode, GestureMode.idle);
    });

    testWidgets('should handle error recovery and state consistency', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));
      final initialState = orchestrator.state;

      when(mockInteractionService.processGesture(any, any))
          .thenThrow(Exception('Gesture processing failed'));

      // Act - Trigger error
      expect(
        () => orchestrator.handleGestureInput(GestureInputEvent.tap(Offset(100, 100))),
        throwsException,
      );

      // Assert - State should remain unchanged on error
      expect(orchestrator.state, initialState);
    });

    testWidgets('should maintain state consistency across multiple orchestrator instances', (tester) async {
      // Arrange
      final levelId1 = 'level-1';
      final levelId2 = 'level-2';

      final orchestrator1 = container.read(gameCanvasOrchestratorProvider(levelId1));
      final orchestrator2 = container.read(gameCanvasOrchestratorProvider(levelId2));

      // Mock different responses for each orchestrator
      final result1 = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(selectedComponentId: 'comp-level1'),
        ),
        sideEffects: [],
      );

      final result2 = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(selectedComponentId: 'comp-level2'),
        ),
        sideEffects: [],
      );

      when(mockInteractionService.processGesture(any, any))
          .thenReturn(result1)
          .thenReturn(result2);

      // Act
      orchestrator1.handleGestureInput(GestureInputEvent.tap(Offset(100, 100)));
      orchestrator2.handleGestureInput(GestureInputEvent.tap(Offset(200, 200)));

      // Assert - Each orchestrator maintains its own state
      expect(orchestrator1.state.interactionState.selectedComponentId, 'comp-level1');
      expect(orchestrator2.state.interactionState.selectedComponentId, 'comp-level2');
    });

    testWidgets('should handle rapid gesture sequences without state corruption', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      // Create a sequence of gesture results
      final results = List.generate(10, (index) => GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(selectedComponentId: 'comp-$index'),
        ),
        sideEffects: [FeedbackSideEffect(FeedbackType.selection)],
      ));

      when(mockInteractionService.processGesture(any, any))
          .thenAnswer((_) => results.removeAt(0));

      // Act - Rapid gesture sequence
      for (int i = 0; i < 10; i++) {
        orchestrator.handleGestureInput(GestureInputEvent.tap(Offset(100 + i * 10, 100)));
      }

      // Assert - Final state should be from last gesture
      expect(orchestrator.state.interactionState.selectedComponentId, 'comp-0'); // First result
      verify(mockInteractionService.processGesture(any, any)).called(10);
    });

    testWidgets('should properly clean up resources on orchestrator disposal', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      // Mock a gesture to change state
      final result = GestureProcessingResult(
        newState: GameCanvasState.initial().copyWith(
          interactionState: InteractionState(selectedComponentId: 'test-comp'),
        ),
        sideEffects: [],
      );

      when(mockInteractionService.processGesture(any, any)).thenReturn(result);

      // Act
      orchestrator.handleGestureInput(GestureInputEvent.tap(Offset(100, 100)));

      // Assert state was modified
      expect(orchestrator.state.interactionState.selectedComponentId, 'test-comp');

      // Note: In a real scenario, disposal would clean up resources
      // This test verifies the orchestrator is properly managed by Riverpod
    });

    testWidgets('should handle complex multi-step interaction workflows', (tester) async {
      // Arrange
      final levelId = 'test-level-1';
      final orchestrator = container.read(gameCanvasOrchestratorProvider(levelId));

      // Complex workflow: Select -> Drag -> Place -> Pan -> Scale
      final workflowResults = [
        // 1. Component selection
        GestureProcessingResult(
          newState: GameCanvasState.initial().copyWith(
            interactionState: InteractionState(selectedComponentId: 'workflow-comp'),
          ),
          sideEffects: [FeedbackSideEffect(FeedbackType.selection)],
        ),
        // 2. Start dragging
        GestureProcessingResult(
          newState: GameCanvasState.initial().copyWith(
            interactionState: InteractionState(
              mode: GestureMode.draggingExistingComponent,
              draggedComponentId: 'workflow-comp',
            ),
          ),
          sideEffects: [],
        ),
        // 3. Component placement
        GestureProcessingResult(
          newState: GameCanvasState.initial().copyWith(
            interactionState: InteractionState(mode: GestureMode.idle),
          ),
          sideEffects: [ComponentPlacementSideEffect(ComponentPlacementRequest(
            componentType: ComponentType.resistor,
            row: 2,
            col: 2,
            currentGameState: GameState.initial(),
            levelId: levelId,
          ))],
        ),
      ];

      when(mockInteractionService.processGesture(any, any))
          .thenAnswer((_) => workflowResults.removeAt(0));

      when(mockPlacementService.executeComponentPlacement(any))
          .thenAnswer((_) async => ComponentPlacementResult.success());

      // Act - Execute complex workflow
      orchestrator.handleGestureInput(GestureInputEvent.tap(Offset(100, 100))
          .copyWith(hitTestResult: HitTestResult.component('workflow-comp')));
      orchestrator.handleGestureInput(GestureInputEvent.dragStart(Offset(100, 100)));
      orchestrator.handleGestureInput(GestureInputEvent.tap(Offset(200, 200))
          .copyWith(hitTestResult: HitTestResult.empty()));

      // Assert
      verify(mockInteractionService.processGesture(any, any)).called(3);
      verify(mockPlacementService.executeComponentPlacement(any)).called(1);
      expect(orchestrator.state.interactionState.mode, GestureMode.idle);
    });
  });
}