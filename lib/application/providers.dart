import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager_state.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager_state.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/domain/entities/level_metadata.dart';
import 'package:circuit_stem/application/render_state.dart';

// Hybrid system imports
import 'package:circuit_stem/domain/entities/component.dart';
import 'grid_notifier.dart';
import 'history_notifier.dart';
import 'game_progress_notifier.dart';
import 'component_selection_notifier.dart';
import 'interaction_state_notifier.dart';
import 'game_engine_orchestrator.dart';
import 'hybrid_game_engine_adapter.dart';
import 'services/component_palette_manager.dart';

// Feature flag imports
import '../common/feature_flags.dart';
import 'feature_flag_service.dart';

// =============================================================================
// FOUNDATIONAL SERVICE PROVIDERS
// =============================================================================

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider must be overridden');
});

final assetManagerProvider =
    StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

final audioServiceProvider = Provider((ref) => AudioService());
final animationSchedulerProvider = Provider((ref) => AnimationScheduler());

final levelManagerProvider =
    StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final assetManager = ref.watch(assetManagerProvider.notifier);
  return LevelManagerNotifier(sharedPrefs, assetManager);
});

// =============================================================================
// HYBRID NOTIFIER PROVIDERS (only available when hybrid is enabled)
// =============================================================================

final gridNotifierProvider = StateNotifierProvider<GridNotifier, Grid>((ref) {
  if (!FeatureFlags.useHybridEngine && !FeatureFlagService.useHybridEngine) {
    throw UnsupportedError('GridNotifier requires hybrid engine to be enabled');
  }
  return GridNotifier();
});

final historyNotifierProvider = 
    StateNotifierProvider<HistoryNotifier, List<GameEngineState>>((ref) {
  if (!FeatureFlags.useHybridEngine && !FeatureFlagService.useHybridEngine) {
    throw UnsupportedError('HistoryNotifier requires hybrid engine to be enabled');
  }
  return HistoryNotifier();
});

final gameProgressNotifierProvider = 
    StateNotifierProvider<GameProgressNotifier, GameProgressState>((ref) {
  if (!FeatureFlags.useHybridEngine && !FeatureFlagService.useHybridEngine) {
    throw UnsupportedError('GameProgressNotifier requires hybrid engine to be enabled');
  }
  return GameProgressNotifier();
});

final componentSelectionNotifierProvider = 
    StateNotifierProvider<ComponentSelectionNotifier, String?>((ref) {
  if (!FeatureFlags.useHybridEngine && !FeatureFlagService.useHybridEngine) {
    throw UnsupportedError('ComponentSelectionNotifier requires hybrid engine to be enabled');
  }
  return ComponentSelectionNotifier();
});

final interactionStateNotifierProvider = 
    StateNotifierProvider<InteractionStateNotifier, InteractionState>((ref) {
  if (!FeatureFlags.useHybridEngine && !FeatureFlagService.useHybridEngine) {
    throw UnsupportedError('InteractionStateNotifier requires hybrid engine to be enabled');
  }
  return InteractionStateNotifier();
});

// =============================================================================
// ORCHESTRATOR PROVIDER (hybrid only)
// =============================================================================

final gameEngineOrchestratorProvider =
    StateNotifierProvider<GameEngineOrchestrator, GameEngineState>((ref) {
  if (!FeatureFlags.useHybridEngine && !FeatureFlagService.useHybridEngine) {
    throw UnsupportedError('GameEngineOrchestrator requires hybrid engine to be enabled');
  }
  
  final gridNotifier = ref.watch(gridNotifierProvider.notifier);
  final historyNotifier = ref.watch(historyNotifierProvider.notifier);
  final progressNotifier = ref.watch(gameProgressNotifierProvider.notifier);
  final selectionNotifier = ref.watch(componentSelectionNotifierProvider.notifier);
  final interactionNotifier = ref.watch(interactionStateNotifierProvider.notifier);
  
  return GameEngineOrchestrator(
    gridNotifier,
    historyNotifier,
    progressNotifier,
    selectionNotifier,
    interactionNotifier,
    const ComponentPaletteManager([]),
  );
});

final hybridGameEngineAdapterProvider =
    StateNotifierProvider<HybridGameEngineAdapter, GameEngineState>((ref) {
  if (!FeatureFlags.useHybridEngine && !FeatureFlagService.useHybridEngine) {
    throw UnsupportedError('HybridGameEngineAdapter requires hybrid engine to be enabled');
  }
  
  // This would be implemented similar to the hybrid_providers.dart version
  // For now, we'll delegate to the orchestrator
  return ref.watch(hybridGameEngineProvider.notifier) as HybridGameEngineAdapter;
});

