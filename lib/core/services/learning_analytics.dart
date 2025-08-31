import 'package:shared_preferences/shared_preferences.dart';
import '../../common/logger.dart';

/// Service for tracking learning analytics and user progress
class LearningAnalytics {
  final SharedPreferences _prefs;

  LearningAnalytics(this._prefs);

  /// Track user interaction
  Future<void> trackInteraction(String interactionType, Map<String, dynamic> data) async {
    Logger.log('LearningAnalytics: Tracking interaction $interactionType');

    // Store interaction data (simplified implementation)
    final interactions = _prefs.getStringList('user_interactions') ?? [];
    interactions.add('$interactionType:${DateTime.now().toIso8601String()}');

    // Keep only last 100 interactions
    if (interactions.length > 100) {
      interactions.removeRange(0, interactions.length - 100);
    }

    await _prefs.setStringList('user_interactions', interactions);
  }

  /// Track level completion
  Future<void> trackLevelCompletion(String levelId, Duration timeSpent, bool success) async {
    Logger.log('LearningAnalytics: Level $levelId completed in ${timeSpent.inSeconds}s, success: $success');

    // Store completion data
    final completions = _prefs.getStringList('level_completions') ?? [];
    completions.add('$levelId:${timeSpent.inSeconds}:$success:${DateTime.now().toIso8601String()}');

    await _prefs.setStringList('level_completions', completions);
  }

  /// Get learning statistics
  Map<String, dynamic> getLearningStatistics() {
    final interactions = _prefs.getStringList('user_interactions') ?? [];
    final completions = _prefs.getStringList('level_completions') ?? [];

    return {
      'totalInteractions': interactions.length,
      'totalCompletions': completions.length,
      'averageSessionTime': _calculateAverageSessionTime(completions),
      'successRate': _calculateSuccessRate(completions),
    };
  }

  /// Get user learning progress
  Map<String, dynamic> getLearningProgress() {
    return {
      'skillLevel': _estimateSkillLevel(),
      'learningObjectives': _getLearningObjectivesProgress(),
      'recommendedActivities': _getRecommendedActivities(),
    };
  }

  double _calculateAverageSessionTime(List<String> completions) {
    if (completions.isEmpty) return 0.0;

    int totalTime = 0;
    for (final completion in completions) {
      final parts = completion.split(':');
      if (parts.length >= 2) {
        totalTime += int.tryParse(parts[1]) ?? 0;
      }
    }

    return totalTime / completions.length;
  }

  double _calculateSuccessRate(List<String> completions) {
    if (completions.isEmpty) return 0.0;

    int successful = 0;
    for (final completion in completions) {
      final parts = completion.split(':');
      if (parts.length >= 3 && parts[2] == 'true') {
        successful++;
      }
    }

    return successful / completions.length;
  }

  String _estimateSkillLevel() {
    final stats = getLearningStatistics();
    final successRate = stats['successRate'] as double;

    if (successRate > 0.8) return 'Advanced';
    if (successRate > 0.6) return 'Intermediate';
    return 'Beginner';
  }

  List<String> _getLearningObjectivesProgress() {
    // Simplified implementation
    return [
      'Basic circuit concepts: Completed',
      'Series circuits: In Progress',
      'Parallel circuits: Not Started',
    ];
  }

  List<String> _getRecommendedActivities() {
    // Simplified implementation
    return [
      'Practice series circuit connections',
      'Try the parallel circuits tutorial',
      'Complete the switches level',
    ];
  }
}