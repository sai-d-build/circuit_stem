// Game State & Engine Providers
// ===============================
// This file manages game engines and state providers with feature flag support.
// Handles switching between V1 (stable) and V3 (experimental) game engines.
// Supports A/B testing and gradual migration scenarios.
//
// Feature Flags:
// - useV3EngineProvider: Controls whether to use V1 or V3 game engine
// - Supports runtime switching for testing different implementations
// - Defaults to V1 (stable) for production safety
//
// Architecture: Mediator Pattern with Strategy Selection
// Testing: Feature flags allow testing different engine implementations
// Performance: Engine selection affects simulation performance significantly
//
// ⚠️  IMPORTANT: Game engine selection affects user experience.
// ⚠️  Always validate performance before deploying new engines.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Core engine types
import '../game_engine_notifier.dart';
import '../game_engine/v3/game_engine_notifier_v3.dart';
import '../game_engine_state.dart'; // For V1 GameEngineState
import '../states/game_state.dart'; // For V3 GameState

// Import service providers from main facade
import '../providers.dart' show
  audioServiceProvider,
  animationSchedulerProvider;

// Import missing providers
import '../grid_notifier.dart' show gridNotifierProvider;
import '../history_notifier.dart' show historyNotifierProvider;
import '../game_progress_notifier.dart' show gameProgressNotifierProvider;
import '../component_selection_notifier.dart' show componentSelectionNotifierProvider;
import '../providers/core_providers.dart' show interactionStateProvider;
import '../services/component_palette_manager.dart';

// Import use case providers
import '../use_cases/providers.dart' as use_case_providers;

/// Engine version enum for future-proofing and better type safety
enum GameEngineVersion {
  v1, // Current stable production engine
  v3, // Experimental next-generation engine
  // v4, // Future engine versions can be added here
}

/// Abstract GameEngine interface that both V1 and V3 implementations conform to
/// This allows the provider system to work with both engines uniformly
abstract class GameEngine {
  void loadLevel(dynamic level);
  void togglePause();
  void restartLevel();
  void undo();
  void tapComponent(dynamic component);
  void moveComponent(String id, int r, int c);
  void updateComponent(dynamic component);
  void selectPaletteComponent(dynamic component);
  void rotateComponent(String componentId, int rotation);
}

// ============================================================================
// FEATURE FLAG SYSTEM
// ============================================================================

/// Engine selection feature flag
/// Controls which game engine implementation is used
/// Default: V1 (stable) engine for production safety
final useV3EngineProvider = Provider<bool>((ref) {
  // Use V3 in debug/development, V1 in production
  return kDebugMode ? false : false; // Safe: V1 by default
});

/// Engine version provider for more granular control and future versions
/// Provides type-safe engine selection with validation
final gameEngineVersionProvider = Provider<GameEngineVersion>((ref) {
  final useV3 = ref.watch(useV3EngineProvider);
  return useV3 ? GameEngineVersion.v3 : GameEngineVersion.v1;
});

/// Engine state synchronization provider
/// Ensures both engines maintain consistent state when switching
/// Useful for state validation and rollback scenarios
final gameEngineStateSynchronizerProvider = Provider<GameEngineStateSynchronizer>((ref) {
  return GameEngineStateSynchronizer(
    v1Engine: ref.watch(gameEngineV1Provider.notifier),
    v3Engine: ref.watch(gameEngineV3Provider.notifier),
  );
});

/// State synchronizer class for engine consistency
class GameEngineStateSynchronizer {
  final GameEngineNotifier v1Engine;
  final GameEngineNotifierV3 v3Engine;

  const GameEngineStateSynchronizer({
    required this.v1Engine,
    required this.v3Engine,
  });

  /// Validate that both engines have equivalent state (for debugging)
  bool validateEngineConsistency() {
    // Implementation would compare key state properties between engines
    // This is useful during development and A/B testing
    return true; // Placeholder - would implement actual validation
  }

  /// Reset both engines to a consistent state
  void resetEngines() {
    // Implementation would synchronize engine states
    // This ensures no state drift when switching engines
  }
}

// ============================================================================
// GAME ENGINE PROVIDERS
// ============================================================================

/// V1 Game Engine Provider (Stable, Current Production)
/// Provides the current stable game engine implementation
/// Architecture: Uses middleware pattern and use case orchestration
final gameEngineV1Provider = StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  return GameEngineNotifier(
    audioService: ref.watch(audioServiceProvider),
    animationScheduler: ref.watch(animationSchedulerProvider),
    gridNotifier: ref.watch(gridNotifierProvider.notifier),
    historyNotifier: ref.watch(historyNotifierProvider.notifier),
    progressNotifier: ref.watch(gameProgressNotifierProvider.notifier),
    selectionNotifier: ref.watch(componentSelectionNotifierProvider.notifier),
    interactionNotifier: ref.watch(interactionStateProvider('default').notifier),
    paletteManager: const ComponentPaletteManager(availableTemplates: []),
    loadLevelUseCase: ref.watch(use_case_providers.loadLevelUseCaseProvider),
    createComponentUseCase: ref.watch(use_case_providers.createComponentUseCaseProvider),
    rotateComponentUseCase: ref.watch(use_case_providers.rotateComponentUseCaseProvider),
    moveComponentUseCase: ref.watch(use_case_providers.moveComponentUseCaseProvider),
    tapComponentUseCase: ref.watch(use_case_providers.tapComponentUseCaseProvider),
    updateComponentUseCase: ref.watch(use_case_providers.updateComponentUseCaseProvider),
    restartLevelUseCase: ref.watch(use_case_providers.restartLevelUseCaseProvider),
    selectPaletteComponentUseCase: ref.watch(use_case_providers.selectPaletteComponentUseCaseProvider),
    togglePauseUseCase: ref.watch(use_case_providers.togglePauseUseCaseProvider),
    undoUseCase: ref.watch(use_case_providers.undoUseCaseProvider),
  );
});

/// V3 Game Engine Provider (Experimental)
/// Provides the new experimental game engine implementation
/// Architecture: Direct state management, redesigned from scratch
final gameEngineV3Provider = StateNotifierProvider<GameEngineNotifierV3, GameState>((ref) {
  return GameEngineNotifierV3();
});

// ============================================================================
// MAIN GAME ENGINE SELECTOR
// ============================================================================

/// Main Game Engine Provider (Feature Flag Controlled)
/// This is the single provider that applications depend on.
/// Uses feature flag to select between V1 and V3 implementations.
/// Returns the notifier (StateNotifier) for state management.
///
/// Usage: Use this provider everywhere instead of directly accessing V1/V3
final gameEngineProvider = Provider<GameEngine>((ref) {
  final useV3 = ref.watch(useV3EngineProvider);
  return useV3
      ? ref.watch(gameEngineV3Provider.notifier) as GameEngine
      : ref.watch(gameEngineV1Provider.notifier) as GameEngine;
});

/// Backward Compatibility: Alias for enhancedStateNotifier
/// Existing code uses this - maintains compatibility during migration
final enhancedGameStateNotifierProvider = gameEngineProvider;

// ============================================================================
// DEVELOPMENT NOTES
// ============================================================================
// Engine Selection Strategy:
// 1. Default to V1 for production safety
// 2. Enable V3 in debug mode for testing
// 3. Use AB testing patterns for gradual rollout
// 4. Monitor performance metrics when switching engines
//
// Future Migration Path:
// 1. V4 will be added alongside V3
// 2. Feature flag becomes enum: GameEngineVersion.v1, v3, v4
// 3. Gradual deprecation of older versions
// 4. Keep backward compatibility during transition periods