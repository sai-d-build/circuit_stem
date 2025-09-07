// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coordinate_system_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CoordinateContext {
  Size get gridDimensions => throw _privateConstructorUsedError;
  double get cellSize => throw _privateConstructorUsedError;
  double get scale => throw _privateConstructorUsedError;
  Offset get panOffset => throw _privateConstructorUsedError;
  Size get canvasSize => throw _privateConstructorUsedError;
  double get devicePixelRatio => throw _privateConstructorUsedError;
  Rect? get viewportBounds => throw _privateConstructorUsedError;
  EdgeInsets get padding => throw _privateConstructorUsedError;

  /// Create a copy of CoordinateContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoordinateContextCopyWith<CoordinateContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoordinateContextCopyWith<$Res> {
  factory $CoordinateContextCopyWith(
          CoordinateContext value, $Res Function(CoordinateContext) then) =
      _$CoordinateContextCopyWithImpl<$Res, CoordinateContext>;
  @useResult
  $Res call(
      {Size gridDimensions,
      double cellSize,
      double scale,
      Offset panOffset,
      Size canvasSize,
      double devicePixelRatio,
      Rect? viewportBounds,
      EdgeInsets padding});
}

/// @nodoc
class _$CoordinateContextCopyWithImpl<$Res, $Val extends CoordinateContext>
    implements $CoordinateContextCopyWith<$Res> {
  _$CoordinateContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoordinateContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gridDimensions = null,
    Object? cellSize = null,
    Object? scale = null,
    Object? panOffset = null,
    Object? canvasSize = null,
    Object? devicePixelRatio = null,
    Object? viewportBounds = freezed,
    Object? padding = null,
  }) {
    return _then(_value.copyWith(
      gridDimensions: null == gridDimensions
          ? _value.gridDimensions
          : gridDimensions // ignore: cast_nullable_to_non_nullable
              as Size,
      cellSize: null == cellSize
          ? _value.cellSize
          : cellSize // ignore: cast_nullable_to_non_nullable
              as double,
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
      devicePixelRatio: null == devicePixelRatio
          ? _value.devicePixelRatio
          : devicePixelRatio // ignore: cast_nullable_to_non_nullable
              as double,
      viewportBounds: freezed == viewportBounds
          ? _value.viewportBounds
          : viewportBounds // ignore: cast_nullable_to_non_nullable
              as Rect?,
      padding: null == padding
          ? _value.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoordinateContextImplCopyWith<$Res>
    implements $CoordinateContextCopyWith<$Res> {
  factory _$$CoordinateContextImplCopyWith(_$CoordinateContextImpl value,
          $Res Function(_$CoordinateContextImpl) then) =
      __$$CoordinateContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Size gridDimensions,
      double cellSize,
      double scale,
      Offset panOffset,
      Size canvasSize,
      double devicePixelRatio,
      Rect? viewportBounds,
      EdgeInsets padding});
}

/// @nodoc
class __$$CoordinateContextImplCopyWithImpl<$Res>
    extends _$CoordinateContextCopyWithImpl<$Res, _$CoordinateContextImpl>
    implements _$$CoordinateContextImplCopyWith<$Res> {
  __$$CoordinateContextImplCopyWithImpl(_$CoordinateContextImpl _value,
      $Res Function(_$CoordinateContextImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoordinateContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gridDimensions = null,
    Object? cellSize = null,
    Object? scale = null,
    Object? panOffset = null,
    Object? canvasSize = null,
    Object? devicePixelRatio = null,
    Object? viewportBounds = freezed,
    Object? padding = null,
  }) {
    return _then(_$CoordinateContextImpl(
      gridDimensions: null == gridDimensions
          ? _value.gridDimensions
          : gridDimensions // ignore: cast_nullable_to_non_nullable
              as Size,
      cellSize: null == cellSize
          ? _value.cellSize
          : cellSize // ignore: cast_nullable_to_non_nullable
              as double,
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
      devicePixelRatio: null == devicePixelRatio
          ? _value.devicePixelRatio
          : devicePixelRatio // ignore: cast_nullable_to_non_nullable
              as double,
      viewportBounds: freezed == viewportBounds
          ? _value.viewportBounds
          : viewportBounds // ignore: cast_nullable_to_non_nullable
              as Rect?,
      padding: null == padding
          ? _value.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
    ));
  }
}

/// @nodoc

class _$CoordinateContextImpl
    with DiagnosticableTreeMixin
    implements _CoordinateContext {
  const _$CoordinateContextImpl(
      {required this.gridDimensions,
      required this.cellSize,
      required this.scale,
      required this.panOffset,
      required this.canvasSize,
      required this.devicePixelRatio,
      this.viewportBounds,
      this.padding = EdgeInsets.zero});

  @override
  final Size gridDimensions;
  @override
  final double cellSize;
  @override
  final double scale;
  @override
  final Offset panOffset;
  @override
  final Size canvasSize;
  @override
  final double devicePixelRatio;
  @override
  final Rect? viewportBounds;
  @override
  @JsonKey()
  final EdgeInsets padding;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CoordinateContext(gridDimensions: $gridDimensions, cellSize: $cellSize, scale: $scale, panOffset: $panOffset, canvasSize: $canvasSize, devicePixelRatio: $devicePixelRatio, viewportBounds: $viewportBounds, padding: $padding)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CoordinateContext'))
      ..add(DiagnosticsProperty('gridDimensions', gridDimensions))
      ..add(DiagnosticsProperty('cellSize', cellSize))
      ..add(DiagnosticsProperty('scale', scale))
      ..add(DiagnosticsProperty('panOffset', panOffset))
      ..add(DiagnosticsProperty('canvasSize', canvasSize))
      ..add(DiagnosticsProperty('devicePixelRatio', devicePixelRatio))
      ..add(DiagnosticsProperty('viewportBounds', viewportBounds))
      ..add(DiagnosticsProperty('padding', padding));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoordinateContextImpl &&
            (identical(other.gridDimensions, gridDimensions) ||
                other.gridDimensions == gridDimensions) &&
            (identical(other.cellSize, cellSize) ||
                other.cellSize == cellSize) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.panOffset, panOffset) ||
                other.panOffset == panOffset) &&
            (identical(other.canvasSize, canvasSize) ||
                other.canvasSize == canvasSize) &&
            (identical(other.devicePixelRatio, devicePixelRatio) ||
                other.devicePixelRatio == devicePixelRatio) &&
            (identical(other.viewportBounds, viewportBounds) ||
                other.viewportBounds == viewportBounds) &&
            (identical(other.padding, padding) || other.padding == padding));
  }

  @override
  int get hashCode => Object.hash(runtimeType, gridDimensions, cellSize, scale,
      panOffset, canvasSize, devicePixelRatio, viewportBounds, padding);

  /// Create a copy of CoordinateContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoordinateContextImplCopyWith<_$CoordinateContextImpl> get copyWith =>
      __$$CoordinateContextImplCopyWithImpl<_$CoordinateContextImpl>(
          this, _$identity);
}