// =============================================================================
// ORIGINAL GAME ENGINE PROVIDER (for non-hybrid mode)
// =============================================================================

final _originalGameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final animationScheduler = ref.watch(animationSchedulerProvider);
  final levelManager = ref.watch(levelManagerProvider.notifier);

  return GameEngineNotifier(
    audioService: audioService,
    animationScheduler: animationScheduler,
    levelManager: levelManager,
  );
});

// =============================================================================
// UNIFIED GAME ENGINE PROVIDER (feature flag switching)
// =============================================================================

final gameEngineProvider = Provider<GameEngineState>((ref) {
  // Check both compile-time and runtime flags
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    // Use hybrid system - composite state from orchestrator and granular notifiers
    final orchestratorState = ref.watch(gameEngineOrchestratorProvider);
    final selectedComponentId = ref.watch(componentSelectionNotifierProvider);
    final interactionState = ref.watch(interactionStateNotifierProvider);
    
    return orchestratorState.copyWith(
      selectedComponentId: selectedComponentId,
      draggedComponentId: interactionState.draggedComponentId,
      dragPosition: interactionState.dragPosition,
    );
  } else {
    // Use original monolithic system
    return ref.watch(_originalGameEngineProvider);
  }
});

// =============================================================================
// GRANULAR STATE PROVIDERS (with feature flag switching)
// =============================================================================

final gridProvider = Provider<Grid>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(gridNotifierProvider);
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.grid));
  }
});

final isWinProvider = Provider<bool>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(gameProgressNotifierProvider.select((progress) => progress.isWin));
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.isWin));
  }
});

// Additional granular providers (hybrid only)
final gridComponentsProvider = Provider<List<ComponentModel>>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(gridNotifierProvider.select((grid) => grid.components));
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.grid.components));
  }
});

final isPausedProvider = Provider<bool>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(gameProgressNotifierProvider.select((progress) => progress.isPaused));
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.isPaused));
  }
});

final scoreProvider = Provider<int>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(gameProgressNotifierProvider.select((progress) => progress.score));
  } else {
    // Original system doesn't have score in progress, might be in game state
    return 0; // Default value
  }
});

final selectedComponentIdProvider = Provider<String?>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(componentSelectionNotifierProvider);
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.selectedComponentId));
  }
});

final dragStateProvider = Provider<InteractionState>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(interactionStateNotifierProvider);
  } else {
    final state = ref.watch(gameEngineProvider);
    return InteractionState(
      draggedComponentId: state.draggedComponentId,
      dragPosition: state.dragPosition,
      isDragging: state.draggedComponentId != null,
    );
  }
});

final isDraggingProvider = Provider<bool>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(interactionStateNotifierProvider.select((state) => state.isDragging));
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.draggedComponentId != null));
  }
});

final canUndoProvider = Provider<bool>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(historyNotifierProvider.select((history) => history.isNotEmpty));
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.history.isNotEmpty));
  }
});

final historyLengthProvider = Provider<int>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(historyNotifierProvider.select((history) => history.length));
  } else {
    return ref.watch(gameEngineProvider.select((state) => state.history.length));
  }
});

// =============================================================================
// LEGACY PROVIDERS (preserved for compatibility)
// =============================================================================

final levelsProvider = Provider<List<LevelMetadata>>((ref) {
  return ref.watch(levelManagerProvider).levels;
});

final completedLevelIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(levelManagerProvider).completedLevelIds;
});

final levelIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(levelManagerProvider).isLoading;
});

final renderStateProvider = Provider<RenderState?>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.renderState));
});

final levelDefinitionProvider =
    FutureProvider.family<LevelDefinition?, int>((ref, levelIndex) async {
  final levelManager = ref.watch(levelManagerProvider.notifier);
  return await levelManager.loadLevelByIndex(levelIndex);
});

final debugOverlayProvider = StateProvider<bool>((ref) => false);

// =============================================================================
// MIGRATION HELPERS
// =============================================================================

final gameEngineActionsProvider = Provider<dynamic>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(gameEngineOrchestratorProvider.notifier);
  } else {
    return ref.watch(_originalGameEngineProvider.notifier);
  }
});

final gameEngineNotifierProvider = Provider<dynamic>((ref) {
  final useHybrid = FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;
  
  if (useHybrid) {
    return ref.watch(gameEngineOrchestratorProvider.notifier);
  } else {
    return ref.watch(_originalGameEngineProvider.notifier);
  }
});