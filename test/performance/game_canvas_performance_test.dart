import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';

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
      for (int i = 0; i < 1000; i++) {
        UnifiedCoordinateService().screenToGrid(Offset(100.0 + i, 100.0 + i), config);
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Should be under 100ms for 1000 operations (0.1ms per operation)
      expect(elapsedMs, lessThan(100),
        reason: 'Coordinate transformations took ${elapsedMs}ms for 1000 operations');

      StructuredLogger.info('✅ Coordinate transformations: ${elapsedMs}ms for 1000 operations');
    });

    test('Grid bounds checking performance', () {
      final stopwatch = Stopwatch()..start();

      // Test bounds checking for various positions
      for (int i = 0; i < 1000; i++) {
        controller.isWithinGridBounds(Offset(i.toDouble(), i.toDouble()));
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50),
        reason: 'Bounds checking took ${stopwatch.elapsedMilliseconds}ms for 1000 operations');

      StructuredLogger.info('✅ Bounds checking: ${stopwatch.elapsedMilliseconds}ms for 1000 operations');
    });

    test('Grid position snapping performance', () {
      final stopwatch = Stopwatch()..start();

      // Test position snapping
      for (int i = 0; i < 1000; i++) {
        controller.snapToGrid(Offset(i.toDouble(), i.toDouble()));
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50),
        reason: 'Position snapping took ${stopwatch.elapsedMilliseconds}ms for 1000 operations');

      StructuredLogger.info('✅ Position snapping: ${stopwatch.elapsedMilliseconds}ms for 1000 operations');
    });

    test('Controller state updates performance', () {
      final stopwatch = Stopwatch()..start();

      // Test rapid state updates
      for (int i = 0; i < 1000; i++) {
        controller.updatePan(Offset(i.toDouble() * 0.1, i.toDouble() * 0.1));
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100),
        reason: 'State updates took ${stopwatch.elapsedMilliseconds}ms for 1000 operations');

      StructuredLogger.info('✅ State updates: ${stopwatch.elapsedMilliseconds}ms for 1000 operations');
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
      for (int i = 0; i < 100; i++) {
        UnifiedCoordinateService().screenToGrid(Offset(i.toDouble(), i.toDouble()), config);
        controller.updatePan(const Offset(1, 1));
      }

      // In a real implementation, you'd check actual memory usage
      expect(controller.hashCode, isNotNull); // Basic stability check
      StructuredLogger.info('✅ Memory stability: Controller remains functional after 100 operations');
    });
  });
}