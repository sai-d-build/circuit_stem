import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:circuit_stem/domain/entities/goal.dart';

// Mocks
class MockAudioService extends AudioService {
  @override
  Future<void> play(String sound) async {}
  
  Future<void> stopAll() async {}

  Future<void> dispose() async {}
}

class MockAnimationScheduler extends AnimationScheduler {
  void schedule(void Function() callback) {}
  
  void cancel() {}
}

void main() {
  group('GameEngineNotifier', () {
    late GameEngineNotifier notifier;
    late LevelDefinition testLevel;

    setUp(() {
      notifier = GameEngineNotifier(
        audioService: MockAudioService(),
        animationScheduler: MockAnimationScheduler(),
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
      notifier.loadLevel(testLevel);
    });

    test('handles RotateComponentAction and updates component rotation', () {
      // Arrange
      const componentId = 'c1';
      const newRotation = 1;
      const action = RotateComponentAction(
        componentId: componentId,
        rotation: newRotation,
      );

      // Act
      notifier.executeAction(action);

      // Assert
      final updatedComponent = notifier.state.grid.componentsById[componentId];
      expect(updatedComponent, isNotNull);
      expect(updatedComponent!.rotation, equals(newRotation));
    });

    test('undo restores the previous state', () {
      // Arrange
      final initialState = notifier.state;
      const componentId = 'c1';
      const newRotation = 1;
      const action = RotateComponentAction(
        componentId: componentId,
        rotation: newRotation,
      );

      // Act
      notifier.executeAction(action);
      final stateAfterAction = notifier.state;
      notifier.undo();
      final stateAfterUndo = notifier.state;

      // Assert
      expect(stateAfterAction, isNot(initialState));
      expect(stateAfterUndo, equals(initialState));
    });
  });
}
