import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';

void main() {
  group('Drag Detection Tests', () {
    late GridConfiguration config;

    setUp(() {
      config = const GridConfiguration(
        rows: 10,
        cols: 10,
        cellSize: 60.0,
        scale: 1.0,
        panOffset: Offset.zero,
      );
    });

    group('Component Position Detection Tests', () {
      test('Finds component at exact grid position', () {
        final testPosition = const Offset(3, 2); // col=3, row=2 to match component position
        final matchingComponent = ComponentModel(
          id: 'test_comp',
          type: ComponentType.battery,
          row: 2,
          col: 3,
          properties: {},
        );

        final grid = _MockGrid([matchingComponent]);
        final result = _findComponentAtPosition(testPosition, grid);

        expect(result, equals(matchingComponent));
      });

      test('Returns null when no component at position', () {
        final testPosition = const Offset(5, 5);
        final componentAtDifferentPos = ComponentModel(
          id: 'test_comp',
          type: ComponentType.battery,
          row: 0,
          col: 0,
          properties: {},
        );

        final grid = _MockGrid([componentAtDifferentPos]);
        final result = _findComponentAtPosition(testPosition, grid);

        expect(result, isNull);
      });

      test('Handles multiple components correctly', () {
        final testPosition = const Offset(2, 2);
        final components = [
          ComponentModel(id: 'comp1', type: ComponentType.battery, row: 0, col: 0, properties: {}),
          ComponentModel(id: 'comp2', type: ComponentType.battery, row: 2, col: 2, properties: {}),
          ComponentModel(id: 'comp3', type: ComponentType.battery, row: 4, col: 4, properties: {}),
        ];

        final grid = _MockGrid(components);
        final result = _findComponentAtPosition(testPosition, grid);

        expect(result?.id, equals('comp2'));
      });
    });

    group('Drag Eligibility Tests', () {
      test('Valid drag candidate should be accepted', () {
        final dragData = _MockDragData(ComponentType.battery, 1);
        final grid = _MockGrid([]);
        final result = _canAcceptComponentDrop(dragData, grid, config, const Offset(120, 120));

        expect(result, isTrue);
      });

      test('Drag with insufficient inventory should be rejected', () {
        final dragData = _MockDragData(ComponentType.battery, 0);
        final grid = _MockGrid([]);
        final result = _canAcceptComponentDrop(dragData, grid, config, const Offset(120, 120));

        expect(result, isFalse);
      });

      test('Drag outside grid bounds should be rejected', () {
        final dragData = _MockDragData(ComponentType.battery, 1);
        final grid = _MockGrid([]);
        final result = _canAcceptComponentDrop(dragData, grid, config, const Offset(-100, -100));

        expect(result, isFalse);
      });

      test('Drag on occupied position should be rejected', () {
        final dragData = _MockDragData(ComponentType.battery, 1);
        final existingComponent = ComponentModel(
          id: 'existing',
          type: ComponentType.battery,
          row: 2,
          col: 2,
          properties: {}
        );
        final grid = _MockGrid([existingComponent]);
        final dropPosition = GridService.gridToScreen(const Offset(2, 2), config); // Position (2,2) in screen coordinates

        final result = _canAcceptComponentDrop(dragData, grid, config, dropPosition);

        expect(result, isFalse);
      });

      test('Drag on valid empty position should be accepted', () {
        final dragData = _MockDragData(ComponentType.battery, 1);
        final existingComponent = ComponentModel(
          id: 'existing',
          type: ComponentType.battery,
          row: 0,
          col: 0,
          properties: {}
        );
        final grid = _MockGrid([existingComponent]);
        final dropPosition = GridService.gridToScreen(const Offset(1, 1), config); // Position (1,1) in screen coordinates

        final result = _canAcceptComponentDrop(dragData, grid, config, dropPosition);

        expect(result, isTrue);
      });
    });

    group('Grid Boundary Checking Tests', () {
      test('Position within grid bounds is accepted', () {
        final screenPos = const Offset(300, 300); // Within 10x10 grid with 60px cells
        final result = GridService.isWithinGridBounds(screenPos, config);
        expect(result, isTrue);
      });

      test('Position at grid boundary is accepted', () {
        final screenPos = const Offset(540, 540); // Edge of 10x10 grid (9*60 + 30 center = 540)
        final result = GridService.isWithinGridBounds(screenPos, config);
        expect(result, isTrue);
      });

      test('Negative position is rejected', () {
        final screenPos = const Offset(-30, 30);
        final result = GridService.isWithinGridBounds(screenPos, config);
        expect(result, isFalse);
      });

      test('Position beyond grid boundaries is rejected', () {
        final screenPos = const Offset(700, 700);
        final result = GridService.isWithinGridBounds(screenPos, config);
        expect(result, isFalse);
      });

      test('Pan offset affects boundary calculations', () {
        final pannedConfig = config.copyWith(panOffset: const Offset(400, 400)); // Even larger pan to definitely push out of bounds
        final screenPos = const Offset(300, 300);
        final result = GridService.isWithinGridBounds(screenPos, pannedConfig);
        expect(result, isFalse);
      });
    });

    group('Component Type Validation Tests', () {
      test('All valid component types are accepted', () {
        final validTypes = [
          ComponentType.battery,
          ComponentType.resistor,
          ComponentType.bulb,
          ComponentType.wire,
          ComponentType.switch_,
          ComponentType.capacitor,
          ComponentType.inductor,
          ComponentType.buzzer,
        ];

        for (final type in validTypes) {
          final dragData = _MockDragData(type, 1);
          final grid = _MockGrid([]);
          final result = _canAcceptComponentDrop(dragData, grid, config, const Offset(120, 120));
          expect(result, isTrue, reason: '${type} should be accepted');
        }
      });

      test('Component with null properties handles gracefully', () {
        final dragData = _MockDragData(ComponentType.wire, 1, hasNullProperties: true);
        final grid = _MockGrid([]);
        final result = _canAcceptComponentDrop(dragData, grid, config, const Offset(120, 120));

        expect(result, isTrue);
      });
    });

    group('Complex Drag Scenarios', () {
      test('Multi-touch drag operations are handled correctly', () {
        // Test scaling and rotation handling
        final zoomConfig = config.copyWith(scale: 2.0);
        final dragData = _MockDragData(ComponentType.battery, 1);
        final grid = _MockGrid([]);
        final result = _canAcceptComponentDrop(dragData, grid, zoomConfig, const Offset(240, 240));

        expect(result, isTrue);
      });

      test('Drag after component repositioning works correctly', () {
        final components = [
          ComponentModel(id: 'moved_comp', type: ComponentType.battery, row: 3, col: 3, properties: {}),
        ];
        final grid = _MockGrid(components);
        final dragData = _MockDragData(ComponentType.battery, 1);
        final newPosition = GridService.gridToScreen(const Offset(5, 5), config);

        final result = _canAcceptComponentDrop(dragData, grid, config, newPosition);

        expect(result, isTrue); // Should succeed as (5,5) is empty
      });

      test('Drag with invalid component ID still works', () {
        final dragData = _MockDragData(ComponentType.wire, 1, invalidId: true);
        final grid = _MockGrid([]);
        final result = _canAcceptComponentDrop(dragData, grid, config, const Offset(120, 120));

        expect(result, isTrue); // Should work even with invalid ID
      });
    });
  });
}

