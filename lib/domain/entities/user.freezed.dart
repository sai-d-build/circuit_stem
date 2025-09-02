// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$User {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  UserPreferences? get preferences => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String uid,
      String email,
      String? displayName,
      String? photoUrl,
      DateTime? createdAt,
      DateTime? lastLoginAt,
      UserPreferences? preferences});

  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
    ) as $Val);
  }

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $UserPreferencesCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      String? displayName,
      String? photoUrl,
      DateTime? createdAt,
      DateTime? lastLoginAt,
      UserPreferences? preferences});

  @override
  $UserPreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_$UserImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences?,
    ));
  }
}

/// @nodoc

class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.uid,
      required this.email,
      this.displayName,
      this.photoUrl,
      this.createdAt,
      this.lastLoginAt,
      this.preferences});

  @override
  final String uid;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastLoginAt;
  @override
  final UserPreferences? preferences;

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, createdAt: $createdAt, lastLoginAt: $lastLoginAt, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences));
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid, email, displayName,
      photoUrl, createdAt, lastLoginAt, preferences);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);
}

abstract class _User implements User {
  const factory _User(
      {required final String uid,
      required final String email,
      final String? displayName,
      final String? photoUrl,
      final DateTime? createdAt,
      final DateTime? lastLoginAt,
      final UserPreferences? preferences}) = _$UserImpl;

