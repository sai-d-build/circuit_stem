import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';

void main() {
  group('CoordinateSystemService', () {
    late CoordinateSystemService service;

    setUp(() {
      service = CoordinateSystemService();
    });

    test('should convert screen coordinates to grid position', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      final result = service.screenToGrid(const Offset(60, 60), context,
          renderBox: mockRenderBox);

      expect(result, isNotNull);
      expect(result!.row, 1);
      expect(result.col, 1);
    });

    test('should validate drop positions correctly', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      final result = service.validateDropPosition(
        const Offset(60, 60),
        context,
        renderBox: mockRenderBox,
      );

      expect(result.isValid, true);
      expect(result.gridPosition, isNotNull);
    });

    test('should handle positions outside grid bounds with warnings', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      final result = service.validateDropPosition(
        const Offset(700, 700), // Outside canvas
        context,
        renderBox: mockRenderBox,
      );

      // New behavior: positions outside bounds are allowed but with warnings
      expect(result.isValid, true);
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('outside grid bounds'));
    });

    test('should convert grid positions to local coordinates', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      const gridPos = GridPosition(row: 1, col: 1);
      final result = service.gridToLocal(gridPos, context);

      expect(result.dx, 60.0);
      expect(result.dy, 60.0);
    });

    test('should handle scaling transformations correctly', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 2, // 2x zoom
        panOffset: Offset.zero,
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      final result = service.screenToGrid(const Offset(120, 120), context,
          renderBox: mockRenderBox);

      expect(result, isNotNull);
      expect(result!.row, 1);
      expect(result.col, 1);
    });

    test('should handle pan offset transformations correctly', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 1,
        panOffset: Offset(30, 30), // Panned
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      final result = service.screenToGrid(const Offset(90, 90), context,
          renderBox: mockRenderBox);

      expect(result, isNotNull);
      expect(result!.row, 1);
      expect(result.col, 1);
    });

    test('should cache repeated screenToGrid calls', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      const position = Offset(60, 60);

      // First call
      final result1 =
          service.screenToGrid(position, context, renderBox: mockRenderBox);
      // Second call (should use cache)
      final result2 =
          service.screenToGrid(position, context, renderBox: mockRenderBox);

      expect(result1, equals(result2));
    });

    test('should clear cache when requested', () {
      const context = CoordinateContext(
        gridDimensions: Size(10, 10),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: Size(600, 600),
        devicePixelRatio: 1,
      );

      final mockRenderBox = MockRenderBox();
      const position = Offset(60, 60);

      // First call
      service.screenToGrid(position, context, renderBox: mockRenderBox);
      // Clear cache
      service.clearCache();
      // Third call (should not use cache)
      final result3 =
          service.screenToGrid(position, context, renderBox: mockRenderBox);

      expect(result3, isNotNull);
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
