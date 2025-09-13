import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/bounds_manager.dart';

void main() {
  group('UnifiedBoundsManager Tests', () {
    late UnifiedBoundsManager boundsManager;

    setUp(() {
      boundsManager = UnifiedBoundsManager();
      // Reset to default configuration for each test
      boundsManager.updateConfiguration(const BoundsConfiguration());
    });

    tearDown(() {
      boundsManager.clearCache();
    });

    group('Configuration Tests', () {
      test('Default configuration should be warning strategy', () {
        final config = boundsManager.getConfiguration();
        expect(config.strategy, BoundsStrategy.warning);
        expect(config.levelBounds, const Size(8, 6));
        expect(config.visualBounds, const Size(20, 20));
      });

      test('Should update configuration correctly', () {
        final newConfig = BoundsConfiguration.tutorial();
        boundsManager.updateConfiguration(newConfig);

        final updatedConfig = boundsManager.getConfiguration();
        expect(updatedConfig.strategy, BoundsStrategy.strict);
        expect(updatedConfig.showBoundaryWarnings, true);
        expect(updatedConfig.boundaryColor, Colors.red);
      });

      test('Factory constructors should create correct configurations', () {
        // Tutorial config
        var config = BoundsConfiguration.tutorial();
        expect(config.strategy, BoundsStrategy.strict);
        expect(config.boundaryColor, Colors.red);

        // Beginner config
        config = BoundsConfiguration.beginner();
        expect(config.strategy, BoundsStrategy.warning);
        expect(config.boundaryColor, Colors.orange);

        // Advanced config
        config = BoundsConfiguration.advanced();
        expect(config.strategy, BoundsStrategy.flexible);
        expect(config.showBoundaryWarnings, false);
      });
    });

    group('Bounds Validation Tests', () {
      test('Should validate positions within level bounds', () {
        final result = boundsManager.validatePosition(3, 4);
        expect(result.isValid, true);
        expect(result.isWithinLevelBounds, true);
        expect(result.isWithinVisualBounds, true);
        expect(result.strategy, BoundsStrategy.warning);
      });

      test('Should validate positions outside level bounds but within visual bounds', () {
        final result = boundsManager.validatePosition(3, 12);
        expect(result.isValid, true); // Warning strategy allows this
        expect(result.isWithinLevelBounds, false);
        expect(result.isWithinVisualBounds, true);
      });

      test('Should reject positions outside visual bounds', () {
        final result = boundsManager.validatePosition(25, 25);
        expect(result.isValid, false);
        expect(result.isWithinLevelBounds, false);
        expect(result.isWithinVisualBounds, false);
        expect(result.errorMessage, contains('outside visual bounds'));
      });

      test('Should reject occupied positions', () {
        final occupiedPositions = {'3,4'};
        final result = boundsManager.validatePosition(3, 4, occupiedPositions: occupiedPositions);
        expect(result.isValid, false);
        expect(result.errorMessage, contains('already occupied'));
      });

      test('Strict strategy should reject positions outside level bounds', () {
        boundsManager.updateConfiguration(BoundsConfiguration.tutorial());
        final result = boundsManager.validatePosition(3, 12);
        expect(result.isValid, false);
        expect(result.errorMessage, contains('outside level bounds'));
      });

      test('Flexible strategy should allow all valid positions', () {
        boundsManager.updateConfiguration(BoundsConfiguration.advanced());
        final result = boundsManager.validatePosition(3, 12);
        expect(result.isValid, true);
        expect(result.isWithinLevelBounds, false);
        expect(result.isWithinVisualBounds, true);
      });
    });

    group('Caching Tests', () {
      test('Should cache validation results', () {
        // First call should cache
        final result1 = boundsManager.validatePosition(3, 4);
        expect(boundsManager.getCacheSize(), 1);

        // Second call should use cache
        final result2 = boundsManager.validatePosition(3, 4);
        expect(boundsManager.getCacheSize(), 1);
        expect(result1.isValid, result2.isValid);
      });

      test('Should clear cache when configuration changes', () {
        boundsManager.validatePosition(3, 4);
        expect(boundsManager.getCacheSize(), 1);

        boundsManager.updateConfiguration(BoundsConfiguration.tutorial());
        expect(boundsManager.getCacheSize(), 0);
      });

      test('Should disable caching when configured', () {
        final noCacheConfig = const BoundsConfiguration(enableCaching: false);
        boundsManager.updateConfiguration(noCacheConfig);

        boundsManager.validatePosition(3, 4);
        expect(boundsManager.getCacheSize(), 0);
      });
    });

    group('Bounds Calculation Tests', () {
      test('Should calculate level bounds rectangle correctly', () {
        const cellSize = 60.0;
        const panOffset = Offset(10, 20);

        final rect = boundsManager.getLevelBoundsRect(cellSize, panOffset);
        expect(rect.left, 10);
        expect(rect.top, 20);
        expect(rect.width, 8 * 60); // 8 columns * 60 cell size
        expect(rect.height, 6 * 60); // 6 rows * 60 cell size
      });

      test('Should calculate visual bounds rectangle correctly', () {
        const cellSize = 60.0;
        const panOffset = Offset(10, 20);

        final rect = boundsManager.getVisualBoundsRect(cellSize, panOffset);
        expect(rect.left, 10);
        expect(rect.top, 20);
        expect(rect.width, 20 * 60); // 20 columns * 60 cell size
        expect(rect.height, 20 * 60); // 20 rows * 60 cell size
      });

      test('Should convert grid to screen coordinates', () {
        const cellSize = 60.0;
        const panOffset = Offset(10, 20);

        final screenPos = boundsManager.gridToScreen(2, 3, cellSize, panOffset);
        expect(screenPos.dx, 10 + 3 * 60); // panOffset.x + col * cellSize
        expect(screenPos.dy, 20 + 2 * 60); // panOffset.y + row * cellSize
      });

      test('Should convert screen to grid coordinates', () {
        const cellSize = 60.0;
        const panOffset = Offset(10, 20);
        const screenPos = Offset(190, 140); // Should map to (2, 3)

        final gridPos = boundsManager.screenToGrid(screenPos, cellSize, panOffset);
        expect(gridPos?.row, 2);
        expect(gridPos?.col, 3);
      });

      test('Should return null for screen positions outside visual bounds', () {
        const cellSize = 60.0;
        const panOffset = Offset(0, 0);
        const screenPos = Offset(2000, 2000); // Way outside bounds

        final gridPos = boundsManager.screenToGrid(screenPos, cellSize, panOffset);
        expect(gridPos, null);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('Should handle negative coordinates', () {
        final result = boundsManager.validatePosition(-1, -1);
        expect(result.isValid, false);
        expect(result.isWithinLevelBounds, false);
        expect(result.isWithinVisualBounds, false);
      });

      test('Should handle zero coordinates', () {
        final result = boundsManager.validatePosition(0, 0);
        expect(result.isValid, true);
        expect(result.isWithinLevelBounds, true);
        expect(result.isWithinVisualBounds, true);
      });

      test('Should handle maximum valid coordinates', () {
        final result = boundsManager.validatePosition(5, 7); // 6x8 level bounds max
        expect(result.isValid, true);
        expect(result.isWithinLevelBounds, true);
        expect(result.isWithinVisualBounds, true);
      });

      test('Should handle extended bounds when configured', () {
        final config = const BoundsConfiguration(
          extendedBounds: Size(15, 12),
        );
        boundsManager.updateConfiguration(config);

        final result = boundsManager.validatePosition(8, 10);
        expect(result.isWithinExtendedBounds, true);
      });
    });

    group('Performance Tests', () {
      test('Should handle multiple validation calls efficiently', () {
        final stopwatch = Stopwatch()..start();

        // Perform many validation calls
        for (int row = 0; row < 20; row++) {
          for (int col = 0; col < 20; col++) {
            boundsManager.validatePosition(row, col);
          }
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
      });

      test('Cache should improve performance on repeated calls', () {
        final positions = <List<int>>[];
        for (int i = 0; i < 100; i++) {
          positions.add([i % 20, i % 20]); // Repeat positions
        }

        final stopwatch = Stopwatch()..start();

        for (final pos in positions) {
          boundsManager.validatePosition(pos[0], pos[1]);
        }

        stopwatch.stop();
        final withCache = stopwatch.elapsedMilliseconds;

        // Clear cache and test again
        boundsManager.clearCache();
        stopwatch.reset();

        stopwatch.start();
        for (final pos in positions) {
          boundsManager.validatePosition(pos[0], pos[1]);
        }
        stopwatch.stop();
        final withoutCache = stopwatch.elapsedMilliseconds;

        // With cache should be faster (though this is a rough test)
        expect(withCache, lessThanOrEqualTo(withoutCache));
      });
    });
  });

  group('BoundsConfiguration Tests', () {
    test('Should create valid configurations', () {
      const config = BoundsConfiguration();
      expect(config.strategy, BoundsStrategy.warning);
      expect(config.levelBounds, const Size(8, 6));
      expect(config.visualBounds, const Size(20, 20));
      expect(config.enableCaching, true);
    });

    test('CopyWith should create modified configurations', () {
      const original = BoundsConfiguration();
      final modified = original.copyWith(
        strategy: BoundsStrategy.strict,
        boundaryColor: Colors.blue,
      );

      expect(modified.strategy, BoundsStrategy.strict);
      expect(modified.boundaryColor, Colors.blue);
      expect(modified.levelBounds, original.levelBounds); // Unchanged
    });
  });

  group('GridPosition Tests', () {
    test('Should create valid grid positions', () {
      const pos = GridPosition(row: 3, col: 4);
      expect(pos.row, 3);
      expect(pos.col, 4);
    });

    test('Should implement equality correctly', () {
      const pos1 = GridPosition(row: 3, col: 4);
      const pos2 = GridPosition(row: 3, col: 4);
      const pos3 = GridPosition(row: 4, col: 3);

      expect(pos1, equals(pos2));
      expect(pos1, isNot(equals(pos3)));
    });

    test('Should implement hashCode correctly', () {
      const pos1 = GridPosition(row: 3, col: 4);
      const pos2 = GridPosition(row: 3, col: 4);

      expect(pos1.hashCode, equals(pos2.hashCode));
    });
  });

  group('Integration Tests', () {
    test('Complete workflow should work end-to-end', () {
      final boundsManager = UnifiedBoundsManager();

      // Configure for tutorial mode
      boundsManager.updateConfiguration(BoundsConfiguration.tutorial());

      // Test position validation
      final result = boundsManager.validatePosition(2, 3);
      expect(result.isValid, true);

      // Test bounds calculation
      const cellSize = 60.0;
      const panOffset = Offset(0, 0);
      final levelRect = boundsManager.getLevelBoundsRect(cellSize, panOffset);
      expect(levelRect.width, 8 * 60);
      expect(levelRect.height, 6 * 60);

      // Test coordinate conversion
      final screenPos = boundsManager.gridToScreen(2, 3, cellSize, panOffset);
      expect(screenPos.dx, 3 * 60);
      expect(screenPos.dy, 2 * 60);

      final gridPos = boundsManager.screenToGrid(screenPos, cellSize, panOffset);
      expect(gridPos?.row, 2);
      expect(gridPos?.col, 3);
    });

    test('Configuration changes should affect validation', () {
      final boundsManager = UnifiedBoundsManager();

      // Start with default warning strategy
      boundsManager.updateConfiguration(const BoundsConfiguration(strategy: BoundsStrategy.warning));
      final result1 = boundsManager.validatePosition(3, 12);
      expect(result1.isValid, true); // Should allow in warning mode
      expect(result1.strategy, BoundsStrategy.warning);

      // Switch to strict strategy
      boundsManager.updateConfiguration(BoundsConfiguration.tutorial());
      final result2 = boundsManager.validatePosition(3, 12);
      expect(result2.isValid, false); // Should reject in strict mode
      expect(result2.strategy, BoundsStrategy.strict);
    });
  });
}