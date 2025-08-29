import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/providers.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/game_engine_orchestrator.dart';
import 'package:circuit_stem/application/grid_notifier.dart';
import 'package:circuit_stem/application/history_notifier.dart';
import 'package:circuit_stem/application/game_progress_notifier.dart';
import 'package:circuit_stem/application/component_selection_notifier.dart';
import 'package:circuit_stem/application/interaction_state_notifier.dart';
import 'package:circuit_stem/common/feature_flags.dart';
import 'package:circuit_stem/application/feature_flag_service.dart';
import 'package:circuit_stem/presentation/core/ui_migration_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';

/// Test infrastructure for hybrid vs original game engine testing.
///
/// Utilities:
/// - create test ProviderContainer instances with correct overrides
/// - switch feature flags for hybrid/original systems
/// - lightweight mocks and helpers suitable for unit tests
class HybridTestSetup {
  /// Create a test container with hybrid engine enabled.
  /// Returns a Future because SharedPreferences mock initialization is async.
  static Future<ProviderContainer> createHybridTestContainer({
    Map<Override, Override> additionalOverrides = const {},
    String? userId,
  }) async {
    // Initialize feature flag service for testing
    FeatureFlagService.initialize(userId: userId ?? 'test_user');
    FeatureFlagService.setFlag('hybrid_engine', true);
    FeatureFlagService.setFlag('granular_providers', true);

    // Prepare SharedPreferences synchronously for tests
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final overrides = <Override>[
      // Foundation service overrides
      sharedPreferencesProvider.overrideWithValue(prefs),

      // Hybrid-specific overrides
      gridNotifierProvider.overrideWith((ref) => MockGridNotifier()),
      historyNotifierProvider.overrideWith((ref) => MockHistoryNotifier()),
      gameProgressNotifierProvider.overrideWith((ref) => MockGameProgressNotifier()),
      componentSelectionNotifierProvider.overrideWith((ref) => MockComponentSelectionNotifier()),
      interactionStateNotifierProvider.overrideWith((ref) => MockInteractionStateNotifier()),

      ...additionalOverrides.values,
    ];

    return ProviderContainer(overrides: overrides);
  }

  /// Create a test container with original engine enabled.
  static Future<ProviderContainer> createOriginalTestContainer({
    Map<Override, Override> additionalOverrides = const {},
    String? userId,
  }) async {
    FeatureFlagService.initialize(userId: userId ?? 'test_user');
    FeatureFlagService.setFlag('hybrid_engine', false);
    FeatureFlagService.setFlag('granular_providers', false);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final overrides = <Override>[
      // Foundation service overrides
      sharedPreferencesProvider.overrideWithValue(prefs),

      // Original system override - use a lightweight dummy notifier for tests
      gameEngineNotifierProvider.overrideWith((ref) => _DummyGameEngineNotifier()),

      ...additionalOverrides.values,
    ];

    return ProviderContainer(overrides: overrides);
  }

  /// Create a test container that can switch between systems dynamically.
  static Future<ProviderContainer> createSwitchableTestContainer({
    bool startWithHybrid = false,
    Map<Override, Override> additionalOverrides = const {},
    String? userId,
  }) async {
    FeatureFlagService.initialize(userId: userId ?? 'test_user');
    FeatureFlagService.setFlag('hybrid_engine', startWithHybrid);
    FeatureFlagService.setFlag('granular_providers', startWithHybrid);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final overrides = <Override>[
      // Foundation service overrides
      sharedPreferencesProvider.overrideWithValue(prefs),

      // Both systems available
      gridNotifierProvider.overrideWith((ref) => MockGridNotifier()),
      historyNotifierProvider.overrideWith((ref) => MockHistoryNotifier()),
      gameProgressNotifierProvider.overrideWith((ref) => MockGameProgressNotifier()),
      componentSelectionNotifierProvider.overrideWith((ref) => MockComponentSelectionNotifier()),
      interactionStateNotifierProvider.overrideWith((ref) => MockInteractionStateNotifier()),
      gameEngineNotifierProvider.overrideWith((ref) => _DummyGameEngineNotifier()),

      ...additionalOverrides.values,
    ];

    return ProviderContainer(overrides: overrides);
  }

  /// Switch a test container between hybrid and original systems.
  static void switchToHybrid(ProviderContainer container, {bool enableGranular = true}) {
    FeatureFlagService.setFlag('hybrid_engine', true);
    FeatureFlagService.setFlag('granular_providers', enableGranular);
    container.invalidate(gameEngineProvider);
  }

  /// Switch a test container to original system.
  static void switchToOriginal(ProviderContainer container) {
    FeatureFlagService.setFlag('hybrid_engine', false);
    FeatureFlagService.setFlag('granular_providers', false);
    container.invalidate(gameEngineProvider);
  }

