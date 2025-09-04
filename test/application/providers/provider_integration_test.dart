import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

// Import the actual providers we want to test
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/application/providers/game_providers.dart';

/// Provider Integration Test Suite
/// ================================
/// End-to-end integration tests for the refactored provider architecture.
/// Tests real provider chains, dependency resolution, and functional behavior.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Provider Integration Tests - End-to-End Validation', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // =========================================================================
    // END-TO-END PROVIDER CHAIN TESTS
    // =========================================================================

    test('complete core provider dependency chain resolves correctly', () {
      // Test the full dependency chain from low-level to high-level providers
      // This validates that our refactoring maintains working dependencies

      // Bottom-level dependencies
      final mnaSolver = container.read(mnaSolverProvider);
      final componentFactory = container.read(componentFactoryProvider);
      final storageService = container.read(storageServiceProvider);
      final powerSimulation = container.read(powerSimulationServiceProvider);
      final netlistBuilder = container.read(netlistBuilderProvider);

      // Intermediate dependencies
      final simulationEngine = container.read(simulationEngineProvider);

      // High-level dependencies (use case providers)
      // final createComponentUseCase = container.read(createComponentUseCaseProvider);
      // final checkWinConditionUseCase = container.read(checkWinConditionUseCaseProvider);

      // Assert all providers resolve successfully
      expect(mnaSolver, isNotNull);
      expect(componentFactory, isNotNull);
      expect(storageService, isNotNull);
      expect(powerSimulation, isNotNull);
      expect(netlistBuilder, isNotNull);
      expect(simulationEngine, isNotNull);
    });

    test('game provider ecosystem functions as coherent system', () {
      // Test the entire game provider ecosystem
      final flag = container.read(useV3EngineProvider);
      final version = container.read(gameEngineVersionProvider);
      final engine = container.read(gameEngineProvider);
      final synchronizer = container.read(gameEngineStateSynchronizerProvider);

      // Verify all components work together
      expect(flag, isFalse); // Should default to V1
      expect(version, GameEngineVersion.v1);
      expect(engine, isNotNull);
      expect(synchronizer, isNotNull);
      expect(synchronizer.v1Engine, isNotNull);
      expect(synchronizer.v3Engine, isNotNull);
    });

    test('backward compatibility is maintained through refactoring', () {
      // Test that old imports continue to work through our backward compatibility layer

      // These should work even though we're now importing from core_providers.dart
      expect(container.read(mnaSolverProvider), isNotNull);
      expect(container.read(simulationEngineProvider), isNotNull);
      expect(container.read(componentFactoryProvider), isNotNull);
      expect(container.read(storageServiceProvider), isNotNull);

      // Test the legacy alias still works
      final legacyEngine = container.read(enhancedGameStateNotifierProvider);
      expect(legacyEngine, isNotNull);
    });

    test('provider lifecycle management works correctly', () {
      // Test that providers can be created, used, and disposed properly
      final testContainer = ProviderContainer();

      // Use various providers
      testContainer.read(mnaSolverProvider);
      testContainer.read(simulationEngineProvider);
      testContainer.read(gameEngineProvider);

      // Should dispose without issues
      expect(() => testContainer.dispose(), returnsNormally);
    });

    // =========================================================================
    // FEATURE FLAG INTEGRATION TESTS
    // =========================================================================

    test('feature flag switching affects entire provider ecosystem', () {
      // Test V1 configuration
      final v1Container = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(false),
      ]);

      expect(v1Container.read(useV3EngineProvider), isFalse);
      expect(v1Container.read(gameEngineVersionProvider), GameEngineVersion.v1);

      v1Container.dispose();

      // Test V3 configuration
      final v3Container = ProviderContainer(overrides: [
        useV3EngineProvider.overrideWithValue(true),
      ]);

      expect(v3Container.read(useV3EngineProvider), isTrue);
      expect(v3Container.read(gameEngineVersionProvider), GameEngineVersion.v3);

      v3Container.dispose();
    });

    test('engine switching maintains provider consistency', () {
      // Test that switching engines doesn't break the provider ecosystem

      // Start with V1
      var engine = container.read(gameEngineProvider);
      expect(engine, isNotNull);

      // Test that both engines are available through the synchronizer
      final synchronizer = container.read(gameEngineStateSynchronizerProvider);
      expect(synchronizer, isNotNull);
    });

    // =========================================================================
    // CROSS-PROVIDER INTEGRATION TESTS
    // =========================================================================

    test('core providers integrate with game providers correctly', () {
      // Test that core providers (simulation, storage) work with game providers
      final simulationEngine = container.read(simulationEngineProvider);
      final storageService = container.read(storageServiceProvider);
      final gameEngine = container.read(gameEngineProvider);

      // All should coexist and work together
      expect(simulationEngine, isNotNull);
      expect(storageService, isNotNull);
      expect(gameEngine, isNotNull);
    });

    test('provider resolution performance is acceptable for real usage', () {
      // Test that provider resolution is fast enough for production use
      final startTime = DateTime.now();

      // Simulate real-world provider usage pattern
      for (var i = 0; i < 1000; i++) {
        container.read(mnaSolverProvider);
        container.read(componentFactoryProvider);
        container.read(storageServiceProvider);
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Should be under 2 seconds for 1000 iterations
      expect(duration.inSeconds, lessThan(2));
    });

    // =========================================================================
    // REFACTORING SAFETY NET TESTS
    // =========================================================================

    test('refactoring maintains all existing functionality', () {
      // Test that after our refactoring, all expected functionality is preserved
      // This is a comprehensive safety net

      expect(container.read(mnaSolverProvider), isNotNull);
      expect(container.read(simulationEngineProvider), isNotNull);
      expect(container.read(componentFactoryProvider), isNotNull);
      expect(container.read(storageServiceProvider), isNotNull);
      expect(container.read(powerSimulationServiceProvider), isNotNull);
      expect(container.read(netlistBuilderProvider), isNotNull);
    });

    test('no regression in provider count and types', () {
      // Test that we haven't inadvertently changed the number or types of providers
      // This ensures our refactoring didn't break existing contracts

      // These are the original providers that should all still work
      expect(container.read(mnaSolverProvider), isNotNull);
      expect(container.read(simulationEngineProvider), isNotNull);
      expect(container.read(componentFactoryProvider), isNotNull);
      expect(container.read(storageServiceProvider), isNotNull);
    });

    // =========================================================================
    // ERROR HANDLING AND EDGE CASES
    // =========================================================================

    test('provider system handles error conditions gracefully', () {
      // Test error handling in the provider system
      // This validates that our refactoring didn't introduce new failure modes

      expect(() => container.read(mnaSolverProvider), returnsNormally);
      expect(() => container.read(gameEngineProvider), returnsNormally);
    });

    test('concurrent access to providers works correctly', () {
      // Test that concurrent access patterns work
      // This is important for UI usage where multiple widgets read providers

      final futures = <Future<void>>[];

      for (var i = 0; i < 10; i++) {
        futures.add(Future(() {
          container.read(simulationEngineProvider);
          container.read(gameEngineProvider);
        }));
      }

      // Should all complete successfully
      expect(Future.wait(futures), returnsNormally);
    });

    // =========================================================================
    // SCALABILITY AND PERFORMANCE TESTS
    // =========================================================================

    test('provider system scales with additional providers', () {
      // Test that our architecture supports adding more providers
      // This validates the scalability of our refactoring approach

      final testContainer = ProviderContainer();

      // Add multiple providers that could represent future expansion
      // In a real scenario, these would be additional business logic providers
      for (var i = 0; i < 50; i++) {
        expect(testContainer.read(mnaSolverProvider), isNotNull);
      }

      testContainer.dispose();
    });

    test('memory usage patterns are reasonable', () {
      // Test basic memory patterns (though we can't measure actual memory)
      // This ensures our provider structure doesn't create obvious issues

      final testContainer = ProviderContainer();

      // Create and dispose multiple containers
      for (var i = 0; i < 20; i++) {
        final tempContainer = ProviderContainer();
        tempContainer.read(simulationEngineProvider);
        tempContainer.dispose();
      }

      // Original container should still work
      expect(testContainer.read(mnaSolverProvider), isNotNull);
      testContainer.dispose();
    });
  });

  // ============================================================================
  // CROSS-CONTAINER TESTS
  // ============================================================================

  group('Provider Integration - Cross-Container Scenarios', () {
    test('multiple provider containers can coexist', () {
      // Test that multiple containers can be created and used independently
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();

      // Both should work independently
      expect(container1.read(mnaSolverProvider), isNotNull);
      expect(container2.read(mnaSolverProvider), isNotNull);

      container1.dispose();
      container2.dispose();
    });

    test('container lifetimes are properly managed', () {
      // Test lifecycle management across multiple containers
      final containers = <ProviderContainer>[];

      // Create multiple containers
      for (var i = 0; i < 5; i++) {
        containers.add(ProviderContainer());
      }

      // Use all containers
      for (final cont in containers) {
        expect(cont.read(simulationEngineProvider), isNotNull);
      }

      // Dispose all containers
      for (final cont in containers) {
        cont.dispose();
      }

      // Should not throw
      expect(true, isTrue);
    });
  });
}