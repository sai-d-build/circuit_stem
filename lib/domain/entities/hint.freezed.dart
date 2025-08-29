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
  String get type => throw _privateConstructorUsedError;
  List<Position>? get path => throw _privateConstructorUsedError;

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
  $Res call({String type, List<Position>? path});
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
    Object? type = null,
    Object? path = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as List<Position>?,
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
  $Res call({String type, List<Position>? path});
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
    Object? type = null,
    Object? path = freezed,
  }) {
    return _then(_$HintImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _value._path
          : path // ignore: cast_nullable_to_non_nullable
              as List<Position>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HintImpl implements _Hint {
  const _$HintImpl({required this.type, final List<Position>? path})
      : _path = path;

  factory _$HintImpl.fromJson(Map<String, dynamic> json) =>
      _$$HintImplFromJson(json);

  @override
  final String type;
  final List<Position>? _path;
  @override
  List<Position>? get path {
    final value = _path;
    if (value == null) return null;
    if (_path is EqualUnmodifiableListView) return _path;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Hint(type: $type, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HintImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._path, _path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(_path));

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
      {required final String type, final List<Position>? path}) = _$HintImpl;

  factory _Hint.fromJson(Map<String, dynamic> json) = _$HintImpl.fromJson;

  @override
  String get type;
  @override
  List<Position>? get path;

  /// Create a copy of Hint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HintImplCopyWith<_$HintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
