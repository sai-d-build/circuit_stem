import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_definition.dart';
import '../models/level_metadata.dart';
import '../engine/render_state.dart';
import '../services/asset_manager.dart';
import '../services/level_manager.dart';
import '../engine/game_engine_notifier.dart';
import '../engine/game_engine_state.dart';
import '../services/level_manager_state.dart';
import '../services/asset_manager_state.dart';
import '../engine/animation_scheduler.dart';
import '../services/audio_service.dart';
import '../ui/controllers/debug_overlay_controller.dart';

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

final gameEngineProvider = StateNotifierProvider.autoDispose
    .family<GameEngineNotifierV2, GameEngineState, LevelDefinition>(
  (ref, level) {
    final animationScheduler = ref.watch(animationSchedulerProvider);
    final audioService = ref.watch(audioServiceProvider);

    return GameEngineNotifierV2(
      initialLevel: level,
      audioService: audioService,
    );
  },
);

// 3. Granular State Providers

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
final renderStateProvider =
    Provider.autoDispose.family<RenderState?, LevelDefinition>((ref, level) {
  return ref
      .watch(gameEngineProvider(level).select((state) => state.renderState));
});

/// Whether the level has been won
final isWinProvider =
    Provider.autoDispose.family<bool, LevelDefinition>((ref, level) {
  return ref
      .watch(gameEngineProvider(level).select((state) => state.isWin));
});
