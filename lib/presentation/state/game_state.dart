
// PURPOSE: Provide the core GameEngineNotifier to the UI using Riverpod.
// STRATEGY: This uses a StateNotifierProvider to wrap the existing GameEngineNotifier.
// NO LOGIC CHANGES ARE MADE TO THE ENGINE ITSELF.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/game_engine_notifier.dart';
import '../../infrastructure/audio/audio_service.dart';
import '../../infrastructure/persistence/level_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/animation_scheduler.dart';
import '../../infrastructure/rendering/asset_manager.dart';
import '../../infrastructure/rendering/asset_manager_state.dart';
import '../../domain/entities/level_metadata.dart';
import '../../domain/entities/grid.dart';
import '../../application/game_engine_state.dart';
import '../../infrastructure/persistence/level_manager_state.dart'; // New import

// Provider for SharedPreferences, which is a dependency for other services
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for AudioService
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// Provider for AssetManager
final assetManagerProvider =
    StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

// Provider for LevelManager
final levelManagerProvider = StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData!.value;
  final assetManager = ref.watch(assetManagerProvider.notifier); // Get AssetManagerNotifier
  return LevelManagerNotifier(prefs, assetManager); // Pass both arguments
});

// The core GameEngine provider that wraps the existing notifier
final gameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final levelManager = ref.watch(levelManagerProvider);
  // The existing GameEngineNotifier is instantiated here with its dependencies
  return GameEngineNotifier(
    audioService: audioService,
    levelManager: levelManager,
    // TODO: Refactor AnimationScheduler to be provided by a provider
    animationScheduler: AnimationScheduler(),
  );
});

// Example of a new, UI-specific state provider that listens to the game engine
final isGameWonProvider = Provider<bool>((ref) {
  return ref.watch(gameEngineProvider.select((s) => s.isWin));
});

final levelsProvider = Provider<List<LevelMetadata>>((ref) {
  return ref.watch(levelManagerProvider).levels;
});

final completedLevelIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(levelManagerProvider).completedLevelIds;
});

final gridProvider = Provider<Grid>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.grid));
});
