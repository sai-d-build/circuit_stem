import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_engine_state.dart';
import 'game_engine_notifier.dart';
import '../infrastructure/audio/audio_service.dart';
import '../infrastructure/persistence/level_manager.dart';
import '../infrastructure/persistence/level_manager_state.dart';
import 'animation_scheduler.dart';
import '../infrastructure/rendering/asset_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import all provider definitions with prefixes to avoid conflicts
import 'use_cases/providers.dart' as use_case_providers;
import 'game_engine/v3/providers_v3.dart' as v3_providers;

// MAINTAIN EXISTING PROVIDERS
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final assetManagerNotifierProvider = Provider<AssetManagerNotifier>((ref) {
  return AssetManagerNotifier();
});

final levelManagerProvider = StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final assetManager = ref.watch(assetManagerNotifierProvider);
  final manager = LevelManagerNotifier(sharedPrefs, assetManager);
  manager.init(); // Initialize the manager
  return manager;
});

// Animation Scheduler Provider
final animationSchedulerProvider = Provider<AnimationScheduler>((ref) {
  final manager = AnimationScheduler();
  ref.onDispose(() => manager.dispose());
  return manager;
});

// Game Engine Provider
final gameEngineNotifierProvider = StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  return GameEngineNotifier(
    audioService: ref.watch(audioServiceProvider),
    animationScheduler: ref.watch(animationSchedulerProvider),
    ref: ref,
  );
});

// ============================================================================
// PROVIDER RE-EXPORTS FOR TEST AND APPLICATION ACCESS
// Use prefixes to avoid name conflicts
// ============================================================================

// Core Service Providers (from use_cases/providers.dart)
final componentFactoryProvider = use_case_providers.componentFactoryProvider;
final simulationEngineProvider = use_case_providers.simulationEngineProvider;
final netlistBuilderProvider = use_case_providers.netlistBuilderProvider;
final commandStackProvider = use_case_providers.commandStackProvider;

// Storage provider - only use the use_cases version to avoid conflicts
final storageServiceProvider = use_case_providers.storageServiceProvider;

// MNA solver and simulation providers from use_cases
final mnaSolverProvider = use_case_providers.mnaSolverProvider;
final powerSimulationServiceProvider = use_case_providers.powerSimulationServiceProvider;
final goalCheckingServiceProvider = use_case_providers.goalCheckingServiceProvider;
final componentPaletteManagerProvider = use_case_providers.componentPaletteManagerProvider;

// Use case providers from use_cases
final checkWinConditionUseCaseProvider = use_case_providers.checkWinConditionUseCaseProvider;
final createComponentUseCaseProvider = use_case_providers.createComponentUseCaseProvider;
final loadLevelUseCaseProvider = use_case_providers.loadLevelUseCaseProvider;
final moveComponentUseCaseProvider = use_case_providers.moveComponentUseCaseProvider;
final restartLevelUseCaseProvider = use_case_providers.restartLevelUseCaseProvider;
final rotateComponentUseCaseProvider = use_case_providers.rotateComponentUseCaseProvider;
final selectPaletteComponentUseCaseProvider = use_case_providers.selectPaletteComponentUseCaseProvider;
final simulatePowerFlowUseCaseProvider = use_case_providers.simulatePowerFlowUseCaseProvider;
final tapComponentUseCaseProvider = use_case_providers.tapComponentUseCaseProvider;
final togglePauseUseCaseProvider = use_case_providers.togglePauseUseCaseProvider;
final undoUseCaseProvider = use_case_providers.undoUseCaseProvider;
final updateComponentUseCaseProvider = use_case_providers.updateComponentUseCaseProvider;

// Game Engine V3 Providers - use specific names to avoid conflicts
final enhancedGameStateNotifierProvider = v3_providers.enhancedGameStateNotifierProvider;
final gameEngineNotifierV3Provider = v3_providers.gameEngineNotifierV3Provider;
final paletteDragActiveProvider = v3_providers.paletteDragActiveProvider;
final levelServiceProvider = v3_providers.levelServiceProvider;
// Note: v3_providers.storageServiceProvider is shadowed to avoid conflicts