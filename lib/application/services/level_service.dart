// lib/application/services/level_service.dart
// Service for loading and managing level definitions from JSON assets

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

class LevelService {
  final AssetBundle _assetBundle;

  // Caching for performance
  final Map<String, LevelDefinition> _levelCache = {};
  final Map<String, LevelMetadata> _metadataCache = {};

  LevelService(this._assetBundle) {
    StructuredLogger.info('🎯 LevelService initialized', context: {
      'assetBundleType': _assetBundle.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Load all available levels from assets
  Future<List<LevelDefinition>> loadAllLevels() async {
    try {
      // Dynamically discover all level files instead of hardcoded paths
      final levelPaths = await _discoverAllLevelFiles();

      StructuredLogger.info('Discovered level files for loading', context: {
        'totalPaths': levelPaths.length,
        'paths': levelPaths,
      });

      final List<LevelDefinition> levels = [];

      for (final path in levelPaths) {
        try {
          final level = await _loadLevelFromPath(path);
          if (level != null) {
            levels.add(level);
            _levelCache[level.levelId] = level;
            _metadataCache[level.levelId] = level.metadata;
            StructuredLogger.debug('Successfully loaded level', context: {
              'levelId': level.levelId,
              'levelPath': path,
              'title': level.metadata.title,
            });
          } else {
            StructuredLogger.warning('Level file returned null', context: {
              'levelPath': path,
            });
          }
        } catch (e) {
          StructuredLogger.warning('Level loading error - continuing with other levels', context: {
            'levelPath': path,
            'error': e.toString(),
          });
          // Continue loading other levels
        }
      }

      // Sort levels by difficulty and ID
      levels.sort(_compareLevels);

      StructuredLogger.info('Level loading completed', context: {
        'totalLevelsLoaded': levels.length,
        'totalPathsAttempted': levelPaths.length,
        'cacheSize': _levelCache.length,
      });

      return levels;
    } catch (e) {
      StructuredLogger.error('Critical failure loading all levels', context: {
        'error': e.toString(),
      }, error: e);
      return [];
    }
  }

  /// Load a specific level by ID
  Future<LevelDefinition?> loadLevel(String levelId) async {
    // Check cache first
    if (_levelCache.containsKey(levelId)) {
      return _levelCache[levelId];
    }

    try {
      final path = 'levels/${_getLevelPath(levelId)}';
      return await _loadLevelFromPath(path);
    } catch (e) {
      StructuredLogger.error('Failed to load specific level', context: {
        'levelId': levelId,
        'levelPath': _getLevelPath(levelId),
        'error': e.toString(),
      }, error: e);
      return null;
    }
  }

  /// Get metadata for a specific level
  Future<LevelMetadata?> getLevelMetadata(String levelId) async {
    // Check cache first
    if (_metadataCache.containsKey(levelId)) {
      return _metadataCache[levelId];
    }

    final level = await loadLevel(levelId);
    return level?.metadata;
  }

  /// Get all available level IDs
  Future<List<String>> getAvailableLevelIds() async {
    final levels = await loadAllLevels();
    return levels.map((level) => level.levelId).toList();
  }

  /// Get levels by difficulty
  Future<List<LevelDefinition>> getLevelsByDifficulty(String difficulty) async {
    final allLevels = await loadAllLevels();
    return allLevels.where((level) => level.metadata.difficulty == difficulty).toList();
  }

  /// Get levels by tag
  Future<List<LevelDefinition>> getLevelsByTag(String tag) async {
    final allLevels = await loadAllLevels();
    return allLevels.where((level) => level.metadata.tags?.contains(tag) ?? false).toList();
  }

  /// Validate level file structure
  Future<bool> validateLevelFile(String levelId) async {
    try {
      final level = await loadLevel(levelId);
      return level != null && _validateLevelStructure(level);
    } catch (e) {
      StructuredLogger.warning('Level validation failed', context: {
        'levelId': levelId,
        'error': e.toString(),
      }, error: e);
      return false;
    }
  }

  /// Clear cache (useful for development/testing)
  void clearCache() {
    _levelCache.clear();
    _metadataCache.clear();
  }

  // Private helper methods

  /// Dynamically discover all available level files
  Future<List<String>> _discoverAllLevelFiles() async {
    StructuredLogger.info('🔍 STARTING LEVEL FILE DISCOVERY', context: {
      'timestamp': DateTime.now().toIso8601String(),
      'assetBundleType': _assetBundle.runtimeType.toString(),
    });

    try {
      // Known level directories to search
      final levelDirectories = [
        'tutorial',
        'beginner',
        'intermediate',
        'advanced',
        'expert',
      ];

      StructuredLogger.info('📂 Searching level directories', context: {
        'directories': levelDirectories,
        'totalDirectories': levelDirectories.length,
      });

      final List<String> levelPaths = [];

      for (final directory in levelDirectories) {
        StructuredLogger.debug('🔎 Checking directory', context: {
          'directory': directory,
          'timestamp': DateTime.now().toIso8601String(),
        });

        try {
          // Try to load a few common level files in each directory
          final possibleFiles = [
            '$directory/${directory}_01.json',
            '$directory/${directory}_02.json',
            '$directory/${directory}_03.json',
            '$directory/${directory}_04.json',
            '$directory/${directory}_05.json',
          ];

          StructuredLogger.debug('📄 Checking possible files in directory', context: {
            'directory': directory,
            'possibleFiles': possibleFiles,
            'fileCount': possibleFiles.length,
          });

          for (final file in possibleFiles) {
            final fullPath = 'levels/$file';

            StructuredLogger.trace('🔍 Testing file existence', context: {
              'file': file,
              'fullPath': fullPath,
              'directory': directory,
            });

            try {
              // Test if file exists by trying to load it
              final startTime = DateTime.now();
              final content = await _assetBundle.loadString(fullPath);
              final loadTime = DateTime.now().difference(startTime);

              levelPaths.add(fullPath);
              StructuredLogger.info('✅ FOUND LEVEL FILE', context: {
                'path': fullPath,
                'directory': directory,
                'file': file,
                'contentLength': content.length,
                'loadTimeMs': loadTime.inMilliseconds,
                'firstChars': content.length > 50 ? content.substring(0, 50) : content,
                'fixApplied': 'removed_double_assets_prefix',
              });
            } catch (e) {
              // File doesn't exist, continue
              StructuredLogger.debug('❌ Level file not found', context: {
                'path': fullPath,
                'directory': directory,
                'file': file,
                'error': e.toString(),
                'errorType': e.runtimeType.toString(),
                'fixApplied': 'removed_double_assets_prefix',
              });
            }
          }
        } catch (e) {
          StructuredLogger.warning('⚠️ Directory search failed', context: {
            'directory': directory,
            'error': e.toString(),
            'errorType': e.runtimeType.toString(),
          });
        }
      }

      StructuredLogger.info('🏁 LEVEL FILE DISCOVERY COMPLETED', context: {
        'totalFilesFound': levelPaths.length,
        'directoriesSearched': levelDirectories.length,
        'foundFiles': levelPaths,
        'discoverySuccessful': levelPaths.isNotEmpty,
      });

      if (levelPaths.isEmpty) {
        StructuredLogger.warning('🚨 NO LEVEL FILES FOUND', context: {
          'searchedDirectories': levelDirectories,
          'thisWillCauseLevelLoadingFailure': true,
          'possibleCauses': [
            'Asset path prefix fix applied - old paths may be cached',
            'Actual level files might be missing from assets folder',
            'Web asset bundling issue'
          ],
        });

        // Try with original assets/ prefix if web is having issues
        StructuredLogger.info('🔄 ATTEMPTING WEB COMPATIBILITY MODE', context: {
          'action': 'retry_with_assets_prefix',
        });

        try {
          const testPath = 'assets/levels/tutorial/tutorial_01.json';
          await _assetBundle.loadString(testPath);
          StructuredLogger.info('✅ WEB COMPATIBILITY: Assets prefix required', context: {
            'pathTried': testPath,
            'result': 'working_with_assets_prefix_remains'
          });
          // Assets prefix still required for web
        } catch (e) {
          StructuredLogger.error('💥 WEB COMPATIBILITY TEST FAILED', context: {
            'message': 'Both path formats failed - critical asset loading problem',
            'error': e.toString(),
          });
        }
      }

      return levelPaths;
    } catch (e) {
      StructuredLogger.error('💥 CRITICAL FAILURE discovering level files', context: {
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
        'stackTrace': StackTrace.current.toString(),
        'assetBundleType': _assetBundle.runtimeType.toString(),
      }, error: e);

      // Fallback to hardcoded paths if discovery fails (no assets/ prefix for web)
      StructuredLogger.info('🔄 FALLING BACK to hardcoded paths', context: {
        'fallbackPaths': [
          'levels/tutorial/tutorial_01.json',
          'levels/beginner/beginner_01.json',
        ],
      });

      return [
        'levels/tutorial/tutorial_01.json',
        'levels/beginner/beginner_01.json',
      ];
    }
  }

  Future<LevelDefinition?> _loadLevelFromPath(String path) async {
    try {
      final jsonString = await _assetBundle.loadString(path);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return LevelDefinition.fromJson(jsonMap);
    } catch (e) {
      StructuredLogger.error('JSON parsing error for level file', context: {
        'levelPath': path,
        'error': e.toString(),
      }, error: e);
      return null;
    }
  }

  String _getLevelPath(String levelId) {
    // Extract difficulty and number from levelId
    // Format: {difficulty}_{number} (e.g., tutorial_01, beginner_01)
    final parts = levelId.split('_');
    if (parts.length >= 2) {
      final difficulty = parts[0];
      return '$difficulty/$levelId.json';
    }
    return '$levelId.json'; // Fallback
  }

  int _compareLevels(LevelDefinition a, LevelDefinition b) {
    // First sort by difficulty
    final difficultyOrder = _getDifficultyOrder(a.metadata.difficulty);
    final otherDifficultyOrder = _getDifficultyOrder(b.metadata.difficulty);

    if (difficultyOrder != otherDifficultyOrder) {
      return difficultyOrder.compareTo(otherDifficultyOrder);
    }

    // Then sort by level ID
    return a.levelId.compareTo(b.levelId);
  }

  int _getDifficultyOrder(String difficulty) {
    const order = {
      'tutorial': 0,
      'beginner': 1,
      'intermediate': 2,
      'advanced': 3,
      'expert': 4,
    };
    return order[difficulty] ?? 5;
  }

  bool _validateLevelStructure(LevelDefinition level) {
    // Basic validation checks
    if (level.levelId.isEmpty) return false;
    if (level.metadata.title.isEmpty) return false;
    if (level.grid.width <= 0 || level.grid.height <= 0) return false;
    if (level.components.available.isEmpty) return false;
    if (level.goals.isEmpty) return false;

    return true;
  }
}