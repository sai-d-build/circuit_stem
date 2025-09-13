import 'package:shared_preferences/shared_preferences.dart';

import '../../common/logger.dart';

/// Simple level info for the system
class SimpleLevelInfo {
  final String id;
  final String title;
  final String description;
  final int levelNumber;

  const SimpleLevelInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.levelNumber,
  });
}

/// Service for managing level progression and unlocking
class LevelSystem {
  final SharedPreferences _prefs;

  LevelSystem(this._prefs);

  /// Get all available levels
  List<SimpleLevelInfo> getAvailableLevels() {
    // Return a list of available levels
    return [
      const SimpleLevelInfo(
        id: 'tutorial_1',
        title: 'Basic Tutorial',
        description: 'Learn the basics of circuit building',
        levelNumber: 1,
      ),
      const SimpleLevelInfo(
        id: 'basic_1',
        title: 'Series Circuits',
        description: 'Master series circuit connections',
        levelNumber: 2,
      ),
    ];
  }

  /// Get completed levels
  List<SimpleLevelInfo> getCompletedLevels() {
    final completedIds = _prefs.getStringList('completed_levels') ?? [];
    return getAvailableLevels()
        .where((level) => completedIds.contains(level.id))
        .toList();
  }

  /// Check if a level is unlocked
  bool isLevelUnlocked(String levelId) {
    final unlockedIds = _prefs.getStringList('unlocked_levels') ?? [];
    return unlockedIds.contains(levelId);
  }

  /// Mark a level as completed
  Future<void> completeLevel(String levelId) async {
    final completed = _prefs.getStringList('completed_levels') ?? [];
    if (!completed.contains(levelId)) {
      completed.add(levelId);
      await _prefs.setStringList('completed_levels', completed);
      Logger.log('LevelSystem: Completed level $levelId');
    }
  }

  /// Get level progress
  Map<String, dynamic> getLevelProgress(String levelId) {
    final progressKey = 'progress_$levelId';
    final progressJson = _prefs.getString(progressKey);
    if (progressJson != null) {
      try {
        return {}; // Parse JSON in real implementation
      } catch (e) {
        Logger.log('LevelSystem: Error parsing progress for $levelId: $e');
      }
    }
    return {};
  }

  /// Save level progress
  Future<void> saveLevelProgress(
      String levelId, Map<String, dynamic> progress) async {
    // final progressKey = 'progress_$levelId';
    // Save progress as JSON string in real implementation
    Logger.log('LevelSystem: Saved progress for level $levelId');
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    final keys = _prefs.getKeys().where(
        (key) => key.startsWith('progress_') || key == 'completed_levels');
    for (final key in keys) {
      await _prefs.remove(key);
    }
    Logger.log('LevelSystem: Reset all progress');
  }
}
