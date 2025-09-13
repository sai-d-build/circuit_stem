import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/canvas_interaction_controller.dart';

void main() {
  group('Wire Pathfinding', () {
    test('should calculate Manhattan path between adjacent ports', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 0, col: 0),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 0, col: 2),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      expect(path.length, 3); // start -> middle -> end
      expect(path[0], const GridPosition(row: 0, col: 0));
      expect(path[1], const GridPosition(row: 0, col: 1));
      expect(path[2], const GridPosition(row: 0, col: 2));
    });

    test('should calculate L-shaped Manhattan path', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 0, col: 0),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 2, col: 2),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      expect(
          path.length, 5); // start -> horizontal -> corner -> vertical -> end
      expect(path[0], const GridPosition(row: 0, col: 0));
      expect(path[1], const GridPosition(row: 0, col: 1));
      expect(path[2], const GridPosition(row: 0, col: 2));
      expect(path[3], const GridPosition(row: 1, col: 2));
      expect(path[4], const GridPosition(row: 2, col: 2));
    });

    test('should handle same position (no path needed)', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 1, col: 1),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 1, col: 1),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      expect(path.length, 1);
      expect(path[0], const GridPosition(row: 1, col: 1));
    });

    test('should handle vertical-only paths', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 0, col: 1),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 3, col: 1),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      expect(path.length, 4);
      expect(path[0], const GridPosition(row: 0, col: 1));
      expect(path[1], const GridPosition(row: 1, col: 1));
      expect(path[2], const GridPosition(row: 2, col: 1));
      expect(path[3], const GridPosition(row: 3, col: 1));
    });

    test('should handle reverse direction paths', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 2, col: 2),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 0, col: 0),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      expect(path.length, 5);
      expect(path[0], const GridPosition(row: 2, col: 2));
      expect(path[1], const GridPosition(row: 2, col: 1));
      expect(path[2], const GridPosition(row: 2, col: 0));
      expect(path[3], const GridPosition(row: 1, col: 0));
      expect(path[4], const GridPosition(row: 0, col: 0));
    });

    test('should avoid duplicate positions in path', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 1, col: 1),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 1, col: 1),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      // Should not have duplicates
      final uniquePositions = path.toSet();
      expect(uniquePositions.length, path.length);
    });

    test('should handle large grid distances', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 0, col: 0),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 10, col: 15),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      expect(path.length, 26); // 15 horizontal + 10 vertical + 1 start = 26
      expect(path.first, const GridPosition(row: 0, col: 0));
      expect(path.last, const GridPosition(row: 10, col: 15));
    });

    test('should maintain connectivity between adjacent path segments', () {
      const start = ComponentPort(
        id: 'port1',
        position: GridPosition(row: 1, col: 1),
        type: PortType.output,
      );

      const end = ComponentPort(
        id: 'port2',
        position: GridPosition(row: 3, col: 4),
        type: PortType.input,
      );

      final path = _calculateWirePath(start, end);

      // Check that each segment connects to the next
      for (var i = 0; i < path.length - 1; i++) {
        final current = path[i];
        final next = path[i + 1];

        final isAdjacent = (current.row == next.row &&
                (current.col - next.col).abs() == 1) ||
            (current.col == next.col && (current.row - next.row).abs() == 1);

        expect(isAdjacent, true,
            reason: 'Positions $current and $next should be adjacent');
      }
    });
  });

  group('Wire Validation', () {
    test('should validate wire placement constraints', () {
      // Test wire doesn't overlap with existing components
      final occupiedPositions = {
        const GridPosition(row: 1, col: 1),
        const GridPosition(row: 1, col: 2),
      };

      final wirePath = [
        const GridPosition(row: 0, col: 0),
        const GridPosition(row: 0, col: 1),
        const GridPosition(row: 0, col: 2),
      ];

      final hasConflicts = _checkWireConflicts(wirePath, occupiedPositions);
      expect(hasConflicts, false); // No conflicts with wire path
    });

    test('should detect wire placement conflicts', () {
      final occupiedPositions = {
        const GridPosition(row: 1, col: 1),
      };

      final wirePath = [
        const GridPosition(row: 1, col: 0),
        const GridPosition(row: 1, col: 1), // Conflict here
        const GridPosition(row: 1, col: 2),
      ];

      final hasConflicts = _checkWireConflicts(wirePath, occupiedPositions);
      expect(hasConflicts, true);
    });
  });
}

// Helper function copied from CanvasInteractionController for testing
List<GridPosition> _calculateWirePath(ComponentPort start, ComponentPort end) {
  final path = <GridPosition>[];
  final current = start.position;
  path.add(current);

  // Horizontal move
  final hTarget = GridPosition(row: current.row, col: end.position.col);
  if (hTarget.col > current.col) {
    for (var col = current.col + 1; col <= hTarget.col; col++) {
      path.add(GridPosition(row: current.row, col: col));
    }
  } else {
    for (var col = current.col - 1; col >= hTarget.col; col--) {
      path.add(GridPosition(row: current.row, col: col));
    }
  }

  // Vertical move
  final vTarget = GridPosition(row: end.position.row, col: end.position.col);
  if (vTarget.row > hTarget.row) {
    for (var row = hTarget.row + 1; row <= vTarget.row; row++) {
      path.add(GridPosition(row: row, col: hTarget.col));
    }
  } else {
    for (var row = hTarget.row - 1; row >= vTarget.row; row--) {
      path.add(GridPosition(row: row, col: hTarget.col));
    }
  }

  return path;
}

bool _checkWireConflicts(
    List<GridPosition> wirePath, Set<GridPosition> occupiedPositions) {
  return wirePath.any((position) => occupiedPositions.contains(position));
}
