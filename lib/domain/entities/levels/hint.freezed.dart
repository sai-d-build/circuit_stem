// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Hint _$HintFromJson(Map<String, dynamic> json) {
  return _Hint.fromJson(json);
}

/// @nodoc
mixin _$Hint {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get trigger =>
      throw _privateConstructorUsedError; // e.g., "on_error", "on_timeout"
  dynamic get triggerValue => throw _privateConstructorUsedError;

  /// Serializes this Hint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HintCopyWith<Hint> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HintCopyWith<$Res> {
  factory $HintCopyWith(Hint value, $Res Function(Hint) then) =
      _$HintCopyWithImpl<$Res, Hint>;
  @useResult
  $Res call({String id, String text, String trigger, dynamic triggerValue});
}

/// @nodoc
class _$HintCopyWithImpl<$Res, $Val extends Hint>
    implements $HintCopyWith<$Res> {
  _$HintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? trigger = null,
    Object? triggerValue = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      trigger: null == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String,
      triggerValue: freezed == triggerValue
          ? _value.triggerValue
          : triggerValue // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HintImplCopyWith<$Res> implements $HintCopyWith<$Res> {
  factory _$$HintImplCopyWith(
          _$HintImpl value, $Res Function(_$HintImpl) then) =
      __$$HintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String text, String trigger, dynamic triggerValue});
}

/// @nodoc
class __$$HintImplCopyWithImpl<$Res>
    extends _$HintCopyWithImpl<$Res, _$HintImpl>
    implements _$$HintImplCopyWith<$Res> {
  __$$HintImplCopyWithImpl(_$HintImpl _value, $Res Function(_$HintImpl) _then)
      : super(_value, _then);

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? trigger = null,
    Object? triggerValue = freezed,
  }) {
    return _then(_$HintImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      trigger: null == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as String,
      triggerValue: freezed == triggerValue
          ? _value.triggerValue
          : triggerValue // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HintImpl implements _Hint {
  const _$HintImpl(
      {required this.id,
      required this.text,
      required this.trigger,
      this.triggerValue});

  factory _$HintImpl.fromJson(Map<String, dynamic> json) =>
      _$$HintImplFromJson(json);

  @override
  final String id;
  @override
  final String text;
  @override
  final String trigger;
// e.g., "on_error", "on_timeout"
  @override
  final dynamic triggerValue;

  @override
  String toString() {
    return 'Hint(id: $id, text: $text, trigger: $trigger, triggerValue: $triggerValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HintImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.trigger, trigger) || other.trigger == trigger) &&
            const DeepCollectionEquality()
                .equals(other.triggerValue, triggerValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, trigger,
      const DeepCollectionEquality().hash(triggerValue));

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HintImplCopyWith<_$HintImpl> get copyWith =>
      __$$HintImplCopyWithImpl<_$HintImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HintImplToJson(
      this,
    );
  }
}

abstract class _Hint implements Hint {
  const factory _Hint(
      {required final String id,
      required final String text,
      required final String trigger,
      final dynamic triggerValue}) = _$HintImpl;

  factory _Hint.fromJson(Map<String, dynamic> json) = _$HintImpl.fromJson;

  @override
  String get id;
  @override
  String get text;
  @override
  String get trigger; // e.g., "on_error", "on_timeout"
  @override
  dynamic get triggerValue;

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HintImplCopyWith<_$HintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
