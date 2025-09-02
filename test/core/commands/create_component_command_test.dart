import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/commands/create_component_command.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';

import 'package:sparkcircuit/domain/entities/level_definition.dart';
import 'package:sparkcircuit/domain/goals/power_bulb_goal.dart';

void main() {
  group('CreateComponentCommand', () {
    late GameState initialState;
    late ComponentModel testComponent;

    setUp(() {
      final level = LevelDefinition(
        levelId: 'test_level',
        version: '1.0.0',
        metadata: LevelMetadata(
          id: 'test_level',
          title: 'Test Level',
          description: 'A test level',
          difficulty: 'easy',
        ),
        grid: GridConfig(
          width: 10,
          height: 10,
        ),
        components: ComponentConfig(
          available: [],
        ),
        goals: [],
        validation: ValidationRules(
          circuitRules: [],
          successConditions: [],
        ),
      );
      initialState = GameState.initial(level);
      testComponent = ComponentModel(
        id: 'test_id',
        type: ComponentType.battery,
        row: 2,
        col: 2,
      );
    });

    test('execute adds the component to the grid', () {
      final command = CreateComponentCommand(testComponent);

      final newState = command.execute(initialState);

      expect(newState.grid.getComponentById(testComponent.id), isNotNull);
      expect(newState.grid.getComponentById(testComponent.id), equals(testComponent));
    });

    test('undo removes the component from the grid', () {
      final command = CreateComponentCommand(testComponent);

      // First, execute the command to add the component
      final stateAfterExecute = command.execute(initialState);
      expect(stateAfterExecute.grid.getComponentById(testComponent.id), isNotNull);

      // Then, undo the command
      final stateAfterUndo = command.undo(stateAfterExecute);

      expect(stateAfterUndo.grid.getComponentById(testComponent.id), isNull);
    });
  });
}