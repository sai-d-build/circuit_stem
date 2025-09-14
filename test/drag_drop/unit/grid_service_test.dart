import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/entity/grid_configuration.dart'
import 'package:sparkcircuit/core/services/grid_service.dart';

void main() {
  group('GridService Coordinate Conversion Tests', () {
    late GridConfiguration testConfig;

    setUp(() {
      testConfig = const GridConfiguration(
        rows: 10,
        cols: 10,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
    });

    test(
        'screenToGrid converts screen coordinates to grid coordinates correctly',
        () {
      // Test center of cell (0,0) - should be (0.5, 0.5) in grid coordinates
      const screenPos = Offset(30, 30); // Center of (0,0) cell
      final gridPos = GridService.screenToGrid(screenPos, testConfig);

      expect(gridPos.dx, closeTo(0.5, 0.01));
      expect(gridPos.dy, closeTo(0.5, 0.01));
    });

    test(
        'gridToScreen converts grid coordinates to screen coordinates correctly',
        () {
      // Test center of cell (0,0) - should be (30, 30) in screen coordinates
      const gridPos = Offset(0.5, 0.5);
      final screenPos = GridService.gridToScreen(gridPos, testConfig);

      expect(screenPos.dx, closeTo(30, 0.01));
      expect(screenPos.dy, closeTo(30, 0.01));
    });

    test('screenToGrid with scale and pan offset', () {
      const scaledConfig = GridConfiguration(
        rows: 10,
        cols: 10,
        cellSize: 60,
        scale: 2,
        panOffset: Offset(100, 50),
      );

      // Screen position after pan and scale transformations
      // (130, 80) - (100, 50) = (30, 30) -> / 2.0 = (15, 15) -> / 60 = (0.25, 0.25)
      const screenPos = Offset(130, 80);
      final gridPos = GridService.screenToGrid(screenPos, scaledConfig);

      expect(gridPos.dx, closeTo(0.25, 0.01));
      expect(gridPos.dy, closeTo(0.25, 0.01));
    });

    test('gridToScreen with scale and pan offset', () {
      const scaledConfig = GridConfiguration(
        rows: 10,
        cols: 10,
        cellSize: 60,
        scale: 2,
        panOffset: Offset(100, 50),
      );

      // Grid position (0.5, 0.5) -> * 60 = (30, 30) -> * 2.0 = (60, 60) -> + (100, 50) = (160, 110)
      const gridPos = Offset(0.5, 0.5);
      final screenPos = GridService.gridToScreen(gridPos, scaledConfig);

      expect(screenPos.dx, closeTo(160, 0.01));
      expect(screenPos.dy, closeTo(110, 0.01));
    });

    test('snapToGrid snaps to nearest grid cell center', () {
      // Position close to (1,1) cell center
      const screenPos = Offset(85, 85); // Should snap to (1,1)
      final snappedPos = GridService.snapToGrid(screenPos, testConfig);

      expect(snappedPos.dx, closeTo(1.0, 0.01));
      expect(snappedPos.dy, closeTo(1.0, 0.01));
    });

    test('isInGridBounds correctly validates grid positions', () {
      expect(
          GridService.isInGridBounds(const Offset(0, 0), testConfig), isTrue);
      expect(
          GridService.isInGridBounds(const Offset(5, 5), testConfig), isTrue);
      expect(
          GridService.isInGridBounds(const Offset(9, 9), testConfig), isTrue);
      expect(GridService.isInGridBounds(const Offset(10, 10), testConfig),
          isFalse);
      expect(GridService.isInGridBounds(const Offset(-1, -1), testConfig),
          isFalse);
    });

    test('getValidGridPosition returns valid positions within bounds', () {
      final validPos =
          GridService.getValidGridPosition(const Offset(150, 150), testConfig);
      expect(validPos, isNotNull);
      expect(validPos!.dx, closeTo(2.0, 0.01)); // 150/60 = 2.5, floor to 2
      expect(validPos.dy, closeTo(2.0, 0.01));

      final invalidPos =
          GridService.getValidGridPosition(const Offset(-50, -50), testConfig);
      expect(invalidPos, isNull);
    });
  });
}
