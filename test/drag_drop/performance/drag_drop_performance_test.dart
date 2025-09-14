import 'package:flutter/material.dart';
import '../../lib/core/entity/grid_configuration.dart'
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';

void main() {
  group('Drag and Drop Performance Tests', () {
    late GridConfiguration config;

    setUp(() {
      config = const GridConfiguration(
        rows: 10,
        cols: 10,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );
    });

    test('High-frequency coordinate conversions under 1000ms', () {
      final stopwatch = Stopwatch()..start();

      // Perform 1000 coordinate conversions
      for (var i = 0; i < 1000; i++) {
        final screenPos = Offset(i % 600, (i ~/ 600) * 60.0);
        GridService.screenToGrid(screenPos, config);
      }

      stopwatch.stop();

      debugPrint(
          '🔍 Performance test: 1000 coordinate conversions took ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Bulk coordinate validation under 500ms', () {
      final stopwatch = Stopwatch()..start();

      // Test coordinate validation for 100 positions
      var validCount = 0;
      for (var i = 0; i < 100; i++) {
        final gridPos = Offset(i % 10, (i ~/ 10) % 10);
        if (GridService.isInGridBounds(gridPos, config)) {
          validCount++;
        }
      }

      stopwatch.stop();

      debugPrint(
          '🔍 Performance test: 100 coordinate validations took ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect(validCount, equals(100)); // All should be valid in our 10x10 grid
    });

    test('Snap to grid operations under 500ms', () {
      final stopwatch = Stopwatch()..start();

      // Test snapping 500 positions
      for (var i = 0; i < 500; i++) {
        final screenPos = Offset(i * 1.2, i * 1.2);
        GridService.snapToGrid(screenPos, config);
      }

      stopwatch.stop();

      debugPrint(
          '🔍 Performance test: 500 snap operations took ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Complex grid operations scale factor handling', () {
      final testConfigs = [
        config.copyWith(scale: 0.5),
        config.copyWith(scale: 1),
        config.copyWith(scale: 2),
        config.copyWith(scale: 5),
      ];

      final stopwatch = Stopwatch()..start();

      // Test with different scales
      for (final testConfig in testConfigs) {
        for (var i = 0; i < 100; i++) {
          const screenPos = Offset(300, 300);
          GridService.screenToGrid(screenPos, testConfig);
        }
      }

      stopwatch.stop();

      debugPrint(
          '🔍 Performance test: Scale factor operations took ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Pan offset calculation performance with offsets', () {
      final panConfigs = [
        config.copyWith(panOffset: const Offset(100, 100)),
        config.copyWith(panOffset: const Offset(-50, -50)),
        config.copyWith(panOffset: const Offset(1000, 1000)),
      ];

      final stopwatch = Stopwatch()..start();

      for (final panConfig in panConfigs) {
        for (var i = 0; i < 200; i++) {
          final screenPos = Offset(200.0 + i, 200.0 + i);
          GridService.screenToGrid(screenPos, panConfig);
        }
      }

      stopwatch.stop();

      debugPrint(
          '🔍 Performance test: Pan offset operations took ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Edge case performance: boundary checking at scale', () {
      const extremeConfig = GridConfiguration(
        rows: 1000,
        cols: 1000,
        cellSize: 60,
        scale: 10,
        panOffset: Offset(50000, 50000),
      );

      final stopwatch = Stopwatch()..start();

      // Test boundary operations on large grid
      for (var i = 0; i < 100; i++) {
        final testPos = Offset(i * 100, i * 100);
        GridService.getValidGridPosition(testPos, extremeConfig);
      }

      stopwatch.stop();

      debugPrint(
          '🔍 Performance test: Large grid boundary check took ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Memory efficiency: repeated configuration creation', () {
      final stopwatch = Stopwatch()..start();

      // Create 1000 configuration objects
      for (var i = 0; i < 1000; i++) {
        final testConfig = GridConfiguration(
          rows: 10 + (i % 10),
          cols: 10 + (i % 10),
          cellSize: 60.0 + (i % 60),
          scale: 1.0 + (i % 5) * 0.1,
          panOffset: Offset(i * 0.1, i * 0.1),
        );

        // Perform operation with new config
        const testPos = Offset(100, 100);
        GridService.screenToGrid(testPos, testConfig);
      }

      stopwatch.stop();

      debugPrint(
          '🔍 Performance test: 1000 config creations took ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('Concurrent operation simulation', () {
      final stopwatch = Stopwatch()..start();

      // Simulate concurrent operations
      final futures = <Future>[];

      for (var i = 0; i < 50; i++) {
        futures.add(Future(() {
          for (var j = 0; j < 20; j++) {
            final screenPos = Offset(j * 10, j * 10);
            GridService.screenToGrid(screenPos, config);
          }
        }));
      }

      // Wait for all operations to complete
      Future.wait(futures).then((_) {
        stopwatch.stop();
        debugPrint(
            '🔍 Performance test: Concurrent operations took ${stopwatch.elapsedMilliseconds}ms');
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      });
    });
  });
}
