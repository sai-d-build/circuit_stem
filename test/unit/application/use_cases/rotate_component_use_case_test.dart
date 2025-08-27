import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/use_cases/rotate_component_use_case.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';

void main() {
  group('RotateComponentUseCase', () {
    late RotateComponentUseCase useCase;
    late GameEngineState initialState;

    setUp(() {
      useCase = const RotateComponentUseCase();
      initialState = GameEngineState.initial(
        const LevelDefinition(
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
            ComponentModel(id: 'c1', type: 'resistor', r: 1, c: 1, rotation: 0),
          ],
          paletteComponents: [],
          goals: [],
          hints: [],
        ),
      );
    });

    test('should rotate a component', () async {
      // Arrange
      const action = RotateComponentAction(componentId: 'c1', rotation: 1);

      // Act
      final result = await useCase.execute(initialState, action);

      // Assert
      expect(result.isSuccess, isTrue);
      final newGrid = result.data!.grid;
      final rotatedComponent = newGrid.componentsById['c1'];
      expect(rotatedComponent, isNotNull);
      expect(rotatedComponent!.rotation, 1);
    });

    test('should return failure if component is not found', () async {
      // Arrange
      const action = RotateComponentAction(componentId: 'c2', rotation: 1);

      // Act
      final result = await useCase.execute(initialState, action);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error, 'Component not found');
    });
  });
}