abstract class _CoordinateContext implements CoordinateContext {
  const factory _CoordinateContext(
      {required final Size gridDimensions,
      required final double cellSize,
      required final double scale,
      required final Offset panOffset,
      required final Size canvasSize,
      required final double devicePixelRatio,
      final Rect? viewportBounds,
      final EdgeInsets padding}) = _$CoordinateContextImpl;

  @override
  Size get gridDimensions;
  @override
  double get cellSize;
  @override
  double get scale;
  @override
  Offset get panOffset;
  @override
  Size get canvasSize;
  @override
  double get devicePixelRatio;
  @override
  Rect? get viewportBounds;
  @override
  EdgeInsets get padding;

  /// Create a copy of CoordinateContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoordinateContextImplCopyWith<_$CoordinateContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GridPosition {
  int get row => throw _privateConstructorUsedError;
  int get col => throw _privateConstructorUsedError;

  /// Create a copy of GridPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GridPositionCopyWith<GridPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GridPositionCopyWith<$Res> {
  factory $GridPositionCopyWith(
          GridPosition value, $Res Function(GridPosition) then) =
      _$GridPositionCopyWithImpl<$Res, GridPosition>;
  @useResult
  $Res call({int row, int col});
}

/// @nodoc
class _$GridPositionCopyWithImpl<$Res, $Val extends GridPosition>
    implements $GridPositionCopyWith<$Res> {
  _$GridPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GridPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? col = null,
  }) {
    return _then(_value.copyWith(
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GridPositionImplCopyWith<$Res>
    implements $GridPositionCopyWith<$Res> {
  factory _$$GridPositionImplCopyWith(
          _$GridPositionImpl value, $Res Function(_$GridPositionImpl) then) =
      __$$GridPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int row, int col});
}

/// @nodoc
class __$$GridPositionImplCopyWithImpl<$Res>
    extends _$GridPositionCopyWithImpl<$Res, _$GridPositionImpl>
    implements _$$GridPositionImplCopyWith<$Res> {
  __$$GridPositionImplCopyWithImpl(
      _$GridPositionImpl _value, $Res Function(_$GridPositionImpl) _then)
      : super(_value, _then);

  /// Create a copy of GridPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? col = null,
  }) {
    return _then(_$GridPositionImpl(
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$GridPositionImpl extends _GridPosition with DiagnosticableTreeMixin {
  const _$GridPositionImpl({required this.row, required this.col}) : super._();

  @override
  final int row;
  @override
  final int col;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GridPosition(row: $row, col: $col)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GridPosition'))
      ..add(DiagnosticsProperty('row', row))
      ..add(DiagnosticsProperty('col', col));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridPositionImpl &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.col, col) || other.col == col));
  }

  @override
  int get hashCode => Object.hash(runtimeType, row, col);

  /// Create a copy of GridPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridPositionImplCopyWith<_$GridPositionImpl> get copyWith =>
      __$$GridPositionImplCopyWithImpl<_$GridPositionImpl>(this, _$identity);
}

