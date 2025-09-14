import 'package:flutter/services.dart' show rootBundle;
import '../entity/grid_configuration.dart';
import 'dart:convert';
import '../config/grid_config_constants.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
// ================================
// 🔧 REPOSITORY IMPLEMENTATION
/// Repository interface for grid configuration data
abstract class IGridConfigurationRepository {
  /// Always returns visual grid dimensions (20×20)
  GridDimensions getVisualDimensions();

  /// Returns current gameplay boundaries (may be different per level)
  GridDimensions getDefaultGameplayBounds();

  /// Returns level-specific bounds if loaded, otherwise default
  GridDimensions getCurrentLevelBounds();

  /// Load level-specific grid configuration
  Future<void> loadLevelBounds(String levelId);

  /// Reset to default configuration
  void resetToDefaults();

  /// Get debug information about current configuration
  Map<String, dynamic> getDebugInfo();
}

/// Concrete implementation of grid configuration repository
class GridConfigurationRepository implements IGridConfigurationRepository {
  GridDimensions _currentLevel = GridConfigConstants.defaultGameplayBounds; // ✅ FIXED

  // Cache for loaded level configurations
  final Map<String, GridDimensions> _levelCache = {};

  @override
  GridDimensions getVisualDimensions() {
    return GridConfigConstants.visualDimensions;
  }

  @override
  GridDimensions getDefaultGameplayBounds() {
    return GridConfigConstants.defaultGameplayBounds;
  }

  @override
  GridDimensions getCurrentLevelBounds() {
    return _currentLevel;
  }

  @override
  Future<void> loadLevelBounds(String levelId) async {
    StructuredLogger.info('Loading level bounds for level: $levelId', context: {
      'levelId': levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    try {
      // Check cache first
      if (_levelCache.containsKey(levelId)) {
        _currentLevel = _levelCache[levelId]!;
        StructuredLogger.debug('Using cached level bounds', context: {
          'levelId': levelId,
          'cachedBounds': _currentLevel.toString(),
        });
        return;
      }

      // Load level file from assets (implementation simplified)
      try {
        final levelJsonString = await rootBundle.loadString('assets/levels/$levelId/level.json');

        if (levelJsonString.isEmpty) {
          StructuredLogger.warning('Level file is empty, using defaults', context: {
            'levelId': levelId,
          });
          _currentLevel = getDefaultGameplayBounds();
          return;
        }

        final levelData = jsonDecode(levelJsonString) as Map<String, dynamic>;
        final gridData = levelData['grid'] as Map<String, dynamic>?;
        if (gridData != null) {
          _currentLevel = GridDimensions.fromLevel(gridData);
          _levelCache[levelId] = _currentLevel;

          StructuredLogger.info('Successfully loaded level bounds', context: {
            'levelId': levelId,
            'visualBounds': getVisualDimensions().toString(),
            'gameplayBounds': _currentLevel.toString(),
            'usingLevelOverride': gridData['width'] != null,
          });
        } else {
          _currentLevel = getDefaultGameplayBounds();
          _levelCache[levelId] = _currentLevel;
        }
      } catch (e) {
        StructuredLogger.warning('Could not load level file, using defaults', context: {
          'levelId': levelId,
          'error': e.toString(),
        });
        _currentLevel = getDefaultGameplayBounds();
        _levelCache[levelId] = _currentLevel;
      }

    } catch (e, stackTrace) {
      StructuredLogger.error('Failed to load level bounds, using defaults', context: {
        'levelId': levelId,
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      }, error: e);
      _currentLevel = getDefaultGameplayBounds();
      _levelCache[levelId] = _currentLevel;
    }
  }

  @override
  void resetToDefaults() {
    _currentLevel = getDefaultGameplayBounds();
    StructuredLogger.info('Grid configuration reset to defaults', context: {
      'newBounds': _currentLevel.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Map<String, dynamic> getDebugInfo() {
    return {
      'visualDimensions': getVisualDimensions().toString(),
      'currentLevelBounds': _currentLevel.toString(),
      'defaultGameplayBounds': getDefaultGameplayBounds().toString(),
      'levelCache': _levelCache.map((key, value) => MapEntry(key, value.toString())),
      'configConstants': GridConfigConstants.getDebugInfo(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}