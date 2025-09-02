// lib/domain/entities/user.dart
// User domain entity for SparkCircuit

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
  }) = _User;

  
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool soundEnabled,
    @Default(0.5) double musicVolume,
    @Default(1.0) double soundVolume,
    String? theme,
    String? language,
    @Default(false) bool hapticFeedback,
    @Default(true) bool showHints,
    @Default(false) bool developerMode,
  }) = _UserPreferences;

  
}

// User statistics for achievements and analytics
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int levelsCompleted,
    @Default(0) int totalScore,
    @Default(0) int totalPlayTime,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default([]) List<String> achievements,
    @Default([]) List<String> unlockedComponents,
    DateTime? firstPlayDate,
    DateTime? lastPlayDate,
  }) = _UserStats;

  
}

// Achievement definition
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String icon,
    required String category,
    int? points,
    Map<String, dynamic>? requirements,
    DateTime? unlockedAt,
  }) = _Achievement;

  
}