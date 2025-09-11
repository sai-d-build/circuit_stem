// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';

void main() {
  group('Interaction Performance Benchmarks', () {
    late CoordinateSystemService coordinateService;

    setUp(() {
      coordinateService = CoordinateSystemService();
    });

    test('should handle rapid coordinate transformations efficiently', () {
      final context = CoordinateContext(
        gridDimensions: const Size(20, 15),
        cellSize: 50.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(1000, 750),
        devicePixelRatio: 1.0,
      );

      final mockRenderBox = MockRenderBox();

      // Benchmark 1000 coordinate transformations
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        final screenPos = Offset(100 + i % 900, 100 + i % 650);
        final gridPos = coordinateService.screenToGrid(screenPos, context, renderBox: mockRenderBox);
        expect(gridPos, isNotNull);
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Should complete 1000 transformations in under 100ms (< 0.1ms per transformation)
      expect(elapsedMs, lessThan(100));
      print('1000 coordinate transformations took ${elapsedMs}ms (${elapsedMs / 1000}ms per transformation)');
    });

    test('should maintain performance with caching enabled', () {
      final context = CoordinateContext(
        gridDimensions: const Size(20, 15),
        cellSize: 50.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(1000, 750),
        devicePixelRatio: 1.0,
      );

      final mockRenderBox = MockRenderBox();

      // Test cached performance by repeating the same transformations
      final repeatedPositions = [
        const Offset(200, 150),
        const Offset(300, 250),
        const Offset(400, 350),
      ];

      final stopwatch = Stopwatch()..start();

      // Perform 300 transformations (100 of each position)
      for (int i = 0; i < 100; i++) {
        for (final pos in repeatedPositions) {
          final gridPos = coordinateService.screenToGrid(pos, context, renderBox: mockRenderBox);
          expect(gridPos, isNotNull);
        }
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Cached transformations should be very fast
      expect(elapsedMs, lessThan(50));
      print('300 cached transformations took ${elapsedMs}ms (${elapsedMs / 300}ms per transformation)');
    });

    test('should handle complex scaling scenarios efficiently', () {
      final mockRenderBox = MockRenderBox();

      // Test various scale factors
      final scaleFactors = [0.5, 1.0, 1.5, 2.0, 3.0];

      for (final scale in scaleFactors) {
        final context = CoordinateContext(
          gridDimensions: const Size(20, 15),
          cellSize: 50.0,
          scale: scale,
          panOffset: Offset.zero,
          canvasSize: const Size(1000, 750),
          devicePixelRatio: 1.0,
        );

        final stopwatch = Stopwatch()..start();

        // Test 100 transformations at this scale
        for (int i = 0; i < 100; i++) {
          final screenPos = Offset(100 + i * 8, 100 + i * 6);
          final gridPos = coordinateService.screenToGrid(screenPos, context, renderBox: mockRenderBox);
          expect(gridPos, isNotNull);
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        // Each scale factor should maintain good performance
        expect(elapsedMs, lessThan(20));
        print('Scale $scale: 100 transformations took ${elapsedMs}ms');
      }
    });

    test('should perform well under memory pressure', () {
      final context = CoordinateContext(
        gridDimensions: const Size(50, 50), // Large grid
        cellSize: 20.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(1000, 1000),
        devicePixelRatio: 1.0,
      );

      final mockRenderBox = MockRenderBox();

      // Clear cache before test
      coordinateService.clearCache();

      final stopwatch = Stopwatch()..start();

      // Perform many transformations to stress the cache
      for (int row = 0; row < 50; row++) {
        for (int col = 0; col < 50; col++) {
          final screenPos = Offset(col * 20.0, row * 20.0);
          final gridPos = coordinateService.screenToGrid(screenPos, context, renderBox: mockRenderBox);
          expect(gridPos, isNotNull);
          expect(gridPos!.row, row);
          expect(gridPos.col, col);
        }
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // 2500 transformations should complete efficiently
      expect(elapsedMs, lessThan(500));
      print('2500 transformations took ${elapsedMs}ms (${elapsedMs / 2500}ms per transformation)');
    });

    test('should handle concurrent validation requests efficiently', () {
      final context = CoordinateContext(
        gridDimensions: const Size(20, 15),
        cellSize: 50.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(1000, 750),
        devicePixelRatio: 1.0,
      );

      final mockRenderBox = MockRenderBox();
      final occupiedPositions = <GridPosition>{};

      // Create some occupied positions
      for (int i = 0; i < 10; i++) {
        occupiedPositions.add(GridPosition(row: i, col: i));
      }

      final stopwatch = Stopwatch()..start();

      // Perform 500 validation requests
      for (int i = 0; i < 500; i++) {
        final screenPos = Offset(50 + i % 900, 50 + i % 650);
        final result = coordinateService.validateDropPosition(
          screenPos,
          context,
          renderBox: mockRenderBox,
          occupiedPositions: occupiedPositions,
        );
        expect(result, isNotNull);
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // 500 validations should complete quickly
      expect(elapsedMs, lessThan(100));
      print('500 validation requests took ${elapsedMs}ms (${elapsedMs / 500}ms per validation)');
    });

    test('should maintain performance with boundary checking', () {
      final context = CoordinateContext(
        gridDimensions: const Size(10, 10),
        cellSize: 50.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(500, 500),
        devicePixelRatio: 1.0,
      );

      final mockRenderBox = MockRenderBox();

      final stopwatch = Stopwatch()..start();

      // Test positions at and beyond boundaries
      for (int x = -50; x < 600; x += 25) {
        for (int y = -50; y < 600; y += 25) {
          final screenPos = Offset(x.toDouble(), y.toDouble());
          coordinateService.screenToGrid(screenPos, context, renderBox: mockRenderBox);
          // Grid position can be null for out-of-bounds positions
        }
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Boundary checking should not significantly impact performance
      expect(elapsedMs, lessThan(200));
      print('Boundary checking for ${((600 + 50) / 25) * ((600 + 50) / 25)} positions took ${elapsedMs}ms');
    });

    test('should handle rapid cache invalidation efficiently', () {
      final context = CoordinateContext(
        gridDimensions: const Size(20, 15),
        cellSize: 50.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(1000, 750),
        devicePixelRatio: 1.0,
      );

      final mockRenderBox = MockRenderBox();

      // Fill cache with transformations
      for (int i = 0; i < 100; i++) {
        final screenPos = Offset(100 + i * 8, 100 + i * 5);
        coordinateService.screenToGrid(screenPos, context, renderBox: mockRenderBox);
      }

      final stopwatch = Stopwatch()..start();

      // Clear cache and perform new transformations
      coordinateService.clearCache();

      for (int i = 0; i < 100; i++) {
        final screenPos = Offset(200 + i * 8, 200 + i * 5);
        final gridPos = coordinateService.screenToGrid(screenPos, context, renderBox: mockRenderBox);
        expect(gridPos, isNotNull);
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      // Cache invalidation and new transformations should be efficient
      expect(elapsedMs, lessThan(30));
      print('Cache invalidation + 100 new transformations took ${elapsedMs}ms');
    });
  });
}

class MockRenderBox extends RenderBox {
  @override
  bool get attached => true;

  @override
  Offset globalToLocal(Offset globalPosition, {RenderObject? ancestor}) => globalPosition;
}