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

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  int? get xp => throw _privateConstructorUsedError;
  int? get level => throw _privateConstructorUsedError;
  List<String>? get unlockedComponents => throw _privateConstructorUsedError;
  List<String>? get completedLevels => throw _privateConstructorUsedError;
  Map<String, dynamic>? get preferences => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

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
      {String id,
      String? uid,
      String username,
      String email,
      String? displayName,
      String? photoUrl,
      DateTime? createdAt,
      DateTime? lastLoginAt,
      int? xp,
      int? level,
      List<String>? unlockedComponents,
      List<String>? completedLevels,
      Map<String, dynamic>? preferences});
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
    Object? id = null,
    Object? uid = freezed,
    Object? username = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
    Object? xp = freezed,
    Object? level = freezed,
    Object? unlockedComponents = freezed,
    Object? completedLevels = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
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
      xp: freezed == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int?,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int?,
      unlockedComponents: freezed == unlockedComponents
          ? _value.unlockedComponents
          : unlockedComponents // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      completedLevels: freezed == completedLevels
          ? _value.completedLevels
          : completedLevels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
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
      {String id,
      String? uid,
      String username,
      String email,
      String? displayName,
      String? photoUrl,
      DateTime? createdAt,
      DateTime? lastLoginAt,
      int? xp,
      int? level,
      List<String>? unlockedComponents,
      List<String>? completedLevels,
      Map<String, dynamic>? preferences});
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
    Object? id = null,
    Object? uid = freezed,
    Object? username = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
    Object? xp = freezed,
    Object? level = freezed,
    Object? unlockedComponents = freezed,
    Object? completedLevels = freezed,
    Object? preferences = freezed,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
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
      xp: freezed == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int?,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int?,
      unlockedComponents: freezed == unlockedComponents
          ? _value._unlockedComponents
          : unlockedComponents // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      completedLevels: freezed == completedLevels
          ? _value._completedLevels
          : completedLevels // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      preferences: freezed == preferences
          ? _value._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      this.uid,
      required this.username,
      required this.email,
      this.displayName,
      this.photoUrl,
      this.createdAt,
      this.lastLoginAt,
      this.xp,
      this.level,
      final List<String>? unlockedComponents,
      final List<String>? completedLevels,
      final Map<String, dynamic>? preferences})
      : _unlockedComponents = unlockedComponents,
        _completedLevels = completedLevels,
        _preferences = preferences;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String? uid;
  @override
  final String username;
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
  final int? xp;
  @override
  final int? level;
  final List<String>? _unlockedComponents;
  @override
  List<String>? get unlockedComponents {
    final value = _unlockedComponents;
    if (value == null) return null;
    if (_unlockedComponents is EqualUnmodifiableListView)
      return _unlockedComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _completedLevels;
  @override
  List<String>? get completedLevels {
    final value = _completedLevels;
    if (value == null) return null;
    if (_completedLevels is EqualUnmodifiableListView) return _completedLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _preferences;
  @override
  Map<String, dynamic>? get preferences {
    final value = _preferences;
    if (value == null) return null;
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'User(id: $id, uid: $uid, username: $username, email: $email, displayName: $displayName, photoUrl: $photoUrl, createdAt: $createdAt, lastLoginAt: $lastLoginAt, xp: $xp, level: $level, unlockedComponents: $unlockedComponents, completedLevels: $completedLevels, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality()
                .equals(other._unlockedComponents, _unlockedComponents) &&
            const DeepCollectionEquality()
                .equals(other._completedLevels, _completedLevels) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uid,
      username,
      email,
      displayName,
      photoUrl,
      createdAt,
      lastLoginAt,
      xp,
      level,
      const DeepCollectionEquality().hash(_unlockedComponents),
      const DeepCollectionEquality().hash(_completedLevels),
      const DeepCollectionEquality().hash(_preferences));

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String id,
      final String? uid,
      required final String username,
      required final String email,
      final String? displayName,
      final String? photoUrl,
      final DateTime? createdAt,
      final DateTime? lastLoginAt,
      final int? xp,
      final int? level,
      final List<String>? unlockedComponents,
      final List<String>? completedLevels,
      final Map<String, dynamic>? preferences}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String? get uid;
  @override
  String get username;
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
  int? get xp;
  @override
  int? get level;
  @override
  List<String>? get unlockedComponents;
  @override
  List<String>? get completedLevels;
  @override
  Map<String, dynamic>? get preferences;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  bool get soundEnabled => throw _privateConstructorUsedError;
  double? get musicVolume => throw _privateConstructorUsedError;
  double? get soundVolume => throw _privateConstructorUsedError;
  String? get theme => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  bool? get hapticFeedback => throw _privateConstructorUsedError;
  bool? get showHints => throw _privateConstructorUsedError;
  bool? get developerMode => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

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
      double? musicVolume,
      double? soundVolume,
      String? theme,
      String? language,
      bool? hapticFeedback,
      bool? showHints,
      bool? developerMode});
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
    Object? musicVolume = freezed,
    Object? soundVolume = freezed,
    Object? theme = freezed,
    Object? language = freezed,
    Object? hapticFeedback = freezed,
    Object? showHints = freezed,
    Object? developerMode = freezed,
  }) {
    return _then(_value.copyWith(
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      musicVolume: freezed == musicVolume
          ? _value.musicVolume
          : musicVolume // ignore: cast_nullable_to_non_nullable
              as double?,
      soundVolume: freezed == soundVolume
          ? _value.soundVolume
          : soundVolume // ignore: cast_nullable_to_non_nullable
              as double?,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      hapticFeedback: freezed == hapticFeedback
          ? _value.hapticFeedback
          : hapticFeedback // ignore: cast_nullable_to_non_nullable
              as bool?,
      showHints: freezed == showHints
          ? _value.showHints
          : showHints // ignore: cast_nullable_to_non_nullable
              as bool?,
      developerMode: freezed == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool?,
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
      double? musicVolume,
      double? soundVolume,
      String? theme,
      String? language,
      bool? hapticFeedback,
      bool? showHints,
      bool? developerMode});
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
    Object? musicVolume = freezed,
    Object? soundVolume = freezed,
    Object? theme = freezed,
    Object? language = freezed,
    Object? hapticFeedback = freezed,
    Object? showHints = freezed,
    Object? developerMode = freezed,
  }) {
    return _then(_$UserPreferencesImpl(
      soundEnabled: null == soundEnabled
          ? _value.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      musicVolume: freezed == musicVolume
          ? _value.musicVolume
          : musicVolume // ignore: cast_nullable_to_non_nullable
              as double?,
      soundVolume: freezed == soundVolume
          ? _value.soundVolume
          : soundVolume // ignore: cast_nullable_to_non_nullable
              as double?,
      theme: freezed == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      hapticFeedback: freezed == hapticFeedback
          ? _value.hapticFeedback
          : hapticFeedback // ignore: cast_nullable_to_non_nullable
              as bool?,
      showHints: freezed == showHints
          ? _value.showHints
          : showHints // ignore: cast_nullable_to_non_nullable
              as bool?,
      developerMode: freezed == developerMode
          ? _value.developerMode
          : developerMode // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {required this.soundEnabled,
      this.musicVolume,
      this.soundVolume,
      this.theme,
      this.language,
      this.hapticFeedback,
      this.showHints,
      this.developerMode});

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  final bool soundEnabled;
  @override
  final double? musicVolume;
  @override
  final double? soundVolume;
  @override
  final String? theme;
  @override
  final String? language;
  @override
  final bool? hapticFeedback;
  @override
  final bool? showHints;
  @override
  final bool? developerMode;

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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {required final bool soundEnabled,
      final double? musicVolume,
      final double? soundVolume,
      final String? theme,
      final String? language,
      final bool? hapticFeedback,
      final bool? showHints,
      final bool? developerMode}) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  bool get soundEnabled;
  @override
  double? get musicVolume;
  @override
  double? get soundVolume;
  @override
  String? get theme;
  @override
  String? get language;
  @override
  bool? get hapticFeedback;
  @override
  bool? get showHints;
  @override
  bool? get developerMode;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStats _$UserStatsFromJson(Map<String, dynamic> json) {
  return _UserStats.fromJson(json);
}

