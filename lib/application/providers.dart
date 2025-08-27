import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/infrastructure/audio/audio_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager_state.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager_state.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/presentation/screens/game_screen.dart'; // Moved import

// Provider for the simple AnimationScheduler
final animationSchedulerProvider = Provider((ref) => AnimationScheduler());

// Define sharedPreferencesProvider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Define assetManagerProvider
final assetManagerProvider =
    StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

// Define levelManagerProvider
final levelManagerProvider =
    StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final assetManager = ref.watch(assetManagerProvider.notifier);
  return LevelManagerNotifier(sharedPrefs, assetManager);
});

// Define levelDefinitionProvider
final levelDefinitionProvider =
    FutureProvider.family<LevelDefinition?, int>((ref, levelIndex) async {
  final levelManager = ref.watch(levelManagerProvider.notifier);
  return await levelManager.loadLevelByIndex(levelIndex);
});

// Assumes audioServiceProvider is defined elsewhere, e.g., in audio_service.dart
// This is a common pattern for service providers.

final gameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameEngineState>(
  (ref) {
    final audioService = ref.watch(audioServiceProvider);
    final animationScheduler = ref.watch(animationSchedulerProvider);
    final levelManager = ref.watch(levelManagerProvider.notifier);
    // Remove logger usage
    return GameEngineNotifier(
      audioService: audioService,
      animationScheduler: animationScheduler,
      levelManager: levelManager,
    );
  },
);

final gridProvider = Provider<Grid>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.grid));
});

final isWinProvider = Provider<bool>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.isWin));
});

final debugOverlayProvider = StateProvider<bool>((ref) => false);

// Provider for the game initialization
final gameInitializationProvider =
    AsyncNotifierProvider<GameInitializationNotifier, GameScreenData>(
  () => GameInitializationNotifier(),
);
