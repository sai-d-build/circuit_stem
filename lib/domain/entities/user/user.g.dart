// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map json) => $checkedCreate(
      r'_$UserImpl',
      json,
      ($checkedConvert) {
        final val = _$UserImpl(
          id: $checkedConvert('id', (v) => v as String),
          uid: $checkedConvert('uid', (v) => v as String?),
          username: $checkedConvert('username', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          displayName: $checkedConvert('displayName', (v) => v as String?),
          photoUrl: $checkedConvert('photoUrl', (v) => v as String?),
          createdAt: $checkedConvert('createdAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          lastLoginAt: $checkedConvert('lastLoginAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
          xp: $checkedConvert('xp', (v) => (v as num?)?.toInt()),
          level: $checkedConvert('level', (v) => (v as num?)?.toInt()),
          unlockedComponents: $checkedConvert('unlockedComponents',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          completedLevels: $checkedConvert('completedLevels',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          preferences: $checkedConvert(
              'preferences',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'username': instance.username,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'xp': instance.xp,
      'level': instance.level,
      'unlockedComponents': instance.unlockedComponents,
      'completedLevels': instance.completedLevels,
      'preferences': instance.preferences,
    };

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(Map json) =>
    $checkedCreate(
      r'_$UserPreferencesImpl',
      json,
      ($checkedConvert) {
        final val = _$UserPreferencesImpl(
          soundEnabled: $checkedConvert('soundEnabled', (v) => v as bool),
          musicVolume:
              $checkedConvert('musicVolume', (v) => (v as num?)?.toDouble()),
          soundVolume:
              $checkedConvert('soundVolume', (v) => (v as num?)?.toDouble()),
          theme: $checkedConvert('theme', (v) => v as String?),
          language: $checkedConvert('language', (v) => v as String?),
          hapticFeedback: $checkedConvert('hapticFeedback', (v) => v as bool?),
          showHints: $checkedConvert('showHints', (v) => v as bool?),
          developerMode: $checkedConvert('developerMode', (v) => v as bool?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'soundEnabled': instance.soundEnabled,
      'musicVolume': instance.musicVolume,
      'soundVolume': instance.soundVolume,
      'theme': instance.theme,
      'language': instance.language,
      'hapticFeedback': instance.hapticFeedback,
      'showHints': instance.showHints,
      'developerMode': instance.developerMode,
    };

_$UserStatsImpl _$$UserStatsImplFromJson(Map json) => $checkedCreate(
      r'_$UserStatsImpl',
      json,
      ($checkedConvert) {
        final val = _$UserStatsImpl(
          levelsCompleted:
              $checkedConvert('levelsCompleted', (v) => (v as num).toInt()),
          totalScore:
              $checkedConvert('totalScore', (v) => (v as num?)?.toInt()),
          totalPlayTime:
              $checkedConvert('totalPlayTime', (v) => (v as num?)?.toInt()),
          currentStreak:
              $checkedConvert('currentStreak', (v) => (v as num?)?.toInt()),
          longestStreak:
              $checkedConvert('longestStreak', (v) => (v as num?)?.toInt()),
          achievements: $checkedConvert('achievements',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          unlockedComponents: $checkedConvert('unlockedComponents',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          firstPlayDate: $checkedConvert('firstPlayDate',
              (v) => v == null ? null : DateTime.parse(v as String)),
          lastPlayDate: $checkedConvert('lastPlayDate',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'levelsCompleted': instance.levelsCompleted,
      'totalScore': instance.totalScore,
      'totalPlayTime': instance.totalPlayTime,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'achievements': instance.achievements,
      'unlockedComponents': instance.unlockedComponents,
      'firstPlayDate': instance.firstPlayDate?.toIso8601String(),
      'lastPlayDate': instance.lastPlayDate?.toIso8601String(),
    };
