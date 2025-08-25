import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/domain/behaviors/move_behavior.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';

void main() {
  group('MoveBehavior', () {
    test('returns updated component when action is move', () {
      final behavior = MoveBehavior();
      final comp = ComponentModel(id: '1', r: 0, c: 0, type: 'resistor');

      final context = GameContext(
        grid: Grid(rows: 3, cols: 3, components: [comp]),
        toRow: 2,
        toCol: 1,
      );

      final result = behavior.handle(comp, 'move', context);

      expect(result, isNotNull);
      expect(result!.r, 2);
      expect(result.c, 1);
    });

    test('returns null when action is not move', () {
      final behavior = MoveBehavior();
      final comp = ComponentModel(id: '1', r: 0, c: 0, type: 'resistor');

      final context = GameContext(grid: Grid(rows: 3, cols: 3, components: [comp]));

      final result = behavior.handle(comp, 'tap', context);

      expect(result, isNull);
    });

    test('returns null when toRow/toCol is missing', () {
      final behavior = MoveBehavior();
      final comp = ComponentModel(id: '1', r: 0, c: 0, type: 'resistor');

      final context = GameContext(grid: Grid(rows: 3, cols: 3, components: [comp]));

      final result = behavior.handle(comp, 'move', context);

      expect(result, isNull);
    });
  });
}
