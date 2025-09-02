import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_engine_state.dart';
import 'game_engine_notifier.dart';
import '../infrastructure/audio/audio_service.dart';
import '../infrastructure/persistence/level_manager.dart';
import '../infrastructure/persistence/level_manager_state.dart';
import 'animation_scheduler.dart';
import '../infrastructure/rendering/asset_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service Providers
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