  /// Run a test with both hybrid and original systems to ensure compatibility.
  static Future<void> runCompatibilityTest(
    String description,
    Future<void> Function(ProviderContainer container, bool isHybrid) testFunction,
  ) async {
    group('$description (compatibility)', () {
      testWidgets('with original system', (tester) async {
        final container = await createOriginalTestContainer();
        addTearDown(() => container.dispose());

        await testFunction(container, false);
      });

      testWidgets('with hybrid system', (tester) async {
        final container = await createHybridTestContainer();
        addTearDown(() => container.dispose());

        await testFunction(container, true);
      });
    });
  }

  /// Create performance comparison test between systems.
  static Future<void> runPerformanceComparison(
    String description,
    Future<Map<String, dynamic>> Function(ProviderContainer container) performanceTest,
  ) async {
    group('$description (performance)', () {
      test('original system baseline', () async {
        final container = await createOriginalTestContainer();

        final metrics = await performanceTest(container);

        expect(metrics, isA<Map<String, dynamic>>());
        // Store baseline metrics for comparison

        container.dispose();
      });

      test('hybrid system performance', () async {
        final container = await createHybridTestContainer();

        final metrics = await performanceTest(container);

        expect(metrics, isA<Map<String, dynamic>>());
        // Compare with baseline metrics

        container.dispose();
      });
    });
  }
}

// =============================================================================
// MOCK IMPLEMENTATIONS FOR TESTING (lightweight, non-invasive)
// =============================================================================

class MockGridNotifier extends GridNotifier {
  @override
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    // Mock implementation
    transaction.onCommit(() async {
      // Simulate grid update
    });

    transaction.onRollback(() {
      // Simulate rollback
    });
  }
}

class MockHistoryNotifier extends HistoryNotifier {
  @override
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    transaction.onCommit(() async {
      // Simulate history update
    });

    transaction.onRollback(() {
      // Simulate rollback
    });
  }
}

class MockGameProgressNotifier extends GameProgressNotifier {
  @override
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    transaction.onCommit(() async {
      // Simulate progress update
    });

    transaction.onRollback(() {
      // Simulate rollback
    });
  }
}

class MockComponentSelectionNotifier extends ComponentSelectionNotifier {
  @override
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    transaction.onCommit(() async {
      // Simulate selection update
    });

    transaction.onRollback(() {
      // Simulate rollback
    });
  }
}

class MockInteractionStateNotifier extends InteractionStateNotifier {
  @override
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    transaction.onCommit(() async {
      // Simulate interaction update
    });

    transaction.onRollback(() {
      // Simulate rollback
    });
  }
}

/// Lightweight stand-in for original GameEngineNotifier used in tests.
/// Keep it minimal to avoid complex inheritance/async initialization.
class _DummyGameEngineNotifier {
  // Add minimal helpers if tests require invocation; otherwise acts as placeholder.
}

/// Simple mock audio service used by some test setups.
class MockAudioService implements AudioService {
  @override
  Future<void> playSound(String soundPath) async {
    // No-op for tests
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// =============================================================================
// TEST UTILITIES
// =============================================================================

/// Extension on ProviderContainer for easier testing.
extension TestContainerExtension on ProviderContainer {
  /// Get the game engine notifier for the current system.
  dynamic get gameEngineNotifier => read(gameEngineNotifierProvider);

  /// Get the game engine state for the current system.
  GameEngineState get gameEngineState => read(gameEngineProvider);

  /// Check if hybrid system is active.
  bool get isHybridActive => UIMigrationWrapper.isHybridEnabled;

  /// Get performance metrics for the current system.
  Map<String, dynamic> get performanceMetrics {
    return {
      'hybrid_active': isHybridActive,
      'granular_providers': UIMigrationWrapper.useGranularProviders,
      'provider_count': isHybridActive ? 6 : 1,
    };
  }
}

/// Test helper for measuring provider rebuild frequency.
class RebuildCounter {
  int _count = 0;

  int get count => _count;

  void increment() => _count++;

  void reset() => _count = 0;
}

/// Test helper for simulating user actions.
class ActionSimulator {
  final ProviderContainer container;

  ActionSimulator(this.container);

  Future<void> simulateComponentMove(String componentId, int newRow, int newCol) async {
    final notifier = container.gameEngineNotifier;
    // Simulate move action based on system type
    if (container.isHybridActive) {
      // Use hybrid system
      // await notifier.executeAction(MoveComponentAction(...));
    } else {
      // Use original system
      // await notifier.moveComponent(componentId, newRow, newCol);
    }
  }

  Future<void> simulateWinCondition() async {
    final notifier = container.gameEngineNotifier;
    // Simulate win condition trigger
  }
}