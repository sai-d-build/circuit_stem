import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/component.dart';

void main() {
  group('Grid Model Tests', () {
    test('componentAt returns the correct component', () {
      const grid = Grid(
          rows: 3,
          cols: 3,
          components: [ComponentModel(id: 'c1', type: 'test', r: 1, c: 1)]);
      expect(grid.componentAt(1, 1)?.id, equals('c1'));
      expect(grid.componentAt(0, 0), isNull);
    });

    test('isCellOccupied works correctly', () {
      const grid = Grid(
          rows: 3,
          cols: 3,
          components: [ComponentModel(id: 'c1', type: 'test', r: 1, c: 1)]);
      expect(grid.isCellOccupied(1, 1), isTrue);
      expect(grid.isCellOccupied(0, 0), isFalse);
      expect(grid.isCellOccupied(1, 1, excludeComponentId: 'c1'), isFalse);
    });

    test('copyWithUpdatedComponent updates the correct component', () {
      const component1 = ComponentModel(id: 'c1', type: 'test', r: 1, c: 1);
      const component2 = ComponentModel(id: 'c2', type: 'test', r: 2, c: 2);
      const grid = Grid(rows: 3, cols: 3, components: [component1, component2]);

      final updatedComponent1 = component1.copyWith(isPowered: true);
      final newGrid = grid.copyWithUpdatedComponent(updatedComponent1);

      expect(newGrid.componentAt(1, 1)?.isPowered, isTrue);
      expect(newGrid.componentAt(2, 2)?.isPowered, isFalse);
    });

    test('componentsById returns a correct map', () {
      const component1 = ComponentModel(id: 'c1', type: 'test', r: 1, c: 1);
      const component2 = ComponentModel(id: 'c2', type: 'test', r: 2, c: 2);
      const grid = Grid(rows: 3, cols: 3, components: [component1, component2]);

      expect(grid.componentsById.length, 2);
      expect(grid.componentsById['c1'], component1);
      expect(grid.componentsById['c2'], component2);
    });
  });
}
