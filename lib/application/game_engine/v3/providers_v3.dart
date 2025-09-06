import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import './game_engine_notifier_v3.dart';
import '../../../infrastructure/persistence/shared_preferences_storage_service.dart';
import '../../states/game_state.dart';
import '../../services/level_service.dart' as level_service;

// Storage Service Provider
final storageServiceProvider = Provider<SharedPreferencesStorageService>((ref) {
  throw UnimplementedError('Storage service must be initialized in main.dart');
});

// Game Engine V3 Provider - Clean implementation
final gameEngineNotifierV3Provider = StateNotifierProvider<GameEngineNotifierV3, GameState>((ref) {
  return GameEngineNotifierV3();
});

// Enhanced Game State Provider (alias for V3)
final enhancedGameStateNotifierProvider = gameEngineNotifierV3Provider;

// Palette Drag Active Provider - tracks if a drag from palette is in progress
final paletteDragActiveProvider = StateProvider<bool>((ref) => false);

// Level Service Provider
final levelServiceProvider = Provider<level_service.LevelService>((ref) {
  return level_service.LevelService(rootBundle);
});
