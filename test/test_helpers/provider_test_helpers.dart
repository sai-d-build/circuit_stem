import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart'
    as providers_v3;
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/application/providers/scoped_providers.dart';
import 'package:sparkcircuit/core/services/game_state_reader.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/canvas_interaction_controller.dart';
import 'package:sparkcircuit/presentation/features/game/services/viewport_service.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

/// Mock classes for testing
class MockStorageService {
  dynamic readData(String key) => null;
  Future<bool> saveData(String key, dynamic value) async => true;
}

class MockLevelService {
  Future<dynamic> loadLevel(String levelId) async => null;
}

class MockGameEngineNotifierV3 {}

/// Test Provider Factory - Creates properly configured test containers
class TestProviderFactory {
  static ProviderContainer createGameCanvasContainer({
    String levelId = 'test_level',
    bool useRealStorage = false,
    bool useRealGameEngine = false,
    GameStateReader? customGameStateReader,
  }) {
    return ProviderContainer(overrides: [
      // Core service mocks - using proper override methods
      if (!useRealStorage)
        providers_v3.storageServiceProvider.overrideWith(
          (ref) => MockStorageService() as dynamic,
        ),
      if (!useRealGameEngine)
        providers_v3.enhancedGameStateNotifierProvider.overrideWith(
          (ref) => MockGameEngineNotifierV3() as dynamic,
        ),

      // Scoped providers to break circular dependencies
      ...TestScopedProviders.getOverrides(
        gameStateReader: customGameStateReader ?? TestGameStateReader(),
        storageService: useRealStorage ? null : MockStorageService(),
        levelService: MockLevelService(),
        uiStateManager: UIStateManager(),
      ),

      // Viewport service
      viewportServiceProvider.overrideWith(
        (ref, levelId) => ViewportService(
          initialState: const ViewportState(),
        ),
      ),

      // Interaction state
      interactionStateProvider.overrideWith(
        (ref, levelId) => InteractionStateNotifier(
          ref: ref as dynamic,
          levelId: levelId,
        ),
      ),

      // Palette state - simplified for testing
      paletteStateProvider.overrideWith(
        (ref, levelId) => MockGameEngineNotifierV3() as dynamic,
      ),
    ]);
  }

  static Widget wrapWithTestProviders({
    required Widget child,
    required ProviderContainer container,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }
}

/// Test-specific overrides for different scenarios
class GameCanvasTestOverrides {
  static List<Override> basicOverrides() => [
        providers_v3.storageServiceProvider
            .overrideWith((ref) => MockStorageService() as dynamic),
        providers_v3.levelServiceProvider
            .overrideWith((ref) => MockLevelService() as dynamic),
        ...TestScopedProviders.getOverrides(
          gameStateReader: TestGameStateReader(),
          storageService: MockStorageService(),
          levelService: MockLevelService(),
        ),
      ];

  static List<Override> fullGameCanvasOverrides() => [
        ...basicOverrides(),
        viewportServiceProvider.overrideWith(
          (ref, levelId) =>
              ViewportService(initialState: const ViewportState()),
        ),
        interactionStateProvider.overrideWith(
          (ref, levelId) => InteractionStateNotifier(
            ref: ref as dynamic,
            levelId: levelId,
          ),
        ),
        paletteStateProvider.overrideWith(
          (ref, levelId) => MockGameEngineNotifierV3() as dynamic,
        ),
      ];

  static List<Override> integrationTestOverrides() => [
        // Use more realistic mocks for integration tests
        providers_v3.storageServiceProvider
            .overrideWith((ref) => MockStorageService() as dynamic),
        providers_v3.enhancedGameStateNotifierProvider.overrideWith(
          (ref) => MockGameEngineNotifierV3() as dynamic,
        ),
        ...TestScopedProviders.getOverrides(
          gameStateReader: TestGameStateReader(),
          storageService: MockStorageService(),
          levelService: MockLevelService(),
        ),
      ];
}

/// Helper class for creating test scenarios
class TestScenarioBuilder {
  final List<Override> _overrides = [];

  TestScenarioBuilder withBasicSetup() {
    _overrides.addAll(GameCanvasTestOverrides.basicOverrides());
    return this;
  }

  TestScenarioBuilder withFullGameCanvas() {
    _overrides.addAll(GameCanvasTestOverrides.fullGameCanvasOverrides());
    return this;
  }

  TestScenarioBuilder withIntegrationSetup() {
    _overrides.addAll(GameCanvasTestOverrides.integrationTestOverrides());
    return this;
  }

  TestScenarioBuilder withCustomGameState(GameStateReader gameStateReader) {
    _overrides.add(
      scopedGameStateProvider.overrideWithValue(gameStateReader),
    );
    return this;
  }

  TestScenarioBuilder withCustomStorage(dynamic storageService) {
    _overrides.add(
      scopedStorageProvider.overrideWithValue(storageService),
    );
    return this;
  }

  ProviderContainer build() {
    return ProviderContainer(overrides: _overrides);
  }
}
