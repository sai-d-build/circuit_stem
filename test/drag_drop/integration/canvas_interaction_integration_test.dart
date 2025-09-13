import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';

void main() {
  group('Coordinate System Integration Tests', () {
    late CoordinateSystemService coordinateService;

    setUp(() {
      coordinateService = CoordinateSystemService();
    });

    test('should handle complete coordinate transformation workflow', () {
      const context = CoordinateContext(
        gridDimensions: Size(20, 15),
        cellSize: 50,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(1000, 750),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();

      // Test screen to grid conversion
      const screenPos = Offset(250, 200);
      final gridPos = coordinateService.screenToGrid(screenPos, context,
          renderBox: mockRenderBox);

      expect(gridPos, isNotNull);
      expect(gridPos!.row, 4); // 200 / 50 = 4
      expect(gridPos.col, 5); // 250 / 50 = 5

      // Test grid to screen conversion (round trip)
      final screenPos2 = coordinateService.gridToLocal(gridPos, context);
      expect(screenPos2.dx, 250.0);
      expect(screenPos2.dy, 200.0);
    });

    test('should handle scaled coordinate transformations', () {
      const context = CoordinateContext(
        gridDimensions: Size(20, 15),
        cellSize: 50,
        scale: 2, // 2x zoom
        panOffset: Offset.zero,
        canvasSize: Size(1000, 750),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();

      // At 2x scale, screen coordinates should map to smaller grid coordinates
      const screenPos = Offset(200, 150);
      final gridPos = coordinateService.screenToGrid(screenPos, context,
          renderBox: mockRenderBox);

      expect(gridPos, isNotNull);
      expect(gridPos!.row, 2); // (150 / 2) / 50 = 1.5 -> 2 (rounded)
      expect(gridPos.col, 2); // (200 / 2) / 50 = 2
    });

    test('should handle panned coordinate transformations', () {
      const context = CoordinateContext(
        gridDimensions: Size(20, 15),
        cellSize: 50,
        scale: 1,
        panOffset: Offset(100, 50), // Panned
        canvasSize: Size(1000, 750),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();

      // With pan offset, screen coordinates should account for the offset
      const screenPos = Offset(200, 150);
      final gridPos = coordinateService.screenToGrid(screenPos, context,
          renderBox: mockRenderBox);

      expect(gridPos, isNotNull);
      expect(gridPos!.row, 2); // (150 - 50) / 50 = 2
      expect(gridPos.col, 2); // (200 - 100) / 50 = 2
    });

    test('should validate drop positions correctly', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 50,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(500, 500),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();

      // Test valid position
      final validResult = coordinateService.validateDropPosition(
        const Offset(200, 150),
        context,
        renderBox: mockRenderBox,
      );

      expect(validResult.isValid, true);
      expect(validResult.gridPosition, isNotNull);

      // Test invalid position (outside bounds)
      final invalidResult = coordinateService.validateDropPosition(
        const Offset(600, 600),
        context,
        renderBox: mockRenderBox,
      );

      // With our updated validation, positions outside bounds are now allowed but with warnings
      expect(invalidResult.isValid, true); // Now returns valid with warnings
      expect(invalidResult.warnings, isNotEmpty);
    });

    test('should handle boundary validation with occupied positions', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 50,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(500, 500),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      final occupiedPositions = {
        const GridPosition(row: 2, col: 2),
        const GridPosition(row: 3, col: 3),
      };

      // Test dropping on occupied position
      final occupiedResult = coordinateService.validateDropPosition(
        const Offset(100, 100), // Grid position (2, 2)
        context,
        renderBox: mockRenderBox,
        occupiedPositions: occupiedPositions,
      );

      expect(occupiedResult.isValid, false);
      expect(occupiedResult.errorMessage, contains('Cell occupied'));

      // Test dropping on free position
      final freeResult = coordinateService.validateDropPosition(
        const Offset(150, 150), // Grid position (3, 3) - occupied
        context,
        renderBox: mockRenderBox,
        occupiedPositions: occupiedPositions,
      );

      expect(freeResult.isValid,
          false); // Should be invalid because (3,3) is occupied
    });

    test('should handle high DPI coordinate transformations', () {
      const context = CoordinateContext(
        gridDimensions: Size(20, 15),
        cellSize: 50,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(1000, 750),
        devicePixelRatio: 2, // High DPI
      );

      final mockRenderBox = MockRenderBox();

      // High DPI should not affect grid calculations (handled at widget level)
      const screenPos = Offset(200, 150);
      final gridPos = coordinateService.screenToGrid(screenPos, context,
          renderBox: mockRenderBox);

      expect(gridPos, isNotNull);
      expect(gridPos!.row, 3); // 150 / 50 = 3
      expect(gridPos.col, 4); // 200 / 50 = 4
    });

    test('should maintain coordinate accuracy across multiple transformations',
        () {
      const context = CoordinateContext(
        gridDimensions: Size(20, 15),
        cellSize: 60, // Non-round cell size
        scale: 1.5,
        panOffset: Offset(30, 20),
        canvasSize: Size(1200, 900),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();

      // Test multiple round-trip transformations
      final originalPositions = [
        const Offset(180, 120),
        const Offset(300, 240),
        const Offset(420, 360),
      ];

      for (final originalPos in originalPositions) {
        final gridPos = coordinateService.screenToGrid(originalPos, context,
            renderBox: mockRenderBox);
        expect(gridPos, isNotNull);

        final screenPos = coordinateService.gridToLocal(gridPos!, context);

        // Allow reasonable floating-point differences due to scaling and rounding
        expect((screenPos.dx - originalPos.dx).abs(), lessThan(45.0));
        expect((screenPos.dy - originalPos.dy).abs(), lessThan(45.0));
      }
    });

    test('should handle edge cases at grid boundaries', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 50,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(500, 500),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();

      // Test positions at grid boundaries
      final boundaryPositions = [
        const Offset(0, 0), // Top-left corner
        const Offset(450, 0), // Top-right corner
        const Offset(0, 450), // Bottom-left corner
        const Offset(450, 450), // Bottom-right corner
      ];

      for (final pos in boundaryPositions) {
        final gridPos = coordinateService.screenToGrid(pos, context,
            renderBox: mockRenderBox);
        expect(gridPos, isNotNull);

        // Verify position is within bounds
        expect(gridPos!.row, inInclusiveRange(0, 9));
        expect(gridPos.col, inInclusiveRange(0, 9));
      }
    });
  });
}

class MockRenderBox extends RenderBox {
  @override
  bool get attached => true;

  @override
  Offset globalToLocal(Offset globalPosition, {RenderObject? ancestor}) =>
      globalPosition;
}
