import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/debug/structured_logger.dart';
import '../../../infrastructure/persistence/shared_preferences_storage_service.dart';
import '../../services/level_service.dart' as level_service;
import '../../states/game_state.dart';
import './game_engine_notifier_v3.dart';

// Storage Service Provider
final storageServiceProvider = Provider<SharedPreferencesStorageService>((ref) {
  throw UnimplementedError('Storage service must be initialized in main.dart');
});

// Game Engine V3 Provider - Clean implementation
final gameEngineNotifierV3Provider =
    StateNotifierProvider<GameEngineNotifierV3, GameState>((ref) {
  return GameEngineNotifierV3();
});

// Enhanced Game State Provider (alias for V3)
final enhancedGameStateNotifierProvider = gameEngineNotifierV3Provider;

// Palette Drag Active Provider - tracks if a drag from palette is in progress
final paletteDragActiveProvider = StateProvider<bool>((ref) => false);

// Level Service Provider
final levelServiceProvider = Provider<level_service.LevelService>((ref) {
  StructuredLogger.info('🏗️ CREATING LevelService provider', context: {
    'timestamp': DateTime.now().toIso8601String(),
    'rootBundleType': rootBundle.runtimeType.toString(),
  });

  final service = level_service.LevelService(rootBundle);

  StructuredLogger.info('✅ LevelService provider created successfully',
      context: {
        'serviceType': service.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });

  return service;
});
