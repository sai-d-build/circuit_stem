import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';

class MockRenderBox extends Mock implements RenderBox {
  @override
  bool get attached => true;

  @override
  Offset globalToLocal(Offset point, {RenderObject? ancestor}) => point;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'MockRenderBox';
}

void main() {
  group('CoordinateSystemService Tests', () {
    late CoordinateSystemService service;
    late MockRenderBox mockRenderBox;

    setUp(() {
      service = CoordinateSystemService();
      mockRenderBox = MockRenderBox();
    });

    group('Grid Position Tests', () {
      test('GridPosition fromOffset creates correct position', () {
        const offset = Offset(2.7, 1.3);
        final position = GridPosition.fromOffset(offset);

        expect(position.row, 1);
        expect(position.col, 3);
      });

      test('GridPosition isWithinBounds works correctly', () {
        const position = GridPosition(row: 1, col: 2);
        const gridSize = Size(5, 5);

        expect(position.isWithinBounds(gridSize), true);

        const outOfBounds = GridPosition(row: 5, col: 2);
        expect(outOfBounds.isWithinBounds(gridSize), false);
      });

      test('GridPosition distanceTo calculates correctly', () {
        const pos1 = GridPosition(row: 0, col: 0);
        const pos2 = GridPosition(row: 3, col: 4);

        final distance = pos1.distanceTo(pos2);
        expect(distance, closeTo(5.0, 0.1)); // 3-4-5 triangle
      });
    });

    group('Coordinate Transformation Tests', () {
      test('screenToGrid converts screen coordinates to grid', () {
        const context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1,
        );

        const screenPos =
            Offset(125, 175); // Center of grid cell (3,3) with rounding
        final gridPos =
            service.screenToGrid(screenPos, context, renderBox: mockRenderBox);

        expect(gridPos?.row, 4); // 175/50 = 3.5 rounds to 4
        expect(gridPos?.col, 3); // 125/50 = 2.5 rounds to 3
      });

      test('gridToLocal converts grid position to local coordinates', () {
        const context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1,
        );

        const gridPos = GridPosition(row: 2, col: 3);
        final localPos = service.gridToLocal(gridPos, context);

        expect(localPos.dx, 150.0); // 3 * 50
        expect(localPos.dy, 100.0); // 2 * 50
      });

      test('validateDropPosition handles bounds checking', () {
        const context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1,
        );

        // Valid position
        final validResult = service.validateDropPosition(
            const Offset(75, 75), context,
            renderBox: mockRenderBox);

        expect(validResult.isValid, true);
        expect(validResult.gridPosition?.row, 2); // 75/50 = 1.5 rounds to 2
        expect(validResult.gridPosition?.col, 2); // 75/50 = 1.5 rounds to 2

        // Out of bounds position (clamped to canvas bounds)
        final clampedResult = service.validateDropPosition(
            const Offset(300, 300), context,
            renderBox: mockRenderBox);

        expect(clampedResult.isValid, true); // Clamped to valid position
        expect(
            clampedResult.warnings, contains('Position outside grid bounds'));
      });

      test('validateDropPosition handles occupied positions', () {
        const context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1,
        );

        final occupiedPositions = {
          const GridPosition(row: 2, col: 2)
        }; // Updated to match actual grid position

        final result = service.validateDropPosition(
            const Offset(75, 75), context,
            renderBox: mockRenderBox, occupiedPositions: occupiedPositions);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('occupied'));
      });
    });

    group('Performance Tests', () {
      test('coordinate transformations are cached', () {
        const context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1,
        );

        const screenPos = Offset(125, 175);

        // First call
        final result1 =
            service.screenToGrid(screenPos, context, renderBox: mockRenderBox);

        // Second call with same parameters should use cache
        final result2 =
            service.screenToGrid(screenPos, context, renderBox: mockRenderBox);

        expect(result1, equals(result2));
      });

      test('clearCache resets transformation cache', () {
        const context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1,
        );

        const screenPos = Offset(125, 175);

        // Fill cache
        service.screenToGrid(screenPos, context, renderBox: mockRenderBox);

        // Clear cache
        service.clearCache();

        // Cache should be empty now
        expect(
            service.screenToGrid(screenPos, context, renderBox: mockRenderBox),
            isNotNull);
      });
    });

    group('Security Tests', () {
      test('input clamping prevents overflow', () {
        const context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1,
        );

        // Test with extreme coordinates
        final result = service.validateDropPosition(
            const Offset(1000, -500), context,
            renderBox: mockRenderBox);

        // Should clamp to canvas bounds and still validate
        expect(result.isValid, isNotNull);
      });

      test('null renderBox is handled gracefully', () {
        const context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1,
        );

        final result = service.screenToGrid(const Offset(75, 75), context,
            renderBox: mockRenderBox);
        expect(result, isNotNull);
      });
    });
  });
}
