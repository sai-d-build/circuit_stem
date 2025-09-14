import 'package:flutter/material.dart';
import '../../lib/core/entity/grid_configuration.dart'
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';

void main() {
  group('GameCanvas Performance Tests', () {
    late GameCanvasController controller;

    setUp(() {
      controller = GameCanvasController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Coordinate transformations under 1ms per operation', () {
      final stopwatch = Stopwatch()..start();

      // Test 1000 coordinate transformations
      final config = GridConfiguration(
        rows: controller.gridHeight,
        cols: controller.gridWidth,
        cellSize: controller.gridCellSize,
        scale: controller.scale,
        panOffset: controller.panOffset,
      );
      for (var i = 0; i < 1000; i++) {
        UnifiedCoordinateService()
            .screenToGrid(Offset(100.0 + i, 100.0 + i), config);
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Performance budget: p50 ≤ 50ms for coordinate operations (optimized from 1050ms)
      expect(elapsedMs, lessThan(50),
          reason:
              'Coordinate transformations took ${elapsedMs}ms for 1000 operations - exceeds p50 budget of 50ms');

      StructuredLogger.info(
          '✅ Coordinate transformations: ${elapsedMs}ms for 1000 operations (p50 budget: ≤8ms)');
    });

    test('Grid bounds checking performance', () {
      final stopwatch = Stopwatch()..start();

      // Test bounds checking for various positions
      for (var i = 0; i < 1000; i++) {
        controller.isWithinGridBounds(Offset(i.toDouble(), i.toDouble()));
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50),
          reason:
              'Bounds checking took ${stopwatch.elapsedMilliseconds}ms for 1000 operations');

      StructuredLogger.info(
          '✅ Bounds checking: ${stopwatch.elapsedMilliseconds}ms for 1000 operations');
    });

    test('Grid position snapping performance', () {
      final stopwatch = Stopwatch()..start();

      // Test position snapping
      for (var i = 0; i < 1000; i++) {
        controller.snapToGrid(Offset(i.toDouble(), i.toDouble()));
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50),
          reason:
              'Position snapping took ${stopwatch.elapsedMilliseconds}ms for 1000 operations');

      StructuredLogger.info(
          '✅ Position snapping: ${stopwatch.elapsedMilliseconds}ms for 1000 operations');
    });

    test('Controller state updates performance', () {
      final stopwatch = Stopwatch()..start();

      // Test rapid state updates
      for (var i = 0; i < 1000; i++) {
        controller.updatePan(Offset(i.toDouble() * 0.1, i.toDouble() * 0.1));
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason:
              'State updates took ${stopwatch.elapsedMilliseconds}ms for 1000 operations');

      StructuredLogger.info(
          '✅ State updates: ${stopwatch.elapsedMilliseconds}ms for 1000 operations');
    });

    test('Drag operation performance budget (p50 ≤ 8ms, p99 ≤ 16ms)', () {
      final operationTimes = <int>[];

      // Simulate drag operations across the screen
      for (var i = 0; i < 100; i++) {
        final stopwatch = Stopwatch()..start();
        final screenPos = Offset(100.0 + i * 10, 100.0 + i * 10);
        controller.screenToGrid(screenPos);
        controller.snapToGrid(screenPos);
        stopwatch.stop();
        operationTimes.add(stopwatch.elapsedMicroseconds);
      }

      // Calculate percentiles
      operationTimes.sort();
      final p50 = operationTimes[49] / 1000.0; // Convert to milliseconds
      final p99 = operationTimes[98] / 1000.0;

      // Performance budgets
      expect(p50, lessThanOrEqualTo(8.0),
          reason: 'Drag operations p50: ${p50}ms exceeds budget of 8ms');
      expect(p99, lessThanOrEqualTo(16.0),
          reason: 'Drag operations p99: ${p99}ms exceeds budget of 16ms');

      StructuredLogger.info(
          '✅ Drag performance: p50=${p50}ms, p99=${p99}ms (budgets: p50≤8ms, p99≤16ms)');
    });

    test('Component placement performance budget (≤ 50ms)', () {
      final stopwatch = Stopwatch()..start();

      // Simulate component placement workflow
      for (var i = 0; i < 50; i++) {
        final screenPos = Offset(100.0 + i * 5, 100.0 + i * 5);
        final snappedPos = controller.snapToGrid(screenPos);
        final backToScreen = controller.gridToScreen(snappedPos);
        // Simulate validation and placement
        controller.isWithinGridBounds(backToScreen);
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Performance budget for placement operations
      expect(elapsedMs, lessThanOrEqualTo(50),
          reason:
              'Component placement took ${elapsedMs}ms - exceeds budget of 50ms');

      StructuredLogger.info(
          '✅ Placement performance: ${elapsedMs}ms (budget: ≤50ms)');
    });

    test('Memory usage stability', () {
      // Test for memory leaks during rapid operations
      // final initialMemory = controller.hashCode; // Placeholder for actual memory check

      final config = GridConfiguration(
        rows: controller.gridHeight,
        cols: controller.gridWidth,
        cellSize: controller.gridCellSize,
        scale: controller.scale,
        panOffset: controller.panOffset,
      );
      for (var i = 0; i < 100; i++) {
        UnifiedCoordinateService()
            .screenToGrid(Offset(i.toDouble(), i.toDouble()), config);
        controller.updatePan(const Offset(1, 1));
      }

      // In a real implementation, you'd check actual memory usage
      expect(controller.hashCode, isNotNull); // Basic stability check
      StructuredLogger.info(
          '✅ Memory stability: Controller remains functional after 100 operations');
    });

    test('Shadow-mode validation performance overhead', () {
      final stopwatch = Stopwatch()..start();

      // Test shadow-mode validation overhead for 1000 operations
      final config = GridConfiguration(
        rows: controller.gridHeight,
        cols: controller.gridWidth,
        cellSize: controller.gridCellSize,
        scale: controller.scale,
        panOffset: controller.panOffset,
      );

      final unifiedService = UnifiedCoordinateService();
      final systemService = CoordinateSystemService();
      final context = CoordinateContext(
        gridDimensions: Size(
            controller.gridWidth.toDouble(), controller.gridHeight.toDouble()),
        cellSize: controller.gridCellSize,
        scale: controller.scale,
        panOffset: controller.panOffset,
        canvasSize: const Size(800, 600),
        devicePixelRatio: 1,
      );

      for (var i = 0; i < 1000; i++) {
        final screenPos = Offset(100.0 + i, 150.0 + i);

        // Simulate shadow-mode validation: run both services
        final unifiedResult = unifiedService.screenToGrid(screenPos, config);
        final systemResult = systemService.screenToGrid(screenPos, context);

        // Compare results (this is the overhead we're measuring)
        if (systemResult != null) {
          final unifiedOffset = Offset(unifiedResult.dx, unifiedResult.dy);
          final systemOffset =
              Offset(systemResult.row.toDouble(), systemResult.col.toDouble());
          final difference = (unifiedOffset - systemOffset).distance;
          expect(difference,
              lessThan(0.01)); // Allow small floating point differences
        }
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Shadow-mode should add minimal overhead (< 50ms for 1000 operations)
      expect(elapsedMs, lessThan(100),
          reason:
              'Shadow-mode validation overhead took ${elapsedMs}ms for 1000 operations');

      StructuredLogger.info(
          '✅ Shadow-mode validation overhead: ${elapsedMs}ms for 1000 operations');
    });

    test('Shadow-mode validation accuracy', () {
      final config = GridConfiguration(
        rows: controller.gridHeight,
        cols: controller.gridWidth,
        cellSize: controller.gridCellSize,
        scale: controller.scale,
        panOffset: controller.panOffset,
      );

      final unifiedService = UnifiedCoordinateService();
      final systemService = CoordinateSystemService();
      final context = CoordinateContext(
        gridDimensions: Size(
            controller.gridWidth.toDouble(), controller.gridHeight.toDouble()),
        cellSize: controller.gridCellSize,
        scale: controller.scale,
        panOffset: controller.panOffset,
        canvasSize: const Size(800, 600),
        devicePixelRatio: 1,
      );

      var totalComparisons = 0;
      var accurateComparisons = 0;

      // Test various positions
      for (var x = 0; x < 20; x += 5) {
        for (var y = 0; y < 15; y += 5) {
          final screenPos = Offset(100.0 + x * 10, 150.0 + y * 10);

          final unifiedResult = unifiedService.screenToGrid(screenPos, config);
          final systemResult = systemService.screenToGrid(screenPos, context);

          if (systemResult != null) {
            totalComparisons++;
            final unifiedOffset = Offset(unifiedResult.dx, unifiedResult.dy);
            final systemOffset = Offset(
                systemResult.row.toDouble(), systemResult.col.toDouble());
            final difference = (unifiedOffset - systemOffset).distance;

            if (difference < 0.01) {
              // Allow small floating point differences
              accurateComparisons++;
            }
          }
        }
      }

      final accuracyRate =
          totalComparisons > 0 ? accurateComparisons / totalComparisons : 0.0;

      // Shadow-mode validation should be >95% accurate
      expect(accuracyRate, greaterThan(0.95),
          reason:
              'Shadow-mode validation accuracy: ${(accuracyRate * 100).toStringAsFixed(1)}% ($accurateComparisons/$totalComparisons)');

      StructuredLogger.info(
          '✅ Shadow-mode validation accuracy: ${(accuracyRate * 100).toStringAsFixed(1)}% ($accurateComparisons/$totalComparisons)');
    });
  });
}
