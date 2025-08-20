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
import '../ui/controllers/debug_overlay_controller.dart'; // Added import

// This file is the single source of truth for all core providers.

// 1. Foundational Service Providers

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences provider was not overridden');
});

final assetManagerProvider = StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

final audioServiceProvider = Provider((ref) => AudioService());
final animationSchedulerProvider = Provider((ref) => AnimationScheduler());

final debugOverlayControllerProvider = ChangeNotifierProvider((ref) => DebugOverlayController()); // Added provider

// 2. Core Notifier Providers

final levelManagerProvider = StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  return LevelManagerNotifier(
    ref.watch(sharedPreferencesProvider),
    ref.watch(assetManagerProvider.notifier),
  );
});

final levelDefinitionProvider = FutureProvider.autoDispose.family<LevelDefinition?, int>((ref, levelNumber) async {
  final levelManager = ref.watch(levelManagerProvider.notifier);
  return await levelManager.loadLevelByIndex(levelNumber);
});

final gameEngineProvider = StateNotifierProvider.autoDispose.family<GameEngineNotifier, GameEngineState, LevelDefinition>((ref, level) {
  final animationScheduler = ref.watch(animationSchedulerProvider);
  final audioService = ref.watch(audioServiceProvider);

  return GameEngineNotifier(
    initialLevel: level,
    animationScheduler: animationScheduler,
    audioService: audioService,
  );
});

// 3. Granular State Providers

/// Provider for the list of all level metadata.
final levelsProvider = Provider<List<LevelMetadata>>((ref) {
  return ref.watch(levelManagerProvider).levels;
}, dependencies: [levelManagerProvider]);

/// Provider for the set of completed level IDs.
final completedLevelIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(levelManagerProvider).completedLevelIds;
}, dependencies: [levelManagerProvider]);

/// Provider that returns true if the level manager is busy loading.
final levelIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(levelManagerProvider).isLoading;
}, dependencies: [levelManagerProvider]);



/// Provider for the game's render state.
final renderStateProvider = Provider.autoDispose.family<RenderState?, LevelDefinition>((ref, level) {
  return ref.watch(gameEngineProvider(level).select((state) => state.renderState));
});

/// Provider that returns true if the game has been won.
final isWinProvider = Provider.autoDispose.family<bool, LevelDefinition>((ref, level) {
  return ref.watch(gameEngineProvider(level).select((state) => state.isWin));
});
