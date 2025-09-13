import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    String? uid,
    required String username,
    required String email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? xp,
    int? level,
    List<String>? unlockedComponents,
    List<String>? completedLevels,
    Map<String, dynamic>? preferences,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required bool soundEnabled,
    double? musicVolume,
    double? soundVolume,
    String? theme,
    String? language,
    bool? hapticFeedback,
    bool? showHints,
    bool? developerMode,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required int levelsCompleted,
    int? totalScore,
    int? totalPlayTime,
    int? currentStreak,
    int? longestStreak,
    List<String>? achievements,
    List<String>? unlockedComponents,
    DateTime? firstPlayDate,
    DateTime? lastPlayDate,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}
