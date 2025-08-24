// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evaluation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EvaluationResult {
  List<String> get poweredComponents => throw _privateConstructorUsedError;
  List<String> get poweredComponentIds => throw _privateConstructorUsedError;
  bool get isShortCircuit => throw _privateConstructorUsedError;

  /// Create a copy of EvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EvaluationResultCopyWith<EvaluationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EvaluationResultCopyWith<$Res> {
  factory $EvaluationResultCopyWith(
          EvaluationResult value, $Res Function(EvaluationResult) then) =
      _$EvaluationResultCopyWithImpl<$Res, EvaluationResult>;
  @useResult
  $Res call(
      {List<String> poweredComponents,
      List<String> poweredComponentIds,
      bool isShortCircuit});
}

/// @nodoc
class _$EvaluationResultCopyWithImpl<$Res, $Val extends EvaluationResult>
    implements $EvaluationResultCopyWith<$Res> {
  _$EvaluationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poweredComponents = null,
    Object? poweredComponentIds = null,
    Object? isShortCircuit = null,
  }) {
    return _then(_value.copyWith(
      poweredComponents: null == poweredComponents
          ? _value.poweredComponents
          : poweredComponents // ignore: cast_nullable_to_non_nullable
              as List<String>,
      poweredComponentIds: null == poweredComponentIds
          ? _value.poweredComponentIds
          : poweredComponentIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isShortCircuit: null == isShortCircuit
          ? _value.isShortCircuit
          : isShortCircuit // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EvaluationResultImplCopyWith<$Res>
    implements $EvaluationResultCopyWith<$Res> {
  factory _$$EvaluationResultImplCopyWith(_$EvaluationResultImpl value,
          $Res Function(_$EvaluationResultImpl) then) =
      __$$EvaluationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> poweredComponents,
      List<String> poweredComponentIds,
      bool isShortCircuit});
}

/// @nodoc
class __$$EvaluationResultImplCopyWithImpl<$Res>
    extends _$EvaluationResultCopyWithImpl<$Res, _$EvaluationResultImpl>
    implements _$$EvaluationResultImplCopyWith<$Res> {
  __$$EvaluationResultImplCopyWithImpl(_$EvaluationResultImpl _value,
      $Res Function(_$EvaluationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of EvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? poweredComponents = null,
    Object? poweredComponentIds = null,
    Object? isShortCircuit = null,
  }) {
    return _then(_$EvaluationResultImpl(
      poweredComponents: null == poweredComponents
          ? _value._poweredComponents
          : poweredComponents // ignore: cast_nullable_to_non_nullable
              as List<String>,
      poweredComponentIds: null == poweredComponentIds
          ? _value._poweredComponentIds
          : poweredComponentIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isShortCircuit: null == isShortCircuit
          ? _value.isShortCircuit
          : isShortCircuit // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EvaluationResultImpl implements _EvaluationResult {
  const _$EvaluationResultImpl(
      {final List<String> poweredComponents = const [],
      final List<String> poweredComponentIds = const [],
      this.isShortCircuit = false})
      : _poweredComponents = poweredComponents,
        _poweredComponentIds = poweredComponentIds;

  final List<String> _poweredComponents;
  @override
  @JsonKey()
  List<String> get poweredComponents {
    if (_poweredComponents is EqualUnmodifiableListView)
      return _poweredComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_poweredComponents);
  }

  final List<String> _poweredComponentIds;
  @override
  @JsonKey()
  List<String> get poweredComponentIds {
    if (_poweredComponentIds is EqualUnmodifiableListView)
      return _poweredComponentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_poweredComponentIds);
  }

  @override
  @JsonKey()
  final bool isShortCircuit;

  @override
  String toString() {
    return 'EvaluationResult(poweredComponents: $poweredComponents, poweredComponentIds: $poweredComponentIds, isShortCircuit: $isShortCircuit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EvaluationResultImpl &&
            const DeepCollectionEquality()
                .equals(other._poweredComponents, _poweredComponents) &&
            const DeepCollectionEquality()
                .equals(other._poweredComponentIds, _poweredComponentIds) &&
            (identical(other.isShortCircuit, isShortCircuit) ||
                other.isShortCircuit == isShortCircuit));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_poweredComponents),
      const DeepCollectionEquality().hash(_poweredComponentIds),
      isShortCircuit);

  /// Create a copy of EvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EvaluationResultImplCopyWith<_$EvaluationResultImpl> get copyWith =>
      __$$EvaluationResultImplCopyWithImpl<_$EvaluationResultImpl>(
          this, _$identity);
}

abstract class _EvaluationResult implements EvaluationResult {
  const factory _EvaluationResult(
      {final List<String> poweredComponents,
      final List<String> poweredComponentIds,
      final bool isShortCircuit}) = _$EvaluationResultImpl;

  @override
  List<String> get poweredComponents;
  @override
  List<String> get poweredComponentIds;
  @override
  bool get isShortCircuit;

  /// Create a copy of EvaluationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EvaluationResultImplCopyWith<_$EvaluationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
