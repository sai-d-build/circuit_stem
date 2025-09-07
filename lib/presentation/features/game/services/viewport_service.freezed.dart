// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'viewport_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ViewportState {
  double get scale => throw _privateConstructorUsedError;
  Offset get panOffset => throw _privateConstructorUsedError;
  Size get canvasSize => throw _privateConstructorUsedError;
  Size get gridConfiguration => throw _privateConstructorUsedError;
  double get cellSize => throw _privateConstructorUsedError;

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ViewportStateCopyWith<ViewportState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewportStateCopyWith<$Res> {
  factory $ViewportStateCopyWith(
          ViewportState value, $Res Function(ViewportState) then) =
      _$ViewportStateCopyWithImpl<$Res, ViewportState>;
  @useResult
  $Res call(
      {double scale,
      Offset panOffset,
      Size canvasSize,
      Size gridConfiguration,
      double cellSize});
}

/// @nodoc
class _$ViewportStateCopyWithImpl<$Res, $Val extends ViewportState>
    implements $ViewportStateCopyWith<$Res> {
  _$ViewportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scale = null,
    Object? panOffset = null,
    Object? canvasSize = null,
    Object? gridConfiguration = null,
    Object? cellSize = null,
  }) {
    return _then(_value.copyWith(
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
      panOffset: null == panOffset
          ? _value.panOffset
          : panOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      canvasSize: null == canvasSize
          ? _value.canvasSize
          : canvasSize // ignore: cast_nullable_to_non_nullable
              as Size,
      gridConfiguration: null == gridConfiguration
          ? _value.gridConfiguration
          : gridConfiguration // ignore: cast_nullable_to_non_nullable
              as Size,
      cellSize: null == cellSize
          ? _value.cellSize
          : cellSize // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewportStateImplCopyWith<$Res>
    implements $ViewportStateCopyWith<$Res> {
  factory _$$ViewportStateImplCopyWith(
          _$ViewportStateImpl value, $Res Function(_$ViewportStateImpl) then) =
      __$$ViewportStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double scale,
      Offset panOffset,
      Size canvasSize,
      Size gridConfiguration,
      double cellSize});
}

/// @nodoc
class __$$ViewportStateImplCopyWithImpl<$Res>
    extends _$ViewportStateCopyWithImpl<$Res, _$ViewportStateImpl>
    implements _$$ViewportStateImplCopyWith<$Res> {
  __$$ViewportStateImplCopyWithImpl(
      _$ViewportStateImpl _value, $Res Function(_$ViewportStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scale = null,
    Object? panOffset = null,
    Object? canvasSize = null,
    Object? gridConfiguration = null,
    Object? cellSize = null,
  }) {
    return _then(_$ViewportStateImpl(
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
      panOffset: null == panOffset
          ? _value.panOffset
          : panOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      canvasSize: null == canvasSize
          ? _value.canvasSize
          : canvasSize // ignore: cast_nullable_to_non_nullable
              as Size,
      gridConfiguration: null == gridConfiguration
          ? _value.gridConfiguration
          : gridConfiguration // ignore: cast_nullable_to_non_nullable
              as Size,
      cellSize: null == cellSize
          ? _value.cellSize
          : cellSize // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$ViewportStateImpl implements _ViewportState {
  const _$ViewportStateImpl(
      {this.scale = 1.0,
      this.panOffset = Offset.zero,
      this.canvasSize = Size.zero,
      this.gridConfiguration = const Size(20, 15),
      this.cellSize = 60.0});

  @override
  @JsonKey()
  final double scale;
  @override
  @JsonKey()
  final Offset panOffset;
  @override
  @JsonKey()
  final Size canvasSize;
  @override
  @JsonKey()
  final Size gridConfiguration;
  @override
  @JsonKey()
  final double cellSize;

  @override
  String toString() {
    return 'ViewportState(scale: $scale, panOffset: $panOffset, canvasSize: $canvasSize, gridConfiguration: $gridConfiguration, cellSize: $cellSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewportStateImpl &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.panOffset, panOffset) ||
                other.panOffset == panOffset) &&
            (identical(other.canvasSize, canvasSize) ||
                other.canvasSize == canvasSize) &&
            (identical(other.gridConfiguration, gridConfiguration) ||
                other.gridConfiguration == gridConfiguration) &&
            (identical(other.cellSize, cellSize) ||
                other.cellSize == cellSize));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, scale, panOffset, canvasSize, gridConfiguration, cellSize);

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewportStateImplCopyWith<_$ViewportStateImpl> get copyWith =>
      __$$ViewportStateImplCopyWithImpl<_$ViewportStateImpl>(this, _$identity);
}

abstract class _ViewportState implements ViewportState {
  const factory _ViewportState(
      {final double scale,
      final Offset panOffset,
      final Size canvasSize,
      final Size gridConfiguration,
      final double cellSize}) = _$ViewportStateImpl;

  @override
  double get scale;
  @override
  Offset get panOffset;
  @override
  Size get canvasSize;
  @override
  Size get gridConfiguration;
  @override
  double get cellSize;

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ViewportStateImplCopyWith<_$ViewportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