/// @nodoc
mixin _$UserStats {
  int get levelsCompleted => throw _privateConstructorUsedError;
  int? get totalScore => throw _privateConstructorUsedError;
  int? get totalPlayTime => throw _privateConstructorUsedError;
  int? get currentStreak => throw _privateConstructorUsedError;
  int? get longestStreak => throw _privateConstructorUsedError;
  List<String>? get achievements => throw _privateConstructorUsedError;
  List<String>? get unlockedComponents => throw _privateConstructorUsedError;
  DateTime? get firstPlayDate => throw _privateConstructorUsedError;
  DateTime? get lastPlayDate => throw _privateConstructorUsedError;

  /// Serializes this UserStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

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
      int? totalScore,
      int? totalPlayTime,
      int? currentStreak,
      int? longestStreak,
      List<String>? achievements,
      List<String>? unlockedComponents,
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
    Object? totalScore = freezed,
    Object? totalPlayTime = freezed,
    Object? currentStreak = freezed,
    Object? longestStreak = freezed,
    Object? achievements = freezed,
    Object? unlockedComponents = freezed,
    Object? firstPlayDate = freezed,
    Object? lastPlayDate = freezed,
  }) {
    return _then(_value.copyWith(
      levelsCompleted: null == levelsCompleted
          ? _value.levelsCompleted
          : levelsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalScore: freezed == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPlayTime: freezed == totalPlayTime
          ? _value.totalPlayTime
          : totalPlayTime // ignore: cast_nullable_to_non_nullable
              as int?,
      currentStreak: freezed == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int?,
      longestStreak: freezed == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int?,
      achievements: freezed == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      unlockedComponents: freezed == unlockedComponents
          ? _value.unlockedComponents
          : unlockedComponents // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
      int? totalScore,
      int? totalPlayTime,
      int? currentStreak,
      int? longestStreak,
      List<String>? achievements,
      List<String>? unlockedComponents,
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
    Object? totalScore = freezed,
    Object? totalPlayTime = freezed,
    Object? currentStreak = freezed,
    Object? longestStreak = freezed,
    Object? achievements = freezed,
    Object? unlockedComponents = freezed,
    Object? firstPlayDate = freezed,
    Object? lastPlayDate = freezed,
  }) {
    return _then(_$UserStatsImpl(
      levelsCompleted: null == levelsCompleted
          ? _value.levelsCompleted
          : levelsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalScore: freezed == totalScore
          ? _value.totalScore
          : totalScore // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPlayTime: freezed == totalPlayTime
          ? _value.totalPlayTime
          : totalPlayTime // ignore: cast_nullable_to_non_nullable
              as int?,
      currentStreak: freezed == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int?,
      longestStreak: freezed == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int?,
      achievements: freezed == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      unlockedComponents: freezed == unlockedComponents
          ? _value._unlockedComponents
          : unlockedComponents // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
@JsonSerializable()
class _$UserStatsImpl implements _UserStats {
  const _$UserStatsImpl(
      {required this.levelsCompleted,
      this.totalScore,
      this.totalPlayTime,
      this.currentStreak,
      this.longestStreak,
      final List<String>? achievements,
      final List<String>? unlockedComponents,
      this.firstPlayDate,
      this.lastPlayDate})
      : _achievements = achievements,
        _unlockedComponents = unlockedComponents;

  factory _$UserStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsImplFromJson(json);

  @override
  final int levelsCompleted;
  @override
  final int? totalScore;
  @override
  final int? totalPlayTime;
  @override
  final int? currentStreak;
  @override
  final int? longestStreak;
  final List<String>? _achievements;
  @override
  List<String>? get achievements {
    final value = _achievements;
    if (value == null) return null;
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _unlockedComponents;
  @override
  List<String>? get unlockedComponents {
    final value = _unlockedComponents;
    if (value == null) return null;
    if (_unlockedComponents is EqualUnmodifiableListView)
      return _unlockedComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsImplToJson(
      this,
    );
  }
}

abstract class _UserStats implements UserStats {
  const factory _UserStats(
      {required final int levelsCompleted,
      final int? totalScore,
      final int? totalPlayTime,
      final int? currentStreak,
      final int? longestStreak,
      final List<String>? achievements,
      final List<String>? unlockedComponents,
      final DateTime? firstPlayDate,
      final DateTime? lastPlayDate}) = _$UserStatsImpl;

  factory _UserStats.fromJson(Map<String, dynamic> json) =
      _$UserStatsImpl.fromJson;

  @override
  int get levelsCompleted;
  @override
  int? get totalScore;
  @override
  int? get totalPlayTime;
  @override
  int? get currentStreak;
  @override
  int? get longestStreak;
  @override
  List<String>? get achievements;
  @override
  List<String>? get unlockedComponents;
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
