import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';

void main() {
  group('Coordinate Conversion Tests', () {
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

    group('screenToGrid Tests', () {
      test('Offset(0, 0) converts to grid coordinate (0, 0)', () {
        final result = GridService.screenToGrid(Offset.zero, config);
        expect(result, equals(Offset.zero));
      });

      test('Offset(60, 60) converts to grid coordinate (1, 1)', () {
        final result = GridService.screenToGrid(const Offset(60, 60), config);
        expect(result, equals(const Offset(1, 1)));
      });

      test('Offset(30, 30) converts to grid coordinate (0.5, 0.5)', () {
        final result = GridService.screenToGrid(const Offset(30, 30), config);
        expect(result, equals(const Offset(0.5, 0.5)));
      });

      test('Converts with scale factor 2.0', () {
        final scaledConfig = config.copyWith(scale: 2.0);
        final result = GridService.screenToGrid(const Offset(120, 120), scaledConfig);
        expect(result, equals(const Offset(1, 1)));
      });

      test('Converts with pan offset', () {
        final pannedConfig = config.copyWith(panOffset: const Offset(60, 60));
        final result = GridService.screenToGrid(const Offset(120, 120), pannedConfig);
        expect(result, equals(const Offset(1, 1)));
      });

      test('Converts with both scale and pan', () {
        final config = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 60.0,
          scale: 2.0,
          panOffset: Offset(30, 30),
        );
        final result = GridService.screenToGrid(const Offset(150, 150), config);
        expect(result, equals(const Offset(1, 1)));
      });
    });

    group('gridToScreen Tests', () {
      test('Grid(0, 0) converts to screen Offset(30, 30) for cellSize 60', () {
        final config = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 60.0,
          scale: 1.0,
          panOffset: Offset.zero,
        );
        final result = GridService.gridToScreen(const Offset(0, 0), config);
        expect(result, equals(const Offset(30, 30))); // Cell center
      });

      test('Grid(1, 1) converts to screen Offset(90, 90)', () {
        final result = GridService.gridToScreen(const Offset(1, 1), config);
        expect(result, equals(const Offset(90, 90)));
      });

      test('Grid coordinates convert with pan offset', () {
        final pannedConfig = config.copyWith(panOffset: const Offset(20, 20));
        final result = GridService.gridToScreen(const Offset(0, 0), pannedConfig);
        expect(result, equals(const Offset(50, 50))); // 30 + 20
      });
    });

    group('getValidGridPosition Tests', () {
      test('Returns valid position within bounds', () {
        final result = GridService.getValidGridPosition(const Offset(30, 30), config);
        expect(result, equals(const Offset(0, 0)));
      });

      test('Returns null for negative coordinates', () {
        final result = GridService.getValidGridPosition(const Offset(-30, 30), config);
        expect(result, isNull);
      });

      test('Returns null for coordinates outside grid bounds', () {
        final result = GridService.getValidGridPosition(const Offset(600, 600), config);
        expect(result, isNull);
      });

      test('Returns snapped coordinates for valid positions', () {
        final result = GridService.getValidGridPosition(const Offset(30.7, 30.7), config);
        expect(result, equals(const Offset(0, 0)));
      });

      test('Handles edge case at grid boundary', () {
        final result = GridService.getValidGridPosition(const Offset(570, 570), config); // 9.5 * 60 = 570
        expect(result, equals(const Offset(9, 9)));
      });

      test('Handles scale factor in boundary calculations', () {
        final scaledConfig = config.copyWith(scale: 0.5);
        final result = GridService.getValidGridPosition(const Offset(15, 15), scaledConfig);
        expect(result, isNotNull);
      });
    });

    group('Snap to Grid Tests', () {
      test('Snap to nearest grid cell from center', () {
        final config1 = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 60.0,
          scale: 1.0,
          panOffset: Offset.zero,
        );
        final result = GridService.snapToGrid(const Offset(30, 30), config1);
        expect(result.dx, equals(0)); // Snap to cell (0,0) center
        expect(result.dy, equals(0));
      });

      test('Snap to nearest grid cell from offset position', () {
        final config2 = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 60.0,
          scale: 1.0,
          panOffset: Offset.zero,
        );
        final result = GridService.snapToGrid(const Offset(90, 90), config2);
        expect(result.dx, equals(1)); // Snap to cell (1,1) center
        expect(result.dy, equals(1));
      });

      test('Snap handles fractional positions correctly', () {
        final config3 = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 60.0,
          scale: 1.0,
          panOffset: Offset.zero,
        );
        final result = GridService.snapToGrid(const Offset(30.2, 30.8), config3);
        expect(result.dx, equals(0)); // Should still snap to (0,0)
        expect(result.dy, equals(0));
      });

      test('Snap rounds up at midpoint', () {
        final config4 = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 60.0,
          scale: 1.0,
          panOffset: Offset.zero,
        );
        final result = GridService.snapToGrid(const Offset(60, 60), config4);
        expect(result.dx, equals(1)); // Snap to cell (1,1) center
        expect(result.dy, equals(1));
      });

      test('Snap works with different cell sizes', () {
        final config5 = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 40.0,
          scale: 1.0,
          panOffset: Offset.zero,
        );
        final result = GridService.snapToGrid(const Offset(20, 20), config5); // 20/40 - 0.5 = -0.5 -> round to 0
        expect(result.dx, equals(0));
        expect(result.dy, equals(0));
      });
    });

    group('Coordinate Validation Tests', () {
      test('Valid coordinates return true using isInGridBounds', () {
        expect(GridService.isInGridBounds(const Offset(0, 0), config), isTrue);
        expect(GridService.isInGridBounds(const Offset(5, 5), config), isTrue);
        expect(GridService.isInGridBounds(const Offset(9, 9), config), isTrue);
      });

      test('Negative coordinates return false', () {
        expect(GridService.isInGridBounds(const Offset(-1, 0), config), isFalse);
        expect(GridService.isInGridBounds(const Offset(0, -1), config), isFalse);
      });

      test('Out of bounds coordinates return false', () {
        expect(GridService.isInGridBounds(const Offset(10, 0), config), isFalse);
        expect(GridService.isInGridBounds(const Offset(0, 10), config), isFalse);
        expect(GridService.isInGridBounds(const Offset(15, 15), config), isFalse);
      });

      test('Edge cases at boundaries', () {
        expect(GridService.isInGridBounds(const Offset(0, 9), config), isTrue);
        expect(GridService.isInGridBounds(const Offset(9, 0), config), isTrue);
      });
    });

    group('Pixel Density and High DPI Tests', () {
      test('Handles high DPI coordinates correctly', () {
        final highDpiConfig = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 120.0, // 60 * 2 for high DPI
          scale: 0.5,
          panOffset: Offset.zero,
        );
        final result = GridService.screenToGrid(const Offset(60, 60), highDpiConfig);
        expect(result, equals(const Offset(0.5, 0.5)));
      });

      test('Works with fractional scale factors', () {
        final fractionalConfig = config.copyWith(scale: 1.5);
        final result = GridService.screenToGrid(const Offset(90, 90), fractionalConfig);
        expect(result.dx, equals(1.0));
        expect(result.dy, equals(1.0));
      });

      test('Handles very small scales gracefully', () {
        final smallScaleConfig = config.copyWith(scale: 0.1);
        final result = GridService.screenToGrid(const Offset(6, 6), smallScaleConfig);
        expect(result, equals(const Offset(1, 1)));
      });
    });

    group('Pan and Zoom Interaction Tests', () {
      test('Pan offset affects coordinate conversion', () {
        final panConfig = config.copyWith(panOffset: const Offset(120, 120));
        final result = GridService.screenToGrid(const Offset(120, 120), panConfig);
        expect(result, equals(const Offset(0, 0)));
      });

      test('Both pan and zoom work together', () {
        final complexConfig = const GridConfiguration(
          rows: 10,
          cols: 10,
          cellSize: 60.0,
          scale: 2.0,
          panOffset: Offset(60, 60),
        );
        final result = GridService.screenToGrid(const Offset(180, 180), complexConfig);
        expect(result, equals(const Offset(1, 1)));
      });

      test('Zoom factor affects sensitivity', () {
        // Higher zoom = smaller movements needed to reach same grid position
        final zoomConfig = config.copyWith(scale: 2.0);
        final result = GridService.screenToGrid(const Offset(60, 60), zoomConfig);
        expect(result, equals(const Offset(0.5, 0.5)));
      });
    });
  });
}