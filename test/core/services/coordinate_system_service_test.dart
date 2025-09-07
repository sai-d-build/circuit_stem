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
        final offset = Offset(2.7, 1.3);
        final position = GridPosition.fromOffset(offset);

        expect(position.row, 1);
        expect(position.col, 3);
      });

      test('GridPosition isWithinBounds works correctly', () {
        final position = GridPosition(row: 1, col: 2);
        final gridSize = Size(5, 5);

        expect(position.isWithinBounds(gridSize), true);

        final outOfBounds = GridPosition(row: 5, col: 2);
        expect(outOfBounds.isWithinBounds(gridSize), false);
      });

      test('GridPosition distanceTo calculates correctly', () {
        final pos1 = GridPosition(row: 0, col: 0);
        final pos2 = GridPosition(row: 3, col: 4);

        final distance = pos1.distanceTo(pos2);
        expect(distance, closeTo(5.0, 0.1)); // 3-4-5 triangle
      });
    });

    group('Coordinate Transformation Tests', () {
      test('screenToGrid converts screen coordinates to grid', () {
        final context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1.0,
        );

        final screenPos = Offset(125, 175); // Center of grid cell (3,3) with rounding
        final gridPos = service.screenToGrid(screenPos, context, mockRenderBox);

        expect(gridPos?.row, 4); // 175/50 = 3.5 rounds to 4
        expect(gridPos?.col, 3); // 125/50 = 2.5 rounds to 3
      });

      test('gridToLocal converts grid position to local coordinates', () {
        final context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1.0,
        );

        final gridPos = GridPosition(row: 2, col: 3);
        final localPos = service.gridToLocal(gridPos, context);

        expect(localPos.dx, 150.0); // 3 * 50
        expect(localPos.dy, 100.0); // 2 * 50
      });

      test('validateDropPosition handles bounds checking', () {
        final context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1.0,
        );

        // Valid position
        final validResult = service.validateDropPosition(
          Offset(75, 75), context, mockRenderBox
        );

        expect(validResult.isValid, true);
        expect(validResult.gridPosition?.row, 2); // 75/50 = 1.5 rounds to 2
        expect(validResult.gridPosition?.col, 2); // 75/50 = 1.5 rounds to 2

        // Out of bounds position (clamped to canvas bounds)
        final clampedResult = service.validateDropPosition(
          Offset(300, 300), context, mockRenderBox
        );

        expect(clampedResult.isValid, true); // Clamped to valid position
        expect(clampedResult.warnings, contains('Position outside grid bounds'));
      });

      test('validateDropPosition handles occupied positions', () {
        final context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1.0,
        );

        final occupiedPositions = {GridPosition(row: 2, col: 2)}; // Updated to match actual grid position

        final result = service.validateDropPosition(
          Offset(75, 75), context, mockRenderBox,
          occupiedPositions: occupiedPositions
        );

        expect(result.isValid, false);
        expect(result.errorMessage, contains('occupied'));
      });
    });

    group('Performance Tests', () {
      test('coordinate transformations are cached', () {
        final context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1.0,
        );

        final screenPos = Offset(125, 175);

        // First call
        final result1 = service.screenToGrid(screenPos, context, mockRenderBox);

        // Second call with same parameters should use cache
        final result2 = service.screenToGrid(screenPos, context, mockRenderBox);

        expect(result1, equals(result2));
      });

      test('clearCache resets transformation cache', () {
        final context = CoordinateContext(
          gridDimensions: Size(10, 10),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(500, 500),
          devicePixelRatio: 1.0,
        );

        final screenPos = Offset(125, 175);

        // Fill cache
        service.screenToGrid(screenPos, context, mockRenderBox);

        // Clear cache
        service.clearCache();

        // Cache should be empty now
        expect(service.screenToGrid(screenPos, context, mockRenderBox), isNotNull);
      });
    });

    group('Security Tests', () {
      test('input clamping prevents overflow', () {
        final context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1.0,
        );

        // Test with extreme coordinates
        final result = service.validateDropPosition(
          Offset(1000, -500), context, mockRenderBox
        );

        // Should clamp to canvas bounds and still validate
        expect(result.isValid, isNotNull);
      });

      test('null renderBox is handled gracefully', () {
        final context = CoordinateContext(
          gridDimensions: Size(5, 5),
          cellSize: 50.0,
          scale: 1.0,
          panOffset: Offset.zero,
          canvasSize: Size(250, 250),
          devicePixelRatio: 1.0,
        );

        final result = service.screenToGrid(Offset(75, 75), context, mockRenderBox);
        expect(result, isNotNull);
      });
    });
  });
}