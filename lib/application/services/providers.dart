import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../domain/entities/grid.dart';

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

// 2. Core Notifier Providers
final levelManagerProvider =
    StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final assetManager = ref.watch(assetManagerProvider.notifier);
  return LevelManagerNotifier(sharedPrefs, assetManager);
});

final gameEngineProvider =
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

// 3. Granular State Providers
final gridProvider = Provider<Grid>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.grid));
});

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

final isWinProvider = Provider<bool>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.isWin));
});
