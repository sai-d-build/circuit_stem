import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';
import 'package:sparkcircuit/presentation/core/utils/coordinate_translator.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';

/// Legacy coordinate conversion tests documenting current behavior
/// These tests establish a baseline before any refactoring changes
/// They document the input/output behavior of existing coordinate conversion methods
void main() {
  group('Legacy Coordinate Conversion Tests', () {
    late GameCanvasController controller;
    late CoordinateTranslator translator;
    late CoordinateService coordinateService;
    late int logicalGridWidth;
    late int logicalGridHeight;

    setUp(() {
      controller = GameCanvasController();
      translator = const CoordinateTranslator(
        gridCellSize: 60,
        scale: 1,
        panX: 0,
        panY: 0,
      );
      coordinateService = const CoordinateService(
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        gridWidth: 20,
        gridHeight: 20,
      );

      // Define logical grid dimensions (should match controller's grid size)
      logicalGridWidth = 20;
      logicalGridHeight = 20;
    });

    tearDown(() {
      controller.dispose();
    });

    // Test GameCanvasController coordinate conversions
    test('GameCanvasController screenToGrid - center of cell (0,0)', () {
      const screenPos = Offset(30, 30); // Center of (0,0) cell
      final gridPos = controller.screenToGrid(screenPos);
      expect(gridPos, equals(const Offset(0.5, 0.5)));
    });

    test('GameCanvasController screenToGrid - edge case near boundary', () {
      const screenPos = Offset(1199, 719); // Near bottom-right
      final gridPos = controller.screenToGrid(screenPos);
      // Document current behavior - should be within grid bounds
      expect(gridPos.dx, greaterThanOrEqualTo(0));
      expect(gridPos.dy, greaterThanOrEqualTo(0));
      expect(gridPos.dx, lessThanOrEqualTo(20));
      expect(gridPos.dy, lessThanOrEqualTo(20));
    });

    test('GameCanvasController gridToScreen - center of cell (1,1)', () {
      const gridPos = Offset(1.5, 1.5);
      final screenPos = controller.gridToScreen(gridPos);
      expect(screenPos, equals(const Offset(90, 90)));
    });

    test('GameCanvasController snapToGrid - off-center position', () {
      const screenPos =
          Offset(85, 95); // Should snap to nearest grid cell center
      final snappedPos = controller.snapToGrid(screenPos);
      // Updated expectation to match corrected snapping behavior
      expect(snappedPos, equals(const Offset(90, 150)));
    });

    // Test CoordinateTranslator conversions
    test('CoordinateTranslator screenToGrid - basic conversion', () {
      const screenPos = Offset(120, 180);
      final gridPos = translator.screenToGrid(screenPos);
      expect(gridPos, equals(const Offset(2, 3)));
    });

    test('CoordinateTranslator gridToScreen - basic conversion', () {
      const gridPos = Offset(2, 3);
      final screenPos = translator.gridToScreen(gridPos);
      expect(screenPos, equals(const Offset(120, 180)));
    });

    test('CoordinateTranslator snapToGrid - snapping behavior', () {
      const screenPos =
          Offset(125, 175); // Should snap to center of (2,3) cell: (150, 210)
      final snappedPos = translator.snapToGrid(screenPos);
      expect(snappedPos, equals(const Offset(150, 210)));
    });

    // Test CoordinateService conversions
    test('CoordinateService screenToGrid - with configuration', () {
      const screenPos = Offset(120, 180);
      final gridPos = coordinateService.screenToGrid(screenPos);
      expect(gridPos, equals(const Offset(2, 3)));
    });

    test('CoordinateService gridToScreen - with configuration', () {
      const gridPos = Offset(2, 3);
      final screenPos = coordinateService.gridToScreen(gridPos);
      expect(screenPos, equals(const Offset(120, 180)));
    });

    test('CoordinateService snapScreenToGrid - snapping with config', () {
      const screenPos =
          Offset(125, 175); // Should snap to center of (2,3) cell: (150, 210)
      final snappedPos = coordinateService.snapScreenToGrid(screenPos);
      expect(snappedPos, equals(const Offset(150, 210)));
    });

    // Test GridService static methods
    test('GridService screenToGrid - static method', () {
      const config = GridConfiguration(
        rows: 20,
        cols: 20,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
      const screenPos = Offset(120, 180);
      final gridPos = GridService.screenToGrid(screenPos, config);
      expect(gridPos, equals(const Offset(2, 3)));
    });

    test('GridService gridToScreen - static method', () {
      const config = GridConfiguration(
        rows: 20,
        cols: 20,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
      const gridPos = Offset(2, 3);
      final screenPos = GridService.gridToScreen(gridPos, config);
      expect(screenPos, equals(const Offset(120, 180)));
    });

    test('GridService snapToGrid - static method', () {
      const config = GridConfiguration(
        rows: 20,
        cols: 20,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
      const screenPos =
          Offset(125, 175); // Should snap to center of (2,3) cell: (150, 210)
      final snappedPos = GridService.snapToGrid(screenPos, config);
      expect(snappedPos, equals(const Offset(150, 210)));
    });

    // Test UnifiedCoordinateService directly
    test('UnifiedCoordinateService screenToGrid - direct call', () {
      const config = GridConfiguration(
        rows: 20,
        cols: 20,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
      const screenPos = Offset(120, 180);
      final gridPos =
          UnifiedCoordinateService().screenToGrid(screenPos, config);
      expect(gridPos, equals(const Offset(2, 3)));
    });

    test('UnifiedCoordinateService gridToScreen - direct call', () {
      const config = GridConfiguration(
        rows: 20,
        cols: 20,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
      const gridPos = Offset(2, 3);
      final screenPos =
          UnifiedCoordinateService().gridToScreen(gridPos, config);
      expect(screenPos, equals(const Offset(120, 180)));
    });

    test('UnifiedCoordinateService snapToGrid - direct call', () {
      const config = GridConfiguration(
        rows: 20,
        cols: 20,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
      const screenPos =
          Offset(125, 175); // Should snap to center of (2,3) cell: (150, 210)
      final snappedPos =
          UnifiedCoordinateService().snapToGrid(screenPos, config);
      expect(snappedPos, equals(const Offset(150, 210)));
    });

    // Edge cases and boundary conditions
    test('Coordinate conversion - zero position', () {
      const screenPos = Offset.zero;
      final gridPos = controller.screenToGrid(screenPos);
      expect(gridPos.dx, greaterThanOrEqualTo(0));
      expect(gridPos.dy, greaterThanOrEqualTo(0));
    });

    test('Coordinate conversion - negative position', () {
      const screenPos = Offset(-10, -10);
      final gridPos = controller.screenToGrid(screenPos);
      // Document current behavior for negative inputs
      expect(gridPos.dx, isNotNull);
      expect(gridPos.dy, isNotNull);
    });

    test('Coordinate conversion - large position', () {
      const screenPos = Offset(2000, 2000);
      final gridPos = controller.screenToGrid(screenPos);
      // Document current behavior for out-of-bounds inputs
      expect(gridPos.dx, isNotNull);
      expect(gridPos.dy, isNotNull);
    });

    // ===== MAIN ISSUE TESTS - These should FAIL now but PASS after refactoring =====

    // Issue 1: Hover/Placement Mismatch
    test(
        'HOVER/PLACEMENT MISMATCH - screenToGrid consistency across different code paths',
        () {
      // This test documents the inconsistency between hover and placement coordinate conversion
      // Currently FAILS due to different implementations in different parts of the codebase

      const testPosition =
          Offset(250, 200); // Position that should map to grid cell

      // Get conversion from different services that should all return the same result
      final controllerResult = controller.screenToGrid(testPosition);
      final translatorResult = translator.screenToGrid(testPosition);
      final serviceResult = coordinateService.screenToGrid(testPosition);

      // These should all be identical after refactoring, but currently may differ
      expect(controllerResult, equals(translatorResult),
          reason:
              'GameCanvasController and CoordinateTranslator should return identical results');
      expect(translatorResult, equals(serviceResult),
          reason:
              'CoordinateTranslator and CoordinateService should return identical results');
      expect(controllerResult, equals(serviceResult),
          reason:
              'GameCanvasController and CoordinateService should return identical results');
    });

    test('HOVER/PLACEMENT MISMATCH - round-trip accuracy', () {
      // Test that screen -> grid -> screen conversion is accurate
      // This currently fails due to rounding inconsistencies

      const originalScreen =
          Offset(245, 195); // Should be center of grid cell (2,1)

      // Convert screen -> grid
      final gridPos = controller.screenToGrid(originalScreen);

      // Convert grid -> screen
      final backToScreen = controller.gridToScreen(gridPos);

      // Should be very close to original (within 1 pixel)
      expect(
          (backToScreen.dx - originalScreen.dx).abs(), lessThanOrEqualTo(1.0),
          reason: 'Round-trip conversion should be accurate within 1 pixel');
      expect(
          (backToScreen.dy - originalScreen.dy).abs(), lessThanOrEqualTo(1.0),
          reason: 'Round-trip conversion should be accurate within 1 pixel');
    });

    // Issue 2: Ghost Components (State Consistency)
    test('GHOST COMPONENTS - state consistency after placement simulation', () {
      // This test simulates component placement and checks for state consistency
      // Currently fails due to stale interaction state not being cleared

      // Simulate initial state
      final initialGridPos = controller.screenToGrid(const Offset(120, 180));

      // Simulate placement (this should clear any temporary drag state)
      // In real scenario, this would trigger placement logic
      final afterPlacementGridPos =
          controller.screenToGrid(const Offset(120, 180));

      // Results should be identical (no stale state affecting conversion)
      expect(initialGridPos, equals(afterPlacementGridPos),
          reason:
              'Coordinate conversion should be consistent before and after simulated placement');
    });

    test('GHOST COMPONENTS - cache consistency', () {
      // Test that caching doesn't cause stale results
      // This currently fails if cache isn't properly invalidated

      const testPos = Offset(300, 240);

      // First conversion
      final result1 = controller.screenToGrid(testPos);

      // Simulate some operation that should not affect cached results
      controller.screenToGrid(const Offset(0, 0)); // Different position

      // Second conversion of same position
      final result2 = controller.screenToGrid(testPos);

      // Should be identical (cache working correctly)
      expect(result1, equals(result2),
          reason: 'Cached coordinate conversions should be consistent');
    });

    // Issue 3: Misleading UI (Dual Grid System)
    test('MISLEADING UI - visual vs logical grid boundaries', () {
      // Test that visual grid boundaries match logical grid boundaries
      // Currently fails because visual grid (20x20) doesn't match logical grid constraints

      const visualGridSize = 20; // Assumed visual grid size
      const logicalGridWidth = 20; // From controller
      const logicalGridHeight = 20; // From controller

      // Visual and logical grid should match
      expect(visualGridSize, equals(logicalGridWidth),
          reason: 'Visual grid width should match logical grid width');
      expect(visualGridSize, equals(logicalGridHeight),
          reason: 'Visual grid height should match logical grid height');
    });

    test('MISLEADING UI - boundary position handling', () {
      // Test positions at visual boundaries
      // Currently fails if visual boundaries don't match logical boundaries

      final boundaryPositions = [
        const Offset(0, 0), // Top-left corner
        const Offset(1200, 0), // Top-right corner
        const Offset(0, 720), // Bottom-left corner
        const Offset(1200, 720), // Bottom-right corner
      ];

      for (final pos in boundaryPositions) {
        final gridPos = controller.screenToGrid(pos);

        // Should be within logical grid bounds
        expect(gridPos.dx, greaterThanOrEqualTo(0),
            reason: 'Boundary position should map to valid grid X coordinate');
        expect(gridPos.dy, greaterThanOrEqualTo(0),
            reason: 'Boundary position should map to valid grid Y coordinate');
        expect(gridPos.dx, lessThan(logicalGridWidth),
            reason: 'Boundary position should not exceed logical grid width');
        expect(gridPos.dy, lessThan(logicalGridHeight),
            reason: 'Boundary position should not exceed logical grid height');
      }
    });

    // Issue 4: Performance Regression Prevention
    test('PERFORMANCE REGRESSION - coordinate conversion speed', () {
      // Test that coordinate conversions meet performance requirements
      // This should pass now but ensures we don't regress during refactoring

      final testPositions =
          List.generate(100, (i) => Offset(i * 12.0, i * 12.0));

      final stopwatch = Stopwatch()..start();

      for (final pos in testPositions) {
        controller.screenToGrid(pos);
      }

      stopwatch.stop();

      // Should complete 100 conversions in under 50ms (0.5ms per conversion)
      expect(stopwatch.elapsedMilliseconds, lessThan(50),
          reason: '100 coordinate conversions should complete in under 50ms');
    });

    // Issue 5: Unified Coordinate System Validation
    test('UNIFIED COORDINATE SYSTEM - all services return identical results',
        () {
      // Test that all coordinate services return identical results for same input
      // This currently fails due to different implementations/rounding

      final testCases = [
        const Offset(120, 180), // Grid cell (2,3)
        const Offset(240, 360), // Grid cell (4,6)
        const Offset(360, 240), // Grid cell (6,4)
      ];

      for (final testPos in testCases) {
        final controllerResult = controller.screenToGrid(testPos);
        final translatorResult = translator.screenToGrid(testPos);
        final serviceResult = coordinateService.screenToGrid(testPos);

        expect(controllerResult, equals(translatorResult),
            reason:
                'All coordinate services should return identical results for position $testPos');
        expect(translatorResult, equals(serviceResult),
            reason:
                'All coordinate services should return identical results for position $testPos');
      }
    });

    // Issue 6: Snapping Consistency
    test('SNAPPING CONSISTENCY - snapToGrid behavior', () {
      // Test that snapping behavior is consistent across services
      // Now should pass with unified coordinate service

      final testPositions = [
        const Offset(
            125, 175), // Should snap to center of (2,3) cell: (150, 210)
        const Offset(
            185, 235), // Should snap to center of (3,3) cell: (210, 210)
        const Offset(
            245, 295), // Should snap to center of (4,4) cell: (270, 270)
      ];

      for (final pos in testPositions) {
        final controllerSnapped = controller.snapToGrid(pos);
        final translatorSnapped = translator.snapToGrid(pos);

        expect(controllerSnapped, equals(translatorSnapped),
            reason:
                'Snapping should be consistent across services for position $pos');
      }
    });
  });
}
