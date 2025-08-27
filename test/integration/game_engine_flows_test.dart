import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';
import 'package:circuit_stem/common/logger.dart';
import 'package:mockito/mockito.dart';

class MockAudioService extends Mock implements AudioService {}

class MockLogger extends Mock implements Logger {}

class MockLevelManager extends Mock implements LevelManagerNotifier {}

void main() {
  group('GameEngineNotifier Integration Tests', () {
    late GameEngineNotifier notifier;
    late LevelDefinition testLevel;

    setUp(() {
      testLevel = const LevelDefinition(
        id: 'test_level',
        title: 'Test Level',
        description: 'A simple test level',
        levelNumber: 1,
        author: 'Test Author',
        version: 1,
        rows: 5,
        cols: 5,
        blockedCells: [],
        initialComponents: [
          ComponentModel(
              id: 'battery',
              type: 'battery',
              r: 0,
              c: 0,
              terminals: [
                TerminalSpec(
                    offset: CellOffset(0, 0),
                    direction: Dir.south,
                    type: TerminalType.power),
              ]),
        ],
        paletteComponents: [
          ComponentModel(
              id: 'wire_palette',
              type: 'wire',
              r: 0,
              c: 0,
              terminals: [
                TerminalSpec(
                    offset: CellOffset(0, 0),
                    direction: Dir.north,
                    type: TerminalType.power),
                TerminalSpec(
                    offset: CellOffset(0, 0),
                    direction: Dir.south,
                    type: TerminalType.power),
              ]),
        ],
        goals: [],
        hints: [],
      );

      notifier = GameEngineNotifier(
        audioService: MockAudioService(),
        animationScheduler: AnimationScheduler(),
        levelManager: MockLevelManager(),
      );

      notifier.loadLevel(testLevel);
    });

    test('Perform actions and undo', () async {
      // Arrange
      final initialState = notifier.state;
      const createAction = CreateComponentFromTemplateAction(
        templateId: 'wire_palette',
        row: 1,
        col: 0,
      );
      await notifier.executeAction(createAction);
      final stateAfterCreate = notifier.state;

      final wireId =
          notifier.state.grid.components.firstWhere((c) => c.type == 'wire').id;
      final moveAction = MoveComponentAction(
        componentId: wireId,
        newRow: 2,
        newCol: 0,
      );
      await notifier.executeAction(moveAction);

      // Act
      const undoAction = UndoAction();
      await notifier.executeAction(undoAction);

      // Assert
      expect(notifier.state, stateAfterCreate);

      // Act
      await notifier.executeAction(undoAction);

      // Assert
      expect(notifier.state, initialState);
    });
  });
}
