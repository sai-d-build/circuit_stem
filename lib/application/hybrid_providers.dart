import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager_state.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager_state.dart';

// Import domain entities
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/component.dart';

// Import all the new notifiers
import 'grid_notifier.dart';
import 'history_notifier.dart';
import 'game_progress_notifier.dart';
import 'component_selection_notifier.dart';
import 'interaction_state_notifier.dart';
import 'game_engine_orchestrator.dart';
import 'game_engine_state.dart';
import 'animation_scheduler.dart';

// =============================================================================
// HYBRID FACADE PROVIDERS - Phase 1 Implementation
// =============================================================================

// 1. Foundational Service Providers (unchanged)
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
// NEW GRANULAR NOTIFIER PROVIDERS
// =============================================================================

// Core game logic notifiers
final gridNotifierProvider = StateNotifierProvider<GridNotifier, Grid>((ref) {
  return GridNotifier();
});

final historyNotifierProvider = 
    StateNotifierProvider<HistoryNotifier, List<GameEngineState>>((ref) {
  return HistoryNotifier();
});

final gameProgressNotifierProvider = 
    StateNotifierProvider<GameProgressNotifier, GameProgressState>((ref) {
  return GameProgressNotifier();
});

// UI state notifiers
final componentSelectionNotifierProvider = 
    StateNotifierProvider<ComponentSelectionNotifier, String?>((ref) {
  return ComponentSelectionNotifier();
});

final interactionStateNotifierProvider = 
    StateNotifierProvider<InteractionStateNotifier, InteractionState>((ref) {
  return InteractionStateNotifier();
});

// =============================================================================
// HYBRID ORCHESTRATOR PROVIDER
// =============================================================================

final gameEngineOrchestratorProvider =
    StateNotifierProvider<GameEngineOrchestrator, GameEngineState>((ref) {
  final gridNotifier = ref.watch(gridNotifierProvider.notifier);
  final historyNotifier = ref.watch(historyNotifierProvider.notifier);
  final progressNotifier = ref.watch(gameProgressNotifierProvider.notifier);
  
  return GameEngineOrchestrator(gridNotifier, historyNotifier, progressNotifier);
});

// =============================================================================
// GRANULAR STATE PROVIDERS - For UI Performance
// =============================================================================

// Grid-specific providers
final gridProvider = Provider<Grid>((ref) {
  return ref.watch(gridNotifierProvider);
});

final gridComponentsProvider = Provider<List<ComponentModel>>((ref) {
  return ref.watch(gridNotifierProvider.select((grid) => grid.components));
});

// Game progress providers
final isWinProvider = Provider<bool>((ref) {
  return ref.watch(gameProgressNotifierProvider.select((progress) => progress.isWin));
});

final isPausedProvider = Provider<bool>((ref) {
  return ref.watch(gameProgressNotifierProvider.select((progress) => progress.isPaused));
});

final scoreProvider = Provider<int>((ref) {
  return ref.watch(gameProgressNotifierProvider.select((progress) => progress.score));
});

// UI interaction providers
final selectedComponentIdProvider = Provider<String?>((ref) {
  return ref.watch(componentSelectionNotifierProvider);
});

final dragStateProvider = Provider<InteractionState>((ref) {
  return ref.watch(interactionStateNotifierProvider);
});

final isDraggingProvider = Provider<bool>((ref) {
  return ref.watch(interactionStateNotifierProvider.select((state) => state.isDragging));
});

// History providers
final canUndoProvider = Provider<bool>((ref) {
  return ref.watch(historyNotifierProvider.select((history) => history.isNotEmpty));
});

final historyLengthProvider = Provider<int>((ref) {
  return ref.watch(historyNotifierProvider.select((history) => history.length));
});

// =============================================================================
// BACKWARD COMPATIBILITY PROVIDER
// =============================================================================

// This maintains the existing API while using the new architecture internally
final gameEngineProvider = Provider<GameEngineState>((ref) {
  // Watch the orchestrator for the main state
  final orchestratorState = ref.watch(gameEngineOrchestratorProvider);
  
  // Enhance with granular state from other notifiers
  final selectedComponentId = ref.watch(selectedComponentIdProvider);
  final interactionState = ref.watch(dragStateProvider);
  
  // Return enhanced composite state
  return orchestratorState.copyWith(
    selectedComponentId: selectedComponentId,
    draggedComponentId: interactionState.draggedComponentId,
    dragPosition: interactionState.dragPosition,
  );
});

// =============================================================================
// MIGRATION HELPERS
// =============================================================================

// Helper provider for accessing the orchestrator's action execution
final gameEngineActionsProvider = Provider<GameEngineOrchestrator>((ref) {
  return ref.watch(gameEngineOrchestratorProvider.notifier);
});

// Helper for UI components that need to trigger actions
final gameEngineNotifierProvider = Provider<GameEngineOrchestrator>((ref) {
  return ref.watch(gameEngineOrchestratorProvider.notifier);
});