abstract class _GridPosition extends GridPosition {
  const factory _GridPosition(
      {required final int row, required final int col}) = _$GridPositionImpl;
  const _GridPosition._() : super._();

  @override
  int get row;
  @override
  int get col;

  /// Create a copy of GridPosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridPositionImplCopyWith<_$GridPositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CoordinateValidationResult {
  bool get isValid => throw _privateConstructorUsedError;
  GridPosition? get gridPosition => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  ValidationLevel get level => throw _privateConstructorUsedError;

  /// Create a copy of CoordinateValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoordinateValidationResultCopyWith<CoordinateValidationResult>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoordinateValidationResultCopyWith<$Res> {
  factory $CoordinateValidationResultCopyWith(CoordinateValidationResult value,
          $Res Function(CoordinateValidationResult) then) =
      _$CoordinateValidationResultCopyWithImpl<$Res,
          CoordinateValidationResult>;
  @useResult
  $Res call(
      {bool isValid,
      GridPosition? gridPosition,
      String? errorMessage,
      List<String> warnings,
      ValidationLevel level});

  $GridPositionCopyWith<$Res>? get gridPosition;
}

/// @nodoc
class _$CoordinateValidationResultCopyWithImpl<$Res,
        $Val extends CoordinateValidationResult>
    implements $CoordinateValidationResultCopyWith<$Res> {
  _$CoordinateValidationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoordinateValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? gridPosition = freezed,
    Object? errorMessage = freezed,
    Object? warnings = null,
    Object? level = null,
  }) {
    return _then(_value.copyWith(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      gridPosition: freezed == gridPosition
          ? _value.gridPosition
          : gridPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as ValidationLevel,
    ) as $Val);
  }

  /// Create a copy of CoordinateValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridPositionCopyWith<$Res>? get gridPosition {
    if (_value.gridPosition == null) {
      return null;
    }

    return $GridPositionCopyWith<$Res>(_value.gridPosition!, (value) {
      return _then(_value.copyWith(gridPosition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoordinateValidationResultImplCopyWith<$Res>
    implements $CoordinateValidationResultCopyWith<$Res> {
  factory _$$CoordinateValidationResultImplCopyWith(
          _$CoordinateValidationResultImpl value,
          $Res Function(_$CoordinateValidationResultImpl) then) =
      __$$CoordinateValidationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isValid,
      GridPosition? gridPosition,
      String? errorMessage,
      List<String> warnings,
      ValidationLevel level});

  @override
  $GridPositionCopyWith<$Res>? get gridPosition;
}

/// @nodoc
class __$$CoordinateValidationResultImplCopyWithImpl<$Res>
    extends _$CoordinateValidationResultCopyWithImpl<$Res,
        _$CoordinateValidationResultImpl>
    implements _$$CoordinateValidationResultImplCopyWith<$Res> {
  __$$CoordinateValidationResultImplCopyWithImpl(
      _$CoordinateValidationResultImpl _value,
      $Res Function(_$CoordinateValidationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoordinateValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isValid = null,
    Object? gridPosition = freezed,
    Object? errorMessage = freezed,
    Object? warnings = null,
    Object? level = null,
  }) {
    return _then(_$CoordinateValidationResultImpl(
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      gridPosition: freezed == gridPosition
          ? _value.gridPosition
          : gridPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      warnings: null == warnings
          ? _value._warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as ValidationLevel,
    ));
  }
}

/// @nodoc

class _$CoordinateValidationResultImpl
    with DiagnosticableTreeMixin
    implements _CoordinateValidationResult {
  const _$CoordinateValidationResultImpl(
      {required this.isValid,
      this.gridPosition,
      this.errorMessage,
      final List<String> warnings = const [],
      this.level = ValidationLevel.info})
      : _warnings = warnings;

  @override
  final bool isValid;
  @override
  final GridPosition? gridPosition;
  @override
  final String? errorMessage;
  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  @override
  @JsonKey()
  final ValidationLevel level;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CoordinateValidationResult(isValid: $isValid, gridPosition: $gridPosition, errorMessage: $errorMessage, warnings: $warnings, level: $level)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CoordinateValidationResult'))
      ..add(DiagnosticsProperty('isValid', isValid))
      ..add(DiagnosticsProperty('gridPosition', gridPosition))
      ..add(DiagnosticsProperty('errorMessage', errorMessage))
      ..add(DiagnosticsProperty('warnings', warnings))
      ..add(DiagnosticsProperty('level', level));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoordinateValidationResultImpl &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.gridPosition, gridPosition) ||
                other.gridPosition == gridPosition) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.level, level) || other.level == level));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isValid, gridPosition,
      errorMessage, const DeepCollectionEquality().hash(_warnings), level);

  /// Create a copy of CoordinateValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoordinateValidationResultImplCopyWith<_$CoordinateValidationResultImpl>
      get copyWith => __$$CoordinateValidationResultImplCopyWithImpl<
          _$CoordinateValidationResultImpl>(this, _$identity);
}

abstract class _CoordinateValidationResult
    implements CoordinateValidationResult {
  const factory _CoordinateValidationResult(
      {required final bool isValid,
      final GridPosition? gridPosition,
      final String? errorMessage,
      final List<String> warnings,
      final ValidationLevel level}) = _$CoordinateValidationResultImpl;

  @override
  bool get isValid;
  @override
  GridPosition? get gridPosition;
  @override
  String? get errorMessage;
  @override
  List<String> get warnings;
  @override
  ValidationLevel get level;

  /// Create a copy of CoordinateValidationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoordinateValidationResultImplCopyWith<_$CoordinateValidationResultImpl>
      get copyWith => throw _privateConstructorUsedError;
}