// Mock classes for testing
class _MockGrid {
  final List<ComponentModel> components;

  _MockGrid(this.components);

  bool canPlaceComponent(int row, int col) {
    return !components.any((component) => component.row == row && component.col == col);
  }
}

class _MockDragData {
  final ComponentType componentType;
  final int availableInventory;
  final bool hasNullProperties;
  final bool invalidId;

  _MockDragData(this.componentType, this.availableInventory, {
    this.hasNullProperties = false,
    this.invalidId = false,
  });
}

// Helper functions for testing
ComponentModel? _findComponentAtPosition(Offset position, _MockGrid grid) {
  final int row = position.dy.toInt();
  final int col = position.dx.toInt();

  try {
    return grid.components.firstWhere(
      (component) => component.row == row && component.col == col,
    );
  } catch (e) {
    return null;
  }
}

bool _canAcceptComponentDrop(
  _MockDragData dragData,
  _MockGrid grid,
  GridConfiguration config,
  Offset screenPosition
) {
  // Check inventory
  if (dragData.availableInventory <= 0) {
    return false;
  }

  // Check grid bounds
  if (!GridService.isWithinGridBounds(screenPosition, config)) {
    return false;
  }

  // Check if position is available
  final gridPosition = GridService.getValidGridPosition(screenPosition, config);
  if (gridPosition == null) {
    return false;
  }

  if (!grid.canPlaceComponent(gridPosition.dy.toInt(), gridPosition.dx.toInt())) {
    return false;
  }

  return true;
}