import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/level_definition.dart';
import '../../domain/entities/level_metadata.dart';
import '../render_state.dart';
import '../../infrastructure/rendering/asset_manager.dart';
import '../../infrastructure/persistence/level_manager.dart';
import '../game_engine_notifier.dart';
import '../game_engine_state.dart';
import '../../infrastructure/persistence/level_manager_state.dart';
import '../../infrastructure/rendering/asset_manager_state.dart';
import '../animation_scheduler.dart';
import '../../infrastructure/audio/audio_service.dart';
import '../../presentation/controllers/debug_overlay_controller.dart';
import '../../domain/entities/grid.dart';

// This file is the single source of truth for all core providers.

// 1. Foundational Service Providers

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider must be overridden');
});

final assetManagerProvider =
    StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

final audioServiceProvider = Provider((ref) => AudioService());
final animationSchedulerProvider = Provider((ref) => AnimationScheduler());

final debugOverlayControllerProvider =
    ChangeNotifierProvider((ref) => DebugOverlayController());

// 2. Core Notifier Providers

final levelManagerProvider =
    StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final assetManager = ref.watch(assetManagerProvider.notifier);
  return LevelManagerNotifier(sharedPrefs, assetManager);
});

/// Pure provider: fetches level data without mutating other state
final levelDefinitionProvider =
    FutureProvider.autoDispose.family<LevelDefinition?, int>(
  (ref, levelNumber) async {
    final levelManager = ref.watch(levelManagerProvider.notifier);
    return levelManager.loadLevelByIndex(levelNumber);
  },
);

final gameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final animationScheduler = ref.watch(animationSchedulerProvider);
  // The notifier is now created without a level.
  // Levels will be loaded by calling a method on the notifier.
  return GameEngineNotifier(
    audioService: audioService,
    animationScheduler: animationScheduler,
  );
});

// 3. Granular State Providers

/// Provides the current grid from the game engine.
/// UI widgets should watch this to rebuild only when the grid changes.
final gridProvider = Provider<Grid>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.grid));
});

/// List of all levels
final levelsProvider = Provider<List<LevelMetadata>>((ref) {
  return ref.watch(levelManagerProvider).levels;
});

/// Set of completed level IDs
final completedLevelIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(levelManagerProvider).completedLevelIds;
});

/// Indicates if LevelManager is busy loading
final levelIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(levelManagerProvider).isLoading;
});

/// Current render state of a level
final renderStateProvider = Provider<RenderState?>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.renderState));
});

/// Whether the level has been won
final isWinProvider = Provider<bool>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.isWin));
});
