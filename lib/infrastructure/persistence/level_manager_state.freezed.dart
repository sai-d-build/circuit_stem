// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level_manager_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LevelManagerState {
  List<LevelMetadata> get levels => throw _privateConstructorUsedError;
  Set<String> get completedLevelIds => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  LevelDefinition? get currentLevelDefinition =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of LevelManagerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LevelManagerStateCopyWith<LevelManagerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LevelManagerStateCopyWith<$Res> {
  factory $LevelManagerStateCopyWith(
          LevelManagerState value, $Res Function(LevelManagerState) then) =
      _$LevelManagerStateCopyWithImpl<$Res, LevelManagerState>;
  @useResult
  $Res call(
      {List<LevelMetadata> levels,
      Set<String> completedLevelIds,
      bool isLoading,
      LevelDefinition? currentLevelDefinition,
      String? errorMessage});

  $LevelDefinitionCopyWith<$Res>? get currentLevelDefinition;
}

/// @nodoc
class _$LevelManagerStateCopyWithImpl<$Res, $Val extends LevelManagerState>
    implements $LevelManagerStateCopyWith<$Res> {
  _$LevelManagerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LevelManagerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? levels = null,
    Object? completedLevelIds = null,
    Object? isLoading = null,
    Object? currentLevelDefinition = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      levels: null == levels
          ? _value.levels
          : levels // ignore: cast_nullable_to_non_nullable
              as List<LevelMetadata>,
      completedLevelIds: null == completedLevelIds
          ? _value.completedLevelIds
          : completedLevelIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevelDefinition: freezed == currentLevelDefinition
          ? _value.currentLevelDefinition
          : currentLevelDefinition // ignore: cast_nullable_to_non_nullable
              as LevelDefinition?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of LevelManagerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LevelDefinitionCopyWith<$Res>? get currentLevelDefinition {
    if (_value.currentLevelDefinition == null) {
      return null;
    }

    return $LevelDefinitionCopyWith<$Res>(_value.currentLevelDefinition!,
        (value) {
      return _then(_value.copyWith(currentLevelDefinition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LevelManagerStateImplCopyWith<$Res>
    implements $LevelManagerStateCopyWith<$Res> {
  factory _$$LevelManagerStateImplCopyWith(_$LevelManagerStateImpl value,
          $Res Function(_$LevelManagerStateImpl) then) =
      __$$LevelManagerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LevelMetadata> levels,
      Set<String> completedLevelIds,
      bool isLoading,
      LevelDefinition? currentLevelDefinition,
      String? errorMessage});

  @override
  $LevelDefinitionCopyWith<$Res>? get currentLevelDefinition;
}

/// @nodoc
class __$$LevelManagerStateImplCopyWithImpl<$Res>
    extends _$LevelManagerStateCopyWithImpl<$Res, _$LevelManagerStateImpl>
    implements _$$LevelManagerStateImplCopyWith<$Res> {
  __$$LevelManagerStateImplCopyWithImpl(_$LevelManagerStateImpl _value,
      $Res Function(_$LevelManagerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LevelManagerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? levels = null,
    Object? completedLevelIds = null,
    Object? isLoading = null,
    Object? currentLevelDefinition = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$LevelManagerStateImpl(
      levels: null == levels
          ? _value._levels
          : levels // ignore: cast_nullable_to_non_nullable
              as List<LevelMetadata>,
      completedLevelIds: null == completedLevelIds
          ? _value._completedLevelIds
          : completedLevelIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevelDefinition: freezed == currentLevelDefinition
          ? _value.currentLevelDefinition
          : currentLevelDefinition // ignore: cast_nullable_to_non_nullable
              as LevelDefinition?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LevelManagerStateImpl implements _LevelManagerState {
  const _$LevelManagerStateImpl(
      {final List<LevelMetadata> levels = const [],
      final Set<String> completedLevelIds = const {},
      this.isLoading = true,
      this.currentLevelDefinition,
      this.errorMessage})
      : _levels = levels,
        _completedLevelIds = completedLevelIds;

  final List<LevelMetadata> _levels;
  @override
  @JsonKey()
  List<LevelMetadata> get levels {
    if (_levels is EqualUnmodifiableListView) return _levels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_levels);
  }

  final Set<String> _completedLevelIds;
  @override
  @JsonKey()
  Set<String> get completedLevelIds {
    if (_completedLevelIds is EqualUnmodifiableSetView)
      return _completedLevelIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_completedLevelIds);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final LevelDefinition? currentLevelDefinition;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'LevelManagerState(levels: $levels, completedLevelIds: $completedLevelIds, isLoading: $isLoading, currentLevelDefinition: $currentLevelDefinition, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LevelManagerStateImpl &&
            const DeepCollectionEquality().equals(other._levels, _levels) &&
            const DeepCollectionEquality()
                .equals(other._completedLevelIds, _completedLevelIds) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.currentLevelDefinition, currentLevelDefinition) ||
                other.currentLevelDefinition == currentLevelDefinition) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_levels),
      const DeepCollectionEquality().hash(_completedLevelIds),
      isLoading,
      currentLevelDefinition,
      errorMessage);

  /// Create a copy of LevelManagerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LevelManagerStateImplCopyWith<_$LevelManagerStateImpl> get copyWith =>
      __$$LevelManagerStateImplCopyWithImpl<_$LevelManagerStateImpl>(
          this, _$identity);
}

abstract class _LevelManagerState implements LevelManagerState {
  const factory _LevelManagerState(
      {final List<LevelMetadata> levels,
      final Set<String> completedLevelIds,
      final bool isLoading,
      final LevelDefinition? currentLevelDefinition,
      final String? errorMessage}) = _$LevelManagerStateImpl;

  @override
  List<LevelMetadata> get levels;
  @override
  Set<String> get completedLevelIds;
  @override
  bool get isLoading;
  @override
  LevelDefinition? get currentLevelDefinition;
  @override
  String? get errorMessage;

  /// Create a copy of LevelManagerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LevelManagerStateImplCopyWith<_$LevelManagerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
