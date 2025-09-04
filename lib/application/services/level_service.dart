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

  LevelService(this._assetBundle);

  /// Load all available levels from assets
  Future<List<LevelDefinition>> loadAllLevels() async {
    try {
      // Known level paths (hardcoded to avoid manifest issues in web)
      final levelPaths = [
        'assets/levels/tutorial/tutorial_01.json',
        'assets/levels/beginner/beginner_01.json',
        // Add more as needed
      ];

      final List<LevelDefinition> levels = [];

      for (final path in levelPaths) {
        try {
          final level = await _loadLevelFromPath(path);
          if (level != null) {
            levels.add(level);
            _levelCache[level.levelId] = level;
            _metadataCache[level.levelId] = level.metadata;
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
      final path = 'assets/levels/${_getLevelPath(levelId)}';
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