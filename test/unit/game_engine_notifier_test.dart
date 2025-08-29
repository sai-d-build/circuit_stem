import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:circuit_stem/domain/entities/goal.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart'; // Added for MockLevelManager
import 'package:mockito/mockito.dart'; // Added for Mockito
import 'package:circuit_stem/common/logger.dart'; // Added for MockLogger

// Mocks
class MockAudioService extends Mock implements AudioService {}

class MockLogger extends Mock implements Logger {}

class MockLevelManager extends Mock implements LevelManagerNotifier {}

class MockAnimationScheduler extends AnimationScheduler {
  void schedule(void Function() callback) {}

  void cancel() {}
}

void main() {
  group('GameEngineNotifier', () {
    late GameEngineNotifier notifier;
    late LevelDefinition testLevel;

    setUp(() async {
      notifier = GameEngineNotifier(
        audioService: MockAudioService(),
        animationScheduler: MockAnimationScheduler(),
        levelManager: MockLevelManager(),
        // Removed logger: MockLogger(),
      );
      testLevel = const LevelDefinition(
        id: 'test_level',
        title: 'Test Level',
        description: 'A level for testing',
        levelNumber: 1,
        author: 'test',
        version: 1,
        rows: 5,
        cols: 5,
        blockedCells: [],
        initialComponents: [
          ComponentModel(id: 'c1', type: 'resistor', r: 1, c: 1),
        ],
        paletteComponents: [],
        goals: [Goal(type: 'power')],
        hints: [],
      );
      await notifier.loadLevel(testLevel);
    });

    test('handles RotateComponentAction and updates component rotation', () async {
      // Arrange
      const componentId = 'c1';
      const newRotation = 90;
      const action = RotateComponentAction(
        componentId: componentId,
        rotation: newRotation,
      );

      // Act
      await notifier.executeAction(action);

      // Assert
      final updatedComponent = notifier.state.grid.componentsById[componentId];
      expect(updatedComponent, isNotNull);
      expect(updatedComponent!.rotation, equals(newRotation));
    });

    test('undo restores the previous state', () async {
      // Arrange
      final initialState = notifier.state;
      const componentId = 'c1';
      const newRotation = 90;
      const action = RotateComponentAction(
        componentId: componentId,
        rotation: newRotation,
      );

      // Act
      await notifier.executeAction(action);
      final stateAfterAction = notifier.state;
      await notifier.undo();
      final stateAfterUndo = notifier.state;

      // Assert
      expect(stateAfterAction, isNot(initialState));
      expect(stateAfterUndo, equals(initialState));
    });
  });
}
