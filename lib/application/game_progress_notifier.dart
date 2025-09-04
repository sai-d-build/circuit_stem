import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

/// Represents game progress data
class GameProgress {
  final int currentLevel;
  final Set<int> completedLevels;
  final Map<int, int> levelStars;
  final Map<int, Duration> levelTimes;
  final DateTime lastPlayed;
  final int totalScore;
  final LevelDefinition? level;
  final bool isWinConditionMet;

  GameProgress({
    this.currentLevel = 1,
    Set<int>? completedLevels,
    Map<int, int>? levelStars,
    Map<int, Duration>? levelTimes,
    DateTime? lastPlayed,
    this.totalScore = 0,
    this.level,
    this.isWinConditionMet = false,
  }) :
    completedLevels = completedLevels ?? {},
    levelStars = levelStars ?? {},
    levelTimes = levelTimes ?? {},
    lastPlayed = lastPlayed ?? DateTime.now();

  GameProgress copyWith({
    int? currentLevel,
    Set<int>? completedLevels,
    Map<int, int>? levelStars,
    Map<int, Duration>? levelTimes,
    DateTime? lastPlayed,
    int? totalScore,
    LevelDefinition? level,
    bool? isWinConditionMet,
  }) {
    return GameProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      completedLevels: completedLevels ?? this.completedLevels,
      levelStars: levelStars ?? this.levelStars,
      levelTimes: levelTimes ?? this.levelTimes,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      totalScore: totalScore ?? this.totalScore,
      level: level ?? this.level,
      isWinConditionMet: isWinConditionMet ?? this.isWinConditionMet,
    );
  }
}

/// Notifier for managing game progress
class GameProgressNotifier extends StateNotifier<GameProgress> {
  GameProgressNotifier() : super(GameProgress());

  /// Update current level
  void setCurrentLevel(int level, LevelDefinition levelDefinition) {
    state = state.copyWith(currentLevel: level, level: levelDefinition, lastPlayed: DateTime.now());
    Logger.log('Progress: Set current level to $level');
  }

  /// Mark level as completed with stars
  void completeLevel(int level, int stars, Duration time) {
    final newCompleted = Set<int>.from(state.completedLevels)..add(level);
    final newStars = Map<int, int>.from(state.levelStars)..[level] = stars;
    final newTimes = Map<int, Duration>.from(state.levelTimes)..[level] = time;
    final newScore = state.totalScore + (stars * 100);

    state = state.copyWith(
      completedLevels: newCompleted,
      levelStars: newStars,
      levelTimes: newTimes,
      totalScore: newScore,
      lastPlayed: DateTime.now(),
    );

    Logger.log('Progress: Completed level $level with $stars stars in ${time.inSeconds}s');
  }

  /// Check if level is completed
  bool isLevelCompleted(int level) => state.completedLevels.contains(level);

  /// Get stars for level
  int getLevelStars(int level) => state.levelStars[level] ?? 0;

  /// Get completion percentage
  double getCompletionPercentage(int totalLevels) {
    if (totalLevels == 0) return 0.0;
    return (state.completedLevels.length / totalLevels) * 100.0;
  }

  /// Reset progress
  void resetProgress() {
        state = GameProgress();
    Logger.log('Progress: Reset all progress');
  }

  /// Get current state (for V2 API compatibility)
  GameProgress get current => state;

  /// Set state directly (for V2 API compatibility)
  void setState(GameProgress newState) {
    state = newState;
    Logger.log('Progress: State set directly - level ${newState.currentLevel}');
  }

  /// Toggle pause state (for V2 API compatibility)
  void togglePause() {
    final newState = state.copyWith(lastPlayed: DateTime.now());
    state = newState;
    Logger.log('Progress: Pause toggled');
  }

  /// Set win state (for V2 API compatibility)
  void setWinState(bool isWin) {
    if (isWin) {
      Logger.log('Progress: Win state set');
    }
    // Additional win state logic can be added here if needed
  }
}

// Provider for GameProgressNotifier
final gameProgressNotifierProvider = StateNotifierProvider<GameProgressNotifier, GameProgress>((ref) {
  return GameProgressNotifier();
});
