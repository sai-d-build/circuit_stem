import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'game_engine_notifier_v3.dart';
import '../../infrastructure/persistence/shared_preferences_storage_service.dart';
import '../enhanced_game_state.dart';
import '../../domain/entities/level_definition.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

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
final levelServiceProvider = Provider<LevelService>((ref) {
  return LevelService();
});

// Level service implementation
class LevelService {
  Future<List<LevelDefinition>> loadAllLevels() async {
    final List<LevelDefinition> levels = [];

    // Define level files to load
    final levelFiles = [
      'assets/levels/tutorial/tutorial_01.json',
      'assets/levels/beginner/beginner_01.json',
    ];

    for (final filePath in levelFiles) {
      try {
        StructuredLogger.debug('Loading individual level file', context: {
          'levelPath': filePath,
        });

        final jsonString = await rootBundle.loadString(filePath);

        StructuredLogger.trace('Level JSON file loaded', context: {
          'levelPath': filePath,
          'jsonLength': jsonString.length,
        });

        final dynamic jsonData = json.decode(jsonString);

        StructuredLogger.trace('Level JSON parsed', context: {
          'levelPath': filePath,
          'jsonType': jsonData.runtimeType.toString(),
        });

        if (jsonData is! Map<String, dynamic>) {
          StructuredLogger.warning('Invalid JSON structure found in level file', context: {
            'levelPath': filePath,
            'jsonType': jsonData.runtimeType.toString(),
            'expectedType': 'Map<String, dynamic>',
          });
          continue;
        }

        final level = LevelDefinition.fromJson(jsonData);
        levels.add(level);

        StructuredLogger.debug('Level successfully loaded', context: {
          'levelId': level.levelId,
          'levelPath': filePath,
          'title': level.metadata.title,
        });
      } catch (e, stackTrace) {
        StructuredLogger.error('Failed to load level file', context: {
          'levelPath': filePath,
          'error': e.toString(),
          'levelsLoaded': levels.length,
        }, error: e);
        // Continue loading other levels even if one fails
      }
    }

    StructuredLogger.info('Level loading batch complete', context: {
      'totalLevelsLoaded': levels.length,
      'levels': levels.map((level) => level.levelId).toList(),
    });
    return levels;
  }

  Future<LevelDefinition?> loadLevel(String levelId) async {
    final allLevels = await loadAllLevels();

    // Map simple level IDs to actual level file names
    final levelIdMapping = {
      '1': 'tutorial_01',
      '2': 'beginner_01',
      // Add more mappings as needed
    };

    final mappedLevelId = levelIdMapping[levelId] ?? levelId;

    try {
      return allLevels.firstWhere((level) => level.levelId == mappedLevelId);
    } catch (e) {
      StructuredLogger.warning('Level search failed', context: {
        'originalLevelId': levelId,
        'mappedLevelId': mappedLevelId,
        'availableLevels': allLevels.map((level) => level.levelId).toList(),
        'error': e.toString(),
      });
      return null;
    }
  }
}