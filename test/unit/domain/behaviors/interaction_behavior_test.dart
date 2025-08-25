import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/domain/behaviors/interaction_behavior.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/application/game_context.dart';

void main() {
  group('ToggleBehavior', () {
    // Create a mock GameContext
    final mockContext = GameContext(grid: Grid(rows: 1, cols: 1, components: []));

    test('handle with "tap" action should toggle the "closed" state from false to true', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentModel(
        id: 's1',
        type: 'switch',
        r: 0,
        c: 0,
        state: {'closed': false},
        behaviors: [],
      );

      // ACT
      final result = behavior.handle(component, 'tap', mockContext);

      // ASSERT
      expect(result, isNotNull);
      expect(result?.state['closed'], isTrue);
    });

    test('handle with "tap" action should toggle the "closed" state from true to false', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentModel(
        id: 's1',
        type: 'switch',
        r: 0,
        c: 0,
        state: {'closed': true},
        behaviors: [],
      );

      // ACT
      final result = behavior.handle(component, 'tap', mockContext);

      // ASSERT
      expect(result, isNotNull);
      expect(result?.state['closed'], isFalse);
    });

    test('handle with non-tap action should return null', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentModel(
        id: 's1',
        type: 'switch',
        r: 0,
        c: 0,
        state: {'closed': false},
        behaviors: [],
      );

      // ACT
      final result = behavior.handle(component, 'drag', mockContext);

      // ASSERT
      expect(result, isNull);
    });

    test('handle with non-switch component should return null', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentModel(
        id: 'b1',
        type: 'battery',
        r: 0,
        c: 0,
        state: {},
        behaviors: [],
      );

      // ACT
      final result = behavior.handle(component, 'tap', mockContext);

      // ASSERT
      expect(result, isNull);
    });
  });
}