  @override
  String get uid;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get photoUrl;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastLoginAt;
  @override
  UserPreferences? get preferences;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserPreferences {
  bool get soundEnabled => throw _privateConstructorUsedError;
  double get musicVolume => throw _privateConstructorUsedError;
  double get soundVolume => throw _privateConstructorUsedError;
  String? get theme => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  bool get hapticFeedback => throw _privateConstructorUsedError;
  bool get showHints => throw _privateConstructorUsedError;
  bool get developerMode => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {bool soundEnabled,
      double musicVolume,
      double soundVolume,
      String? theme,
      String? language,
      bool hapticFeedback,
      bool showHints,
      bool developerMode});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soundEnabled = null,
    Object? musicVolume = null,
    Object? soundVolume = null,
    Object? theme = freezed,
    Object? language = freezed,
    Object? hapticFeedback = null,
    Object? showHints = null,
    Object? developerMode = null,
  }) {
    return _then(_value.copyWith(
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      musicVolume: null == musicVolume
          ? _value.musicVolume
          : musicVolume // ignore: cast_nullable_to_non_nullable
              as double,
      soundVolume: null == soundVolume
          ? _value.soundVolume
          : soundVolume // ignore: cast_nullable_to_non_nullable
              as double,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      hapticFeedback: null == hapticFeedback
          ? _value.hapticFeedback
          : hapticFeedback // ignore: cast_nullable_to_non_nullable
              as bool,
      showHints: null == showHints
          ? _value.showHints
          : showHints // ignore: cast_nullable_to_non_nullable
              as bool,
      developerMode: null == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool soundEnabled,
      double musicVolume,
      double soundVolume,
      String? theme,
      String? language,
      bool hapticFeedback,
      bool showHints,
      bool developerMode});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? soundEnabled = null,
    Object? musicVolume = null,
    Object? soundVolume = null,
    Object? theme = freezed,
    Object? language = freezed,
    Object? hapticFeedback = null,
    Object? showHints = null,
    Object? developerMode = null,
  }) {
    return _then(_$UserPreferencesImpl(
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      musicVolume: null == musicVolume
          ? _value.musicVolume
          : musicVolume // ignore: cast_nullable_to_non_nullable
              as double,
      soundVolume: null == soundVolume
          ? _value.soundVolume
          : soundVolume // ignore: cast_nullable_to_non_nullable
              as double,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      hapticFeedback: null == hapticFeedback
          ? _value.hapticFeedback
          : hapticFeedback // ignore: cast_nullable_to_non_nullable
              as bool,
      showHints: null == showHints
          ? _value.showHints
          : showHints // ignore: cast_nullable_to_non_nullable
              as bool,
      developerMode: null == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {this.soundEnabled = true,
      this.musicVolume = 0.5,
      this.soundVolume = 1.0,
      this.theme,
      this.language,
      this.hapticFeedback = false,
      this.showHints = true,
      this.developerMode = false});

  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final double musicVolume;
  @override
  @JsonKey()
  final double soundVolume;
  @override
  final String? theme;
  @override
  final String? language;
  @override
  @JsonKey()
  final bool hapticFeedback;
  @override
  @JsonKey()
  final bool showHints;
  @override
  @JsonKey()
  final bool developerMode;

  @override
  String toString() {
    return 'UserPreferences(soundEnabled: $soundEnabled, musicVolume: $musicVolume, soundVolume: $soundVolume, theme: $theme, language: $language, hapticFeedback: $hapticFeedback, showHints: $showHints, developerMode: $developerMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.musicVolume, musicVolume) ||
                other.musicVolume == musicVolume) &&
            (identical(other.soundVolume, soundVolume) ||
                other.soundVolume == soundVolume) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.hapticFeedback, hapticFeedback) ||
                other.hapticFeedback == hapticFeedback) &&
            (identical(other.showHints, showHints) ||
                other.showHints == showHints) &&
            (identical(other.developerMode, developerMode) ||
                other.developerMode == developerMode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, soundEnabled, musicVolume,
      soundVolume, theme, language, hapticFeedback, showHints, developerMode);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {final bool soundEnabled,
      final double musicVolume,
      final double soundVolume,
      final String? theme,
      final String? language,
      final bool hapticFeedback,
      final bool showHints,
      final bool developerMode}) = _$UserPreferencesImpl;

  @override
  bool get soundEnabled;
  @override
  double get musicVolume;
  @override
  double get soundVolume;
  @override
  String? get theme;
  @override
  String? get language;
  @override
  bool get hapticFeedback;
  @override
  bool get showHints;
  @override
  bool get developerMode;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserStats {
  int get levelsCompleted => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  int get totalPlayTime => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  List<String> get achievements => throw _privateConstructorUsedError;
  List<String> get unlockedComponents => throw _privateConstructorUsedError;
  DateTime? get firstPlayDate => throw _privateConstructorUsedError;
  DateTime? get lastPlayDate => throw _privateConstructorUsedError;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatsCopyWith<UserStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsCopyWith<$Res> {
  factory $UserStatsCopyWith(UserStats value, $Res Function(UserStats) then) =
      _$UserStatsCopyWithImpl<$Res, UserStats>;
  @useResult
  $Res call(
      {int levelsCompleted,
      int totalScore,
      int totalPlayTime,
      int currentStreak,
      int longestStreak,
      List<String> achievements,
      List<String> unlockedComponents,
      DateTime? firstPlayDate,
      DateTime? lastPlayDate});
}

/// @nodoc
class _$UserStatsCopyWithImpl<$Res, $Val extends UserStats>
    implements $UserStatsCopyWith<$Res> {
  _$UserStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? levelsCompleted = null,
    Object? totalScore = null,
    Object? totalPlayTime = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? achievements = null,
    Object? unlockedComponents = null,
    Object? firstPlayDate = freezed,
    Object? lastPlayDate = freezed,
  }) {
    return _then(_value.copyWith(
      levelsCompleted: null == levelsCompleted
          ? _value.levelsCompleted
          : levelsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalScore: null == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as int,
      totalPlayTime: null == totalPlayTime
          ? _value.totalPlayTime
          : totalPlayTime // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unlockedComponents: null == unlockedComponents
          ? _value.unlockedComponents
          : unlockedComponents // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstPlayDate: freezed == firstPlayDate
          ? _value.firstPlayDate
          : firstPlayDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPlayDate: freezed == lastPlayDate
          ? _value.lastPlayDate
          : lastPlayDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStatsImplCopyWith<$Res>
    implements $UserStatsCopyWith<$Res> {
  factory _$$UserStatsImplCopyWith(
          _$UserStatsImpl value, $Res Function(_$UserStatsImpl) then) =
      __$$UserStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int levelsCompleted,
      int totalScore,
      int totalPlayTime,
      int currentStreak,
      int longestStreak,
      List<String> achievements,
      List<String> unlockedComponents,
      DateTime? firstPlayDate,
      DateTime? lastPlayDate});
}

/// @nodoc
class __$$UserStatsImplCopyWithImpl<$Res>
    extends _$UserStatsCopyWithImpl<$Res, _$UserStatsImpl>
    implements _$$UserStatsImplCopyWith<$Res> {
  __$$UserStatsImplCopyWithImpl(
      _$UserStatsImpl _value, $Res Function(_$UserStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? levelsCompleted = null,
    Object? totalScore = null,
    Object? totalPlayTime = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? achievements = null,
    Object? unlockedComponents = null,
    Object? firstPlayDate = freezed,
    Object? lastPlayDate = freezed,
  }) {
    return _then(_$UserStatsImpl(
      levelsCompleted: null == levelsCompleted
          ? _value.levelsCompleted
          : levelsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalScore: null == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as int,
      totalPlayTime: null == totalPlayTime
          ? _value.totalPlayTime
          : totalPlayTime // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unlockedComponents: null == unlockedComponents
          ? _value._unlockedComponents
          : unlockedComponents // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstPlayDate: freezed == firstPlayDate
          ? _value.firstPlayDate
          : firstPlayDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastPlayDate: freezed == lastPlayDate
          ? _value.lastPlayDate
          : lastPlayDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$UserStatsImpl implements _UserStats {
  const _$UserStatsImpl(
      {this.levelsCompleted = 0,
      this.totalScore = 0,
      this.totalPlayTime = 0,
      this.currentStreak = 0,
      this.longestStreak = 0,
      final List<String> achievements = const [],
      final List<String> unlockedComponents = const [],
      this.firstPlayDate,
      this.lastPlayDate})
      : _achievements = achievements,
        _unlockedComponents = unlockedComponents;

  @override
  @JsonKey()
  final int levelsCompleted;
  @override
  @JsonKey()
  final int totalScore;
  @override
  @JsonKey()
  final int totalPlayTime;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  final List<String> _achievements;
  @override
  @JsonKey()
  List<String> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  final List<String> _unlockedComponents;
  @override
  @JsonKey()
  List<String> get unlockedComponents {
    if (_unlockedComponents is EqualUnmodifiableListView)
      return _unlockedComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unlockedComponents);
  }

  @override
  final DateTime? firstPlayDate;
  @override
  final DateTime? lastPlayDate;

  @override
  String toString() {
    return 'UserStats(levelsCompleted: $levelsCompleted, totalScore: $totalScore, totalPlayTime: $totalPlayTime, currentStreak: $currentStreak, longestStreak: $longestStreak, achievements: $achievements, unlockedComponents: $unlockedComponents, firstPlayDate: $firstPlayDate, lastPlayDate: $lastPlayDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsImpl &&
            (identical(other.levelsCompleted, levelsCompleted) ||
                other.levelsCompleted == levelsCompleted) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.totalPlayTime, totalPlayTime) ||
                other.totalPlayTime == totalPlayTime) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements) &&
            const DeepCollectionEquality()
                .equals(other._unlockedComponents, _unlockedComponents) &&
            (identical(other.firstPlayDate, firstPlayDate) ||
                other.firstPlayDate == firstPlayDate) &&
            (identical(other.lastPlayDate, lastPlayDate) ||
                other.lastPlayDate == lastPlayDate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      levelsCompleted,
      totalScore,
      totalPlayTime,
      currentStreak,
      longestStreak,
      const DeepCollectionEquality().hash(_achievements),
      const DeepCollectionEquality().hash(_unlockedComponents),
      firstPlayDate,
      lastPlayDate);

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      __$$UserStatsImplCopyWithImpl<_$UserStatsImpl>(this, _$identity);
}

abstract class _UserStats implements UserStats {
  const factory _UserStats(
      {final int levelsCompleted,
      final int totalScore,
      final int totalPlayTime,
      final int currentStreak,
      final int longestStreak,
      final List<String> achievements,
      final List<String> unlockedComponents,
      final DateTime? firstPlayDate,
      final DateTime? lastPlayDate}) = _$UserStatsImpl;

  @override
  int get levelsCompleted;
  @override
  int get totalScore;
  @override
  int get totalPlayTime;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  List<String> get achievements;
  @override
  List<String> get unlockedComponents;
  @override
  DateTime? get firstPlayDate;
  @override
  DateTime? get lastPlayDate;

  /// Create a copy of UserStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Achievement {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int? get points => throw _privateConstructorUsedError;
  Map<String, dynamic>? get requirements => throw _privateConstructorUsedError;
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String icon,
      String category,
      int? points,
      Map<String, dynamic>? requirements,
      DateTime? unlockedAt});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? category = null,
    Object? points = freezed,
    Object? requirements = freezed,
    Object? unlockedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      points: freezed == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int?,
      requirements: freezed == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String icon,
      String category,
      int? points,
      Map<String, dynamic>? requirements,
      DateTime? unlockedAt});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? category = null,
    Object? points = freezed,
    Object? requirements = freezed,
    Object? unlockedAt = freezed,
  }) {
    return _then(_$AchievementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      points: freezed == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int?,
      requirements: freezed == requirements
          ? _value._requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.icon,
      required this.category,
      this.points,
      final Map<String, dynamic>? requirements,
      this.unlockedAt})
      : _requirements = requirements;

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String icon;
  @override
  final String category;
  @override
  final int? points;
  final Map<String, dynamic>? _requirements;
  @override
  Map<String, dynamic>? get requirements {
    final value = _requirements;
    if (value == null) return null;
    if (_requirements is EqualUnmodifiableMapView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, icon: $icon, category: $category, points: $points, requirements: $requirements, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.points, points) || other.points == points) &&
            const DeepCollectionEquality()
                .equals(other._requirements, _requirements) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      icon,
      category,
      points,
      const DeepCollectionEquality().hash(_requirements),
      unlockedAt);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);
}

abstract class _Achievement implements Achievement {
  const factory _Achievement(
      {required final String id,
      required final String title,
      required final String description,
      required final String icon,
      required final String category,
      final int? points,
      final Map<String, dynamic>? requirements,
      final DateTime? unlockedAt}) = _$AchievementImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get icon;
  @override
  String get category;
  @override
  int? get points;
  @override
  Map<String, dynamic>? get requirements;
  @override
  DateTime? get unlockedAt;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
