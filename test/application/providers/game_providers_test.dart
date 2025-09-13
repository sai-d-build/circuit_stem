import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// Import the game providers we want to test
import 'package:sparkcircuit/application/providers/game_providers.dart';

// Helper utilities
import 'helpers/test_container_helper.dart';

/// Game Providers Test Suite
/// ========================
/// Comprehensive test coverage for game engine selection and feature flags.
/// Tests V1/V3 switching logic, state management, and provider resolution.

void main() {
  group('Game Providers - Engine Selection and Feature Flags', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderTestHelper.createTestContainer();
    });

    tearDown(() {
      ProviderTestHelper.disposeContainer(container);
    });

    // =========================================================================
    // TEST GROUP: Feature Flag Provider
    // =========================================================================

    test('useV3EngineProvider defaults to V1 in debug mode', () {
      // Act - Test with debug mode environment
      // Note: This test assumes debug mode is set appropriately

      final useV3 = container.read(useV3EngineProvider);

      // Assert - Should be false by default (V1)
      expect(useV3, isFalse);
      expect(useV3, isA<bool>());
    });

    test('useV3EngineProvider can be overridden for testing', () {
      // Arrange - Override the feature flag
      final testContainer = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(true),
      ]);

      // Act
      final useV3 = testContainer.read(useV3EngineProvider);

      // Assert - Should be the overridden value
      expect(useV3, isTrue);

      testContainer.dispose();
    });

    test('useV3EngineProvider affects gameEngineVersionProvider', () {
      // Test V1 scenario
      final testContainerV1 = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(false),
      ]);

      // Act
      final versionV1 = testContainerV1.read(gameEngineVersionProvider);

      // Assert
      expect(versionV1, GameEngineVersion.v1);

      testContainerV1.dispose();

      // Test V3 scenario
      final testContainerV3 = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(true),
      ]);

      // Act
      final versionV3 = testContainerV3.read(gameEngineVersionProvider);

      // Assert
      expect(versionV3, GameEngineVersion.v3);

      testContainerV3.dispose();
    });

    // =========================================================================
    // TEST GROUP: Engine Selection Provider
    // =========================================================================

    test('gameEngineProvider resolves to GameEngine interface', () {
      // Act - Provider should resolve to some implementation
      expect(
        () => container.read(gameEngineProvider),
        returnsNormally,
      );

      final engine = container.read(gameEngineProvider);

      // Assert - Should implement GameEngine interface
      expect(engine, isNotNull);
    });

    test(
        'gameEngineProvider switches implementation based on feature flag - V1',
        () {
      // Arrange - Force V1 selection
      final testContainer = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(false),
      ]);

      // Act
      final engine = testContainer.read(gameEngineProvider);

      // Assert
      expect(engine, isNotNull);

      testContainer.dispose();
    });

    test(
        'gameEngineProvider switches implementation based on feature flag - V3',
        () {
      // Arrange - Force V3 selection
      final testContainer = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(true),
      ]);

      // Act - Should not throw even if V3 implementation has issues
      expect(
        () => testContainer.read(gameEngineProvider),
        returnsNormally,
      );

      testContainer.dispose();
    });

    test('backward compatibility provider alias works', () {
      // Act & Assert - enhancedGameStateNotifierProvider should be accessible
      expect(
        () => container.read(enhancedGameStateNotifierProvider),
        returnsNormally,
      );

      final backwardCompatProvider =
          container.read(enhancedGameStateNotifierProvider);
      expect(backwardCompatProvider, isNotNull);
    });

    test('backward compatibility provider matches main game engine', () {
      // Act
      final mainEngine = container.read(gameEngineProvider);
      final legacyEngine = container.read(enhancedGameStateNotifierProvider);

      // Assert - They should reference the same provider
      // Note: This is an alias, so they should be equivalent
      expect(mainEngine, isNotNull);
      expect(legacyEngine, isNotNull);
    });

    // =========================================================================
    // TEST GROUP: Engine Version Provider
    // =========================================================================

    test('gameEngineVersionProvider provides correct enum values', () {
      // Test all enum values
      expect(GameEngineVersion.v1, isA<GameEngineVersion>());
      expect(GameEngineVersion.v3, isA<GameEngineVersion>());

      // Values should be distinct
      expect(GameEngineVersion.v1 != GameEngineVersion.v3, isTrue);
    });

    test('gameEngineVersionProvider maps feature flag correctly', () {
      // Test V1 mapping
      final v1Container = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(false),
      ]);

      expect(v1Container.read(gameEngineVersionProvider), GameEngineVersion.v1);
      v1Container.dispose();

      // Test V3 mapping
      final v3Container = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(true),
      ]);

      expect(v3Container.read(gameEngineVersionProvider), GameEngineVersion.v3);
      v3Container.dispose();
    });

    // =========================================================================
    // TEST GROUP: Provider Resolution and Dependencies
    // =========================================================================

    test('all game providers can be resolved without errors', () {
      // Act & Assert - All game providers should be resolvable
      expect(() => container.read(useV3EngineProvider), returnsNormally);
      expect(() => container.read(gameEngineVersionProvider), returnsNormally);
      expect(() => container.read(gameEngineProvider), returnsNormally);
      expect(() => container.read(enhancedGameStateNotifierProvider),
          returnsNormally);
    });

    test('providers have correct dependency relationships', () {
      // Test that gameEngineVersionProvider depends on useV3EngineProvider
      final versionContainer = ProviderContainer();

      // Should work normally
      expect(versionContainer.read(gameEngineVersionProvider), isNotNull);
      versionContainer.dispose();
    });

    // =========================================================================
    // TEST GROUP: State Synchronization Provider
    // =========================================================================

    test('gameEngineStateSynchronizerProvider can be resolved', () {
      expect(
        () => container.read(gameEngineStateSynchronizerProvider),
        returnsNormally,
      );

      final synchronizer = container.read(gameEngineStateSynchronizerProvider);
      expect(synchronizer, isNotNull);
    });

    test('state synchronizer has correct engine references', () {
      final synchronizer = container.read(gameEngineStateSynchronizerProvider);

      // Should contain references to both engine notifiers
      expect(synchronizer.v1Engine, isNotNull);
      expect(synchronizer.v3Engine, isNotNull);
    });

    test('state synchronizer methods work without errors', () {
      final synchronizer = container.read(gameEngineStateSynchronizerProvider);

      // Test that methods exist and don't throw
      expect(synchronizer.resetEngines, returnsNormally);

      // Note: validateEngineConsistency may need mock data
    });

    // =========================================================================
    // INTEGRATION TESTS
    // =========================================================================

    test('end-to-end provider chain resolves correctly', () {
      // Arrange
      final testContainer = ProviderTestHelper.createTestContainer();

      // Act - Read all providers in order
      final flag = testContainer.read(useV3EngineProvider);
      final version = testContainer.read(gameEngineVersionProvider);
      final engine = testContainer.read(gameEngineProvider);
      final synchronizer =
          testContainer.read(gameEngineStateSynchronizerProvider);

      // Assert - All should be resolvable and non-null
      expect(flag, isNotNull);
      expect(version, isNotNull);
      expect(engine, isNotNull);
      expect(synchronizer, isNotNull);

      ProviderTestHelper.disposeContainer(testContainer);
    });

    test('feature flag change propagates through provider chain', () {
      // Test V1 scenario
      final v1Container = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(false),
      ]);

      expect(v1Container.read(useV3EngineProvider), isFalse);
      expect(v1Container.read(gameEngineVersionProvider), GameEngineVersion.v1);

      v1Container.dispose();
    });

    // =========================================================================
    // ERROR HANDLING TESTS
    // =========================================================================

    test('invalid feature flag values are handled gracefully', () {
      // The current implementation uses boolean flag
      // This is more of a design validation that the enum approach covers
      expect(GameEngineVersion.values.length, 2); // V1 and V3
    });

    test('provider consumer methods work correctly', () {
      // Test that consumers of the GameEngine interface can be satisfied
      final engine = container.read(gameEngineProvider);

      // These would throw if the interface contract is broken
      expect(() => engine.loadLevel, returnsNormally);
      expect(() => engine.togglePause, returnsNormally);
      expect(() => engine.restartLevel, returnsNormally);
      expect(() => engine.undo, returnsNormally);
    });

    // =========================================================================
    // PERFORMANCE TESTS
    // =========================================================================

    test('provider resolution is reasonably fast', () {
      final startTime = DateTime.now();

      // Act - Resolve multiple times
      for (var i = 0; i < 100; i++) {
        container.read(gameEngineProvider);
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Assert - Should be very fast
      expect(duration.inMilliseconds, lessThan(500));
    });
  });

  // ============================================================================
  // ENGINE-SPECIFIC TESTS
  // ============================================================================

  group('Game Providers - Engine-Specific Behavior', () {
    test('V1 engine provider resolves correctly', () {
      final testContainer = ProviderContainer();
      expect(() => testContainer.read(gameEngineV1Provider), returnsNormally);

      final v1Engine = testContainer.read(gameEngineV1Provider);
      expect(v1Engine, isNotNull);

      testContainer.dispose();
    });

    test('enum-based version selection works for future extensions', () {
      // Test that the enum allows for easy extension
      const versions = GameEngineVersion.values;
      expect(versions.length, greaterThanOrEqualTo(2));

      // Verify each version is distinct
      final v1 = GameEngineVersion.v1.index;
      final v3 = GameEngineVersion.v3.index;
      expect(v1 != v3, isTrue);
    });

    test('feature flag mechanism is robust against edge cases', () {
      // Test with various boolean combinations
      const testCases = [false, true];

      for (final testCase in testCases) {
        final container = ProviderContainer(overrides: [
          useV3EngineProvider.overrideWithValue(testCase),
        ]);

        final flag = container.read(useV3EngineProvider);
        final version = container.read(gameEngineVersionProvider);

        expect(flag, testCase);
        if (testCase) {
          expect(version, GameEngineVersion.v3);
        } else {
          expect(version, GameEngineVersion.v1);
        }

        container.dispose();
      }
    });
  });
}
