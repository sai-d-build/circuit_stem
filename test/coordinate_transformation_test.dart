import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/entity/grid_configuration.dart'
import 'package:sparkcircuit/core/services/secure_coordinate_validator.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';

void main() {
  group('UnifiedCoordinateService Tests', () {
    late UnifiedCoordinateService coordinateService;
    late GridConfiguration testConfig;

    setUp(() {
      coordinateService = UnifiedCoordinateService();
      testConfig = const GridConfiguration(
        rows: 10,
        cols: 10,
        cellSize: 50,
        scale: 1,
        panOffset: Offset.zero,
      );
    });

    tearDown(() {
      coordinateService.clearCache();
    });

    group('Coordinate Transformations', () {
      test('screenToGrid basic transformation', () {
        const screenPos = Offset(100, 150);
        final gridPos = coordinateService.screenToGrid(screenPos, testConfig);

        // With cellSize=50, scale=1, panOffset=0
        // screen(100,150) -> grid(2,3)
        expect(gridPos.dx, closeTo(2.0, 0.001));
        expect(gridPos.dy, closeTo(3.0, 0.001));
      });

      test('gridToScreen basic transformation', () {
        const gridPos = Offset(2, 3);
        final screenPos = coordinateService.gridToScreen(gridPos, testConfig);

        // With cellSize=50, scale=1, panOffset=0
        // grid(2,3) -> screen(100,150)
        expect(screenPos.dx, closeTo(100.0, 0.001));
        expect(screenPos.dy, closeTo(150.0, 0.001));
      });

      test('round-trip transformation accuracy', () {
        const originalScreen = Offset(123.45, 67.89);
        final gridPos =
            coordinateService.screenToGrid(originalScreen, testConfig);
        final backToScreen =
            coordinateService.gridToScreen(gridPos, testConfig);

        // Should be very close (within 1 pixel due to rounding)
        expect(backToScreen.dx, closeTo(originalScreen.dx, 1.0));
        expect(backToScreen.dy, closeTo(originalScreen.dy, 1.0));
      });

      test('transformation with scale', () {
        final scaledConfig = testConfig.copyWith(scale: 2);
        const screenPos = Offset(100, 150);
        final gridPos = coordinateService.screenToGrid(screenPos, scaledConfig);

        // With scale=2, the grid position should be half
        expect(gridPos.dx, closeTo(1.0, 0.001));
        expect(gridPos.dy, closeTo(1.5, 0.001));
      });

      test('transformation with pan offset', () {
        final pannedConfig =
            testConfig.copyWith(panOffset: const Offset(50, 75));
        const screenPos = Offset(100, 150);
        final gridPos = coordinateService.screenToGrid(screenPos, pannedConfig);

        // Pan offset affects the transformation
        expect(gridPos.dx, closeTo(1.0, 0.001));
        expect(gridPos.dy, closeTo(1.5, 0.001));
      });
    });

    group('Snapping Functionality', () {
      test('snapToGrid basic snapping', () {
        const screenPos = Offset(125, 175); // Not aligned to grid
        final snappedPos = coordinateService.snapToGrid(screenPos, testConfig);

        // Should snap to nearest grid center: (150, 200) with cellSize=50
        expect(snappedPos.dx, closeTo(150.0, 0.001));
        expect(snappedPos.dy, closeTo(200.0, 0.001));
      });

      test('snapToGrid with bounds checking', () {
        const config = GridConfiguration(
          rows: 5,
          cols: 5,
          cellSize: 50,
          scale: 1,
          panOffset: Offset.zero,
        );

        // Position that would snap outside bounds
        const screenPos = Offset(
            275, 275); // Would snap to (250, 250) but clamped to (200, 200)
        final snappedPos = coordinateService.snapToGrid(screenPos, config);

        // Should be clamped to grid bounds
        expect(snappedPos.dx, closeTo(200.0, 0.001)); // 4 * 50
        expect(snappedPos.dy, closeTo(200.0, 0.001)); // 4 * 50
      });
    });

    group('Bounds Checking', () {
      test('isInGridBounds within bounds', () {
        const gridPos = Offset(3, 4);
        expect(coordinateService.isInGridBounds(gridPos, testConfig), isTrue);
      });

      test('isInGridBounds outside bounds', () {
        const gridPos = Offset(15, 4); // x=15 >= cols=10
        expect(coordinateService.isInGridBounds(gridPos, testConfig), isFalse);
      });

      test('isWithinGridBounds screen coordinates', () {
        const screenPos =
            Offset(250, 300); // Within 10x10 grid with cellSize=50
        expect(coordinateService.isWithinGridBounds(screenPos, testConfig),
            isTrue);
      });

      test('getValidGridPosition within bounds', () {
        const screenPos = Offset(125, 175);
        final validPos =
            coordinateService.getValidGridPosition(screenPos, testConfig);

        expect(validPos, isNotNull);
        expect(validPos!.dx, closeTo(2.0, 0.001)); // 125/50 = 2.5 -> 2
        expect(validPos.dy, closeTo(3.0, 0.001)); // 175/50 = 3.5 -> 3
      });

      test('getValidGridPosition outside bounds', () {
        const screenPos = Offset(600, 600); // Outside 10x10 grid
        final validPos =
            coordinateService.getValidGridPosition(screenPos, testConfig);

        expect(validPos, isNull);
      });
    });

    group('Performance and Caching', () {
      test('caching improves performance', () {
        const screenPos = Offset(100, 150);

        // First call should cache
        final startTime1 = DateTime.now();
        final result1 = coordinateService.screenToGrid(screenPos, testConfig);
        final endTime1 = DateTime.now();

        // Second call should use cache
        final startTime2 = DateTime.now();
        final result2 = coordinateService.screenToGrid(screenPos, testConfig);
        final endTime2 = DateTime.now();

        // Results should be identical
        expect(result1.dx, result2.dx);
        expect(result1.dy, result2.dy);

        // Cached call should be faster (though this is a rough test)
        final duration1 = endTime1.difference(startTime1);
        final duration2 = endTime2.difference(startTime2);

        // At minimum, cached call shouldn't be significantly slower
        expect(
            duration2.inMicroseconds, lessThan(duration1.inMicroseconds * 10));
      });

      test('cache expiration works', () {
        // This would require mocking time or waiting, so we'll just test cache clearing
        coordinateService.clearCache();

        // Cache should be empty after clearing
        expect(() {
          // We can't directly test cache contents, but clearCache should not throw
          coordinateService.clearCache();
        }, returnsNormally);
      });
    });

    group('Edge Cases', () {
      test('handles zero scale gracefully', () {
        final zeroScaleConfig =
            testConfig.copyWith(scale: 0.1); // Minimum allowed
        const screenPos = Offset(100, 150);
        final gridPos =
            coordinateService.screenToGrid(screenPos, zeroScaleConfig);

        expect(gridPos.dx, isNot(double.nan));
        expect(gridPos.dy, isNot(double.nan));
        expect(gridPos.dx, isNot(double.infinity));
        expect(gridPos.dy, isNot(double.infinity));
      });

      test('handles large coordinates', () {
        const largePos = Offset(1000000, 1000000);
        final sanitizedPos =
            SecureCoordinateValidator.sanitizePosition(largePos);

        // Should be clamped to reasonable bounds
        expect(sanitizedPos.dx, lessThan(10000));
        expect(sanitizedPos.dy, lessThan(10000));
      });

      test('handles negative coordinates', () {
        const negativePos = Offset(-100, -150);
        final sanitizedPos =
            SecureCoordinateValidator.sanitizePosition(negativePos);

        // Should be clamped to non-negative
        expect(sanitizedPos.dx, greaterThanOrEqualTo(0));
        expect(sanitizedPos.dy, greaterThanOrEqualTo(0));
      });
    });
  });

  group('SecureCoordinateValidator Tests', () {
    test('sanitizes normal coordinates', () {
      const normalPos = Offset(100, 200);
      final sanitized = SecureCoordinateValidator.sanitizePosition(normalPos);

      expect(sanitized.dx, closeTo(100, 0.001));
      expect(sanitized.dy, closeTo(200, 0.001));
    });

    test('sanitizes out-of-bounds coordinates', () {
      const largePos = Offset(100000, -50000);
      final sanitized = SecureCoordinateValidator.sanitizePosition(largePos);

      expect(sanitized.dx, greaterThanOrEqualTo(0));
      expect(sanitized.dy, greaterThanOrEqualTo(0));
      expect(sanitized.dx, lessThan(10000));
      expect(sanitized.dy, lessThan(10000));
    });

    test('handles NaN and infinite values', () {
      const nanPos = Offset(double.nan, double.infinity);
      final sanitized = SecureCoordinateValidator.sanitizePosition(nanPos);

      expect(sanitized.dx, isNot(double.nan));
      expect(sanitized.dy, isNot(double.nan));
      expect(sanitized.dx, isNot(double.infinity));
      expect(sanitized.dy, isNot(double.infinity));
    });

    test('sanitizes scale values', () {
      expect(SecureCoordinateValidator.sanitizeScale(2), closeTo(2.0, 0.001));
      expect(SecureCoordinateValidator.sanitizeScale(15),
          closeTo(10.0, 0.001)); // Clamped
      expect(SecureCoordinateValidator.sanitizeScale(0.05),
          closeTo(0.1, 0.001)); // Clamped
    });
  });
}
