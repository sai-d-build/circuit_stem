import 'package:shared_preferences/shared_preferences.dart';
import '../../common/logger.dart';

/// Simple achievement data
class SimpleAchievement {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;

  const SimpleAchievement({
    required this.id,
    required this.title,
    required this.description,
    this.isUnlocked = false,
  });
}

/// Service for managing achievements and badges
class AchievementSystem {
  final SharedPreferences _prefs;

  AchievementSystem(this._prefs);

  /// Get all achievements
  List<SimpleAchievement> getAllAchievements() {
    final unlockedIds = _prefs.getStringList('unlocked_achievements') ?? [];

    return [
      SimpleAchievement(
        id: 'first_circuit',
        title: 'First Circuit',
        description: 'Complete your first circuit',
        isUnlocked: unlockedIds.contains('first_circuit'),
      ),
      SimpleAchievement(
        id: 'series_master',
        title: 'Series Master',
        description: 'Master series circuit connections',
        isUnlocked: unlockedIds.contains('series_master'),
      ),
    ];
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String achievementId) async {
    final unlocked = _prefs.getStringList('unlocked_achievements') ?? [];
    if (!unlocked.contains(achievementId)) {
      unlocked.add(achievementId);
      await _prefs.setStringList('unlocked_achievements', unlocked);
      Logger.log('AchievementSystem: Unlocked achievement $achievementId');
    }
  }

  /// Check if achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    final unlocked = _prefs.getStringList('unlocked_achievements') ?? [];
    return unlocked.contains(achievementId);
  }

  /// Get achievement progress
  Map<String, dynamic> getAchievementProgress(String achievementId) {
    // Simple implementation - could be expanded
    return {
      'unlocked': isAchievementUnlocked(achievementId),
      'progress': isAchievementUnlocked(achievementId) ? 1.0 : 0.0,
    };
  }
}