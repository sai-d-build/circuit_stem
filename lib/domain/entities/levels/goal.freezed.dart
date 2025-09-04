// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LevelGoal _$LevelGoalFromJson(Map<String, dynamic> json) {
  return _LevelGoal.fromJson(json);
}

/// @nodoc
mixin _$LevelGoal {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conditions => throw _privateConstructorUsedError;
  int? get timeLimit => throw _privateConstructorUsedError;
  List<Hint>? get hints => throw _privateConstructorUsedError;

  /// Serializes this LevelGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelGoalCopyWith<LevelGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelGoalCopyWith<$Res> {
  factory $LevelGoalCopyWith(LevelGoal value, $Res Function(LevelGoal) then) =
      _$LevelGoalCopyWithImpl<$Res, LevelGoal>;
  @useResult
  $Res call(
      {String id,
      String type,
      String? description,
      Map<String, dynamic>? conditions,
      int? timeLimit,
      List<Hint>? hints});
}

/// @nodoc
class _$LevelGoalCopyWithImpl<$Res, $Val extends LevelGoal>
    implements $LevelGoalCopyWith<$Res> {
  _$LevelGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = freezed,
    Object? conditions = freezed,
    Object? timeLimit = freezed,
    Object? hints = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      conditions: freezed == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      hints: freezed == hints
          ? _value.hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<Hint>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LevelGoalImplCopyWith<$Res>
    implements $LevelGoalCopyWith<$Res> {
  factory _$$LevelGoalImplCopyWith(
          _$LevelGoalImpl value, $Res Function(_$LevelGoalImpl) then) =
      __$$LevelGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String? description,
      Map<String, dynamic>? conditions,
      int? timeLimit,
      List<Hint>? hints});
}

/// @nodoc
class __$$LevelGoalImplCopyWithImpl<$Res>
    extends _$LevelGoalCopyWithImpl<$Res, _$LevelGoalImpl>
    implements _$$LevelGoalImplCopyWith<$Res> {
  __$$LevelGoalImplCopyWithImpl(
      _$LevelGoalImpl _value, $Res Function(_$LevelGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? description = freezed,
    Object? conditions = freezed,
    Object? timeLimit = freezed,
    Object? hints = freezed,
  }) {
    return _then(_$LevelGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      conditions: freezed == conditions
          ? _value._conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      hints: freezed == hints
          ? _value._hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<Hint>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LevelGoalImpl implements _LevelGoal {
  const _$LevelGoalImpl(
      {required this.id,
      required this.type,
      this.description,
      final Map<String, dynamic>? conditions,
      this.timeLimit,
      final List<Hint>? hints})
      : _conditions = conditions,
        _hints = hints;

  factory _$LevelGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$LevelGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String? description;
  final Map<String, dynamic>? _conditions;
  @override
  Map<String, dynamic>? get conditions {
    final value = _conditions;
    if (value == null) return null;
    if (_conditions is EqualUnmodifiableMapView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? timeLimit;
  final List<Hint>? _hints;
  @override
  List<Hint>? get hints {
    final value = _hints;
    if (value == null) return null;
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LevelGoal(id: $id, type: $type, description: $description, conditions: $conditions, timeLimit: $timeLimit, hints: $hints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._conditions, _conditions) &&
            (identical(other.timeLimit, timeLimit) ||
                other.timeLimit == timeLimit) &&
            const DeepCollectionEquality().equals(other._hints, _hints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      description,
      const DeepCollectionEquality().hash(_conditions),
      timeLimit,
      const DeepCollectionEquality().hash(_hints));

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelGoalImplCopyWith<_$LevelGoalImpl> get copyWith =>
      __$$LevelGoalImplCopyWithImpl<_$LevelGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LevelGoalImplToJson(
      this,
    );
  }
}

abstract class _LevelGoal implements LevelGoal {
  const factory _LevelGoal(
      {required final String id,
      required final String type,
      final String? description,
      final Map<String, dynamic>? conditions,
      final int? timeLimit,
      final List<Hint>? hints}) = _$LevelGoalImpl;

  factory _LevelGoal.fromJson(Map<String, dynamic> json) =
      _$LevelGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get conditions;
  @override
  int? get timeLimit;
  @override
  List<Hint>? get hints;

  /// Create a copy of LevelGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelGoalImplCopyWith<_$LevelGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
