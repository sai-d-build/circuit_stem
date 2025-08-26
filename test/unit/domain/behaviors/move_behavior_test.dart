import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/domain/behaviors/move_behavior.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';

void main() {
  group('MoveBehavior', () {
    test('returns updated component when action is move', () {
      const behavior = MoveBehavior();
      const comp = ComponentModel(id: '1', r: 0, c: 0, type: 'resistor');

      const context = GameContext(
        grid: Grid(rows: 3, cols: 3, components: []),
        toRow: 2,
        toCol: 1,
      );

      final result = behavior.handle(comp, 'move', context);

      expect(result, isNotNull);
      expect(result!.r, 2);
      expect(result.c, 1);
    });

    test('returns null when action is not move', () {
      const behavior = MoveBehavior();
      const comp = ComponentModel(id: '1', r: 0, c: 0, type: 'resistor');

      const context = GameContext(grid: Grid(rows: 3, cols: 3, components: []));

      final result = behavior.handle(comp, 'tap', context);

      expect(result, isNull);
    });

    test('returns null when toRow/toCol is missing', () {
      const behavior = MoveBehavior();
      const comp = ComponentModel(id: '1', r: 0, c: 0, type: 'resistor');

      const context = GameContext(grid: Grid(rows: 3, cols: 3, components: []));

      final result = behavior.handle(comp, 'move', context);

      expect(result, isNull);
    });
  });
}
