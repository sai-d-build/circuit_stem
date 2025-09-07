// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'canvas_interaction_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$InteractionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Offset startPosition, DragOrigin origin)
        dragStart,
    required TResult Function(Offset currentPosition) dragUpdate,
    required TResult Function(Offset endPosition) dragEnd,
    required TResult Function(Offset delta) gesturePan,
    required TResult Function(double scale) gestureScale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult? Function(Offset currentPosition)? dragUpdate,
    TResult? Function(Offset endPosition)? dragEnd,
    TResult? Function(Offset delta)? gesturePan,
    TResult? Function(double scale)? gestureScale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult Function(Offset currentPosition)? dragUpdate,
    TResult Function(Offset endPosition)? dragEnd,
    TResult Function(Offset delta)? gesturePan,
    TResult Function(double scale)? gestureScale,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DragStartEvent value) dragStart,
    required TResult Function(_DragUpdateEvent value) dragUpdate,
    required TResult Function(_DragEndEvent value) dragEnd,
    required TResult Function(_PanEvent value) gesturePan,
    required TResult Function(_ScaleEvent value) gestureScale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DragStartEvent value)? dragStart,
    TResult? Function(_DragUpdateEvent value)? dragUpdate,
    TResult? Function(_DragEndEvent value)? dragEnd,
    TResult? Function(_PanEvent value)? gesturePan,
    TResult? Function(_ScaleEvent value)? gestureScale,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DragStartEvent value)? dragStart,
    TResult Function(_DragUpdateEvent value)? dragUpdate,
    TResult Function(_DragEndEvent value)? dragEnd,
    TResult Function(_PanEvent value)? gesturePan,
    TResult Function(_ScaleEvent value)? gestureScale,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InteractionEventCopyWith<$Res> {
  factory $InteractionEventCopyWith(
          InteractionEvent value, $Res Function(InteractionEvent) then) =
      _$InteractionEventCopyWithImpl<$Res, InteractionEvent>;
}

/// @nodoc
class _$InteractionEventCopyWithImpl<$Res, $Val extends InteractionEvent>
    implements $InteractionEventCopyWith<$Res> {
  _$InteractionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DragStartEventImplCopyWith<$Res> {
  factory _$$DragStartEventImplCopyWith(_$DragStartEventImpl value,
          $Res Function(_$DragStartEventImpl) then) =
      __$$DragStartEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Offset startPosition, DragOrigin origin});
}

/// @nodoc
class __$$DragStartEventImplCopyWithImpl<$Res>
    extends _$InteractionEventCopyWithImpl<$Res, _$DragStartEventImpl>
    implements _$$DragStartEventImplCopyWith<$Res> {
  __$$DragStartEventImplCopyWithImpl(
      _$DragStartEventImpl _value, $Res Function(_$DragStartEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startPosition = null,
    Object? origin = null,
  }) {
    return _then(_$DragStartEventImpl(
      null == startPosition
          ? _value.startPosition
          : startPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      null == origin
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as DragOrigin,
    ));
  }
}

/// @nodoc

class _$DragStartEventImpl implements _DragStartEvent {
  const _$DragStartEventImpl(this.startPosition, this.origin);

  @override
  final Offset startPosition;
  @override
  final DragOrigin origin;

  @override
  String toString() {
    return 'InteractionEvent.dragStart(startPosition: $startPosition, origin: $origin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DragStartEventImpl &&
            (identical(other.startPosition, startPosition) ||
                other.startPosition == startPosition) &&
            (identical(other.origin, origin) || other.origin == origin));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startPosition, origin);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DragStartEventImplCopyWith<_$DragStartEventImpl> get copyWith =>
      __$$DragStartEventImplCopyWithImpl<_$DragStartEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Offset startPosition, DragOrigin origin)
        dragStart,
    required TResult Function(Offset currentPosition) dragUpdate,
    required TResult Function(Offset endPosition) dragEnd,
    required TResult Function(Offset delta) gesturePan,
    required TResult Function(double scale) gestureScale,
  }) {
    return dragStart(startPosition, origin);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult? Function(Offset currentPosition)? dragUpdate,
    TResult? Function(Offset endPosition)? dragEnd,
    TResult? Function(Offset delta)? gesturePan,
    TResult? Function(double scale)? gestureScale,
  }) {
    return dragStart?.call(startPosition, origin);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult Function(Offset currentPosition)? dragUpdate,
    TResult Function(Offset endPosition)? dragEnd,
    TResult Function(Offset delta)? gesturePan,
    TResult Function(double scale)? gestureScale,
    required TResult orElse(),
  }) {
    if (dragStart != null) {
      return dragStart(startPosition, origin);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DragStartEvent value) dragStart,
    required TResult Function(_DragUpdateEvent value) dragUpdate,
    required TResult Function(_DragEndEvent value) dragEnd,
    required TResult Function(_PanEvent value) gesturePan,
    required TResult Function(_ScaleEvent value) gestureScale,
  }) {
    return dragStart(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DragStartEvent value)? dragStart,
    TResult? Function(_DragUpdateEvent value)? dragUpdate,
    TResult? Function(_DragEndEvent value)? dragEnd,
    TResult? Function(_PanEvent value)? gesturePan,
    TResult? Function(_ScaleEvent value)? gestureScale,
  }) {
    return dragStart?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DragStartEvent value)? dragStart,
    TResult Function(_DragUpdateEvent value)? dragUpdate,
    TResult Function(_DragEndEvent value)? dragEnd,
    TResult Function(_PanEvent value)? gesturePan,
    TResult Function(_ScaleEvent value)? gestureScale,
    required TResult orElse(),
  }) {
    if (dragStart != null) {
      return dragStart(this);
    }
    return orElse();
  }
}

abstract class _DragStartEvent implements InteractionEvent {
  const factory _DragStartEvent(
          final Offset startPosition, final DragOrigin origin) =
      _$DragStartEventImpl;

  Offset get startPosition;
  DragOrigin get origin;

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DragStartEventImplCopyWith<_$DragStartEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DragUpdateEventImplCopyWith<$Res> {
  factory _$$DragUpdateEventImplCopyWith(_$DragUpdateEventImpl value,
          $Res Function(_$DragUpdateEventImpl) then) =
      __$$DragUpdateEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Offset currentPosition});
}

/// @nodoc
class __$$DragUpdateEventImplCopyWithImpl<$Res>
    extends _$InteractionEventCopyWithImpl<$Res, _$DragUpdateEventImpl>
    implements _$$DragUpdateEventImplCopyWith<$Res> {
  __$$DragUpdateEventImplCopyWithImpl(
      _$DragUpdateEventImpl _value, $Res Function(_$DragUpdateEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPosition = null,
  }) {
    return _then(_$DragUpdateEventImpl(
      null == currentPosition
          ? _value.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
    ));
  }
}

/// @nodoc

class _$DragUpdateEventImpl implements _DragUpdateEvent {
  const _$DragUpdateEventImpl(this.currentPosition);

  @override
  final Offset currentPosition;

  @override
  String toString() {
    return 'InteractionEvent.dragUpdate(currentPosition: $currentPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DragUpdateEventImpl &&
            (identical(other.currentPosition, currentPosition) ||
                other.currentPosition == currentPosition));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentPosition);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DragUpdateEventImplCopyWith<_$DragUpdateEventImpl> get copyWith =>
      __$$DragUpdateEventImplCopyWithImpl<_$DragUpdateEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Offset startPosition, DragOrigin origin)
        dragStart,
    required TResult Function(Offset currentPosition) dragUpdate,
    required TResult Function(Offset endPosition) dragEnd,
    required TResult Function(Offset delta) gesturePan,
    required TResult Function(double scale) gestureScale,
  }) {
    return dragUpdate(currentPosition);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult? Function(Offset currentPosition)? dragUpdate,
    TResult? Function(Offset endPosition)? dragEnd,
    TResult? Function(Offset delta)? gesturePan,
    TResult? Function(double scale)? gestureScale,
  }) {
    return dragUpdate?.call(currentPosition);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult Function(Offset currentPosition)? dragUpdate,
    TResult Function(Offset endPosition)? dragEnd,
    TResult Function(Offset delta)? gesturePan,
    TResult Function(double scale)? gestureScale,
    required TResult orElse(),
  }) {
    if (dragUpdate != null) {
      return dragUpdate(currentPosition);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DragStartEvent value) dragStart,
    required TResult Function(_DragUpdateEvent value) dragUpdate,
    required TResult Function(_DragEndEvent value) dragEnd,
    required TResult Function(_PanEvent value) gesturePan,
    required TResult Function(_ScaleEvent value) gestureScale,
  }) {
    return dragUpdate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DragStartEvent value)? dragStart,
    TResult? Function(_DragUpdateEvent value)? dragUpdate,
    TResult? Function(_DragEndEvent value)? dragEnd,
    TResult? Function(_PanEvent value)? gesturePan,
    TResult? Function(_ScaleEvent value)? gestureScale,
  }) {
    return dragUpdate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DragStartEvent value)? dragStart,
    TResult Function(_DragUpdateEvent value)? dragUpdate,
    TResult Function(_DragEndEvent value)? dragEnd,
    TResult Function(_PanEvent value)? gesturePan,
    TResult Function(_ScaleEvent value)? gestureScale,
    required TResult orElse(),
  }) {
    if (dragUpdate != null) {
      return dragUpdate(this);
    }
    return orElse();
  }
}

abstract class _DragUpdateEvent implements InteractionEvent {
  const factory _DragUpdateEvent(final Offset currentPosition) =
      _$DragUpdateEventImpl;

  Offset get currentPosition;

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DragUpdateEventImplCopyWith<_$DragUpdateEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DragEndEventImplCopyWith<$Res> {
  factory _$$DragEndEventImplCopyWith(
          _$DragEndEventImpl value, $Res Function(_$DragEndEventImpl) then) =
      __$$DragEndEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Offset endPosition});
}

/// @nodoc
class __$$DragEndEventImplCopyWithImpl<$Res>
    extends _$InteractionEventCopyWithImpl<$Res, _$DragEndEventImpl>
    implements _$$DragEndEventImplCopyWith<$Res> {
  __$$DragEndEventImplCopyWithImpl(
      _$DragEndEventImpl _value, $Res Function(_$DragEndEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? endPosition = null,
  }) {
    return _then(_$DragEndEventImpl(
      null == endPosition
          ? _value.endPosition
          : endPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
    ));
  }
}

/// @nodoc

class _$DragEndEventImpl implements _DragEndEvent {
  const _$DragEndEventImpl(this.endPosition);

  @override
  final Offset endPosition;

  @override
  String toString() {
    return 'InteractionEvent.dragEnd(endPosition: $endPosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DragEndEventImpl &&
            (identical(other.endPosition, endPosition) ||
                other.endPosition == endPosition));
  }

  @override
  int get hashCode => Object.hash(runtimeType, endPosition);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DragEndEventImplCopyWith<_$DragEndEventImpl> get copyWith =>
      __$$DragEndEventImplCopyWithImpl<_$DragEndEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Offset startPosition, DragOrigin origin)
        dragStart,
    required TResult Function(Offset currentPosition) dragUpdate,
    required TResult Function(Offset endPosition) dragEnd,
    required TResult Function(Offset delta) gesturePan,
    required TResult Function(double scale) gestureScale,
  }) {
    return dragEnd(endPosition);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult? Function(Offset currentPosition)? dragUpdate,
    TResult? Function(Offset endPosition)? dragEnd,
    TResult? Function(Offset delta)? gesturePan,
    TResult? Function(double scale)? gestureScale,
  }) {
    return dragEnd?.call(endPosition);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult Function(Offset currentPosition)? dragUpdate,
    TResult Function(Offset endPosition)? dragEnd,
    TResult Function(Offset delta)? gesturePan,
    TResult Function(double scale)? gestureScale,
    required TResult orElse(),
  }) {
    if (dragEnd != null) {
      return dragEnd(endPosition);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DragStartEvent value) dragStart,
    required TResult Function(_DragUpdateEvent value) dragUpdate,
    required TResult Function(_DragEndEvent value) dragEnd,
    required TResult Function(_PanEvent value) gesturePan,
    required TResult Function(_ScaleEvent value) gestureScale,
  }) {
    return dragEnd(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DragStartEvent value)? dragStart,
    TResult? Function(_DragUpdateEvent value)? dragUpdate,
    TResult? Function(_DragEndEvent value)? dragEnd,
    TResult? Function(_PanEvent value)? gesturePan,
    TResult? Function(_ScaleEvent value)? gestureScale,
  }) {
    return dragEnd?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DragStartEvent value)? dragStart,
    TResult Function(_DragUpdateEvent value)? dragUpdate,
    TResult Function(_DragEndEvent value)? dragEnd,
    TResult Function(_PanEvent value)? gesturePan,
    TResult Function(_ScaleEvent value)? gestureScale,
    required TResult orElse(),
  }) {
    if (dragEnd != null) {
      return dragEnd(this);
    }
    return orElse();
  }
}

abstract class _DragEndEvent implements InteractionEvent {
  const factory _DragEndEvent(final Offset endPosition) = _$DragEndEventImpl;

  Offset get endPosition;

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DragEndEventImplCopyWith<_$DragEndEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PanEventImplCopyWith<$Res> {
  factory _$$PanEventImplCopyWith(
          _$PanEventImpl value, $Res Function(_$PanEventImpl) then) =
      __$$PanEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Offset delta});
}

/// @nodoc
class __$$PanEventImplCopyWithImpl<$Res>
    extends _$InteractionEventCopyWithImpl<$Res, _$PanEventImpl>
    implements _$$PanEventImplCopyWith<$Res> {
  __$$PanEventImplCopyWithImpl(
      _$PanEventImpl _value, $Res Function(_$PanEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? delta = null,
  }) {
    return _then(_$PanEventImpl(
      null == delta
          ? _value.delta
          : delta // ignore: cast_nullable_to_non_nullable
              as Offset,
    ));
  }
}

/// @nodoc

class _$PanEventImpl implements _PanEvent {
  const _$PanEventImpl(this.delta);

  @override
  final Offset delta;

  @override
  String toString() {
    return 'InteractionEvent.gesturePan(delta: $delta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanEventImpl &&
            (identical(other.delta, delta) || other.delta == delta));
  }

  @override
  int get hashCode => Object.hash(runtimeType, delta);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanEventImplCopyWith<_$PanEventImpl> get copyWith =>
      __$$PanEventImplCopyWithImpl<_$PanEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Offset startPosition, DragOrigin origin)
        dragStart,
    required TResult Function(Offset currentPosition) dragUpdate,
    required TResult Function(Offset endPosition) dragEnd,
    required TResult Function(Offset delta) gesturePan,
    required TResult Function(double scale) gestureScale,
  }) {
    return gesturePan(delta);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult? Function(Offset currentPosition)? dragUpdate,
    TResult? Function(Offset endPosition)? dragEnd,
    TResult? Function(Offset delta)? gesturePan,
    TResult? Function(double scale)? gestureScale,
  }) {
    return gesturePan?.call(delta);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult Function(Offset currentPosition)? dragUpdate,
    TResult Function(Offset endPosition)? dragEnd,
    TResult Function(Offset delta)? gesturePan,
    TResult Function(double scale)? gestureScale,
    required TResult orElse(),
  }) {
    if (gesturePan != null) {
      return gesturePan(delta);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DragStartEvent value) dragStart,
    required TResult Function(_DragUpdateEvent value) dragUpdate,
    required TResult Function(_DragEndEvent value) dragEnd,
    required TResult Function(_PanEvent value) gesturePan,
    required TResult Function(_ScaleEvent value) gestureScale,
  }) {
    return gesturePan(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DragStartEvent value)? dragStart,
    TResult? Function(_DragUpdateEvent value)? dragUpdate,
    TResult? Function(_DragEndEvent value)? dragEnd,
    TResult? Function(_PanEvent value)? gesturePan,
    TResult? Function(_ScaleEvent value)? gestureScale,
  }) {
    return gesturePan?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DragStartEvent value)? dragStart,
    TResult Function(_DragUpdateEvent value)? dragUpdate,
    TResult Function(_DragEndEvent value)? dragEnd,
    TResult Function(_PanEvent value)? gesturePan,
    TResult Function(_ScaleEvent value)? gestureScale,
    required TResult orElse(),
  }) {
    if (gesturePan != null) {
      return gesturePan(this);
    }
    return orElse();
  }
}

abstract class _PanEvent implements InteractionEvent {
  const factory _PanEvent(final Offset delta) = _$PanEventImpl;

  Offset get delta;

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanEventImplCopyWith<_$PanEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ScaleEventImplCopyWith<$Res> {
  factory _$$ScaleEventImplCopyWith(
          _$ScaleEventImpl value, $Res Function(_$ScaleEventImpl) then) =
      __$$ScaleEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double scale});
}

/// @nodoc
class __$$ScaleEventImplCopyWithImpl<$Res>
    extends _$InteractionEventCopyWithImpl<$Res, _$ScaleEventImpl>
    implements _$$ScaleEventImplCopyWith<$Res> {
  __$$ScaleEventImplCopyWithImpl(
      _$ScaleEventImpl _value, $Res Function(_$ScaleEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scale = null,
  }) {
    return _then(_$ScaleEventImpl(
      null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$ScaleEventImpl implements _ScaleEvent {
  const _$ScaleEventImpl(this.scale);

  @override
  final double scale;

  @override
  String toString() {
    return 'InteractionEvent.gestureScale(scale: $scale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScaleEventImpl &&
            (identical(other.scale, scale) || other.scale == scale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, scale);

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScaleEventImplCopyWith<_$ScaleEventImpl> get copyWith =>
      __$$ScaleEventImplCopyWithImpl<_$ScaleEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Offset startPosition, DragOrigin origin)
        dragStart,
    required TResult Function(Offset currentPosition) dragUpdate,
    required TResult Function(Offset endPosition) dragEnd,
    required TResult Function(Offset delta) gesturePan,
    required TResult Function(double scale) gestureScale,
  }) {
    return gestureScale(scale);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult? Function(Offset currentPosition)? dragUpdate,
    TResult? Function(Offset endPosition)? dragEnd,
    TResult? Function(Offset delta)? gesturePan,
    TResult? Function(double scale)? gestureScale,
  }) {
    return gestureScale?.call(scale);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Offset startPosition, DragOrigin origin)? dragStart,
    TResult Function(Offset currentPosition)? dragUpdate,
    TResult Function(Offset endPosition)? dragEnd,
    TResult Function(Offset delta)? gesturePan,
    TResult Function(double scale)? gestureScale,
    required TResult orElse(),
  }) {
    if (gestureScale != null) {
      return gestureScale(scale);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_DragStartEvent value) dragStart,
    required TResult Function(_DragUpdateEvent value) dragUpdate,
    required TResult Function(_DragEndEvent value) dragEnd,
    required TResult Function(_PanEvent value) gesturePan,
    required TResult Function(_ScaleEvent value) gestureScale,
  }) {
    return gestureScale(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_DragStartEvent value)? dragStart,
    TResult? Function(_DragUpdateEvent value)? dragUpdate,
    TResult? Function(_DragEndEvent value)? dragEnd,
    TResult? Function(_PanEvent value)? gesturePan,
    TResult? Function(_ScaleEvent value)? gestureScale,
  }) {
    return gestureScale?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_DragStartEvent value)? dragStart,
    TResult Function(_DragUpdateEvent value)? dragUpdate,
    TResult Function(_DragEndEvent value)? dragEnd,
    TResult Function(_PanEvent value)? gesturePan,
    TResult Function(_ScaleEvent value)? gestureScale,
    required TResult orElse(),
  }) {
    if (gestureScale != null) {
      return gestureScale(this);
    }
    return orElse();
  }
}

abstract class _ScaleEvent implements InteractionEvent {
  const factory _ScaleEvent(final double scale) = _$ScaleEventImpl;

  double get scale;

  /// Create a copy of InteractionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScaleEventImplCopyWith<_$ScaleEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InteractionState {
  InteractionMode get currentMode => throw _privateConstructorUsedError;
  ComponentDragData? get componentData => throw _privateConstructorUsedError;
  WireDrawData? get wireData => throw _privateConstructorUsedError;
  GridPosition? get targetPosition => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;
  List<GridPosition> get path => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InteractionStateCopyWith<InteractionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InteractionStateCopyWith<$Res> {
  factory $InteractionStateCopyWith(
          InteractionState value, $Res Function(InteractionState) then) =
      _$InteractionStateCopyWithImpl<$Res, InteractionState>;
  @useResult
  $Res call(
      {InteractionMode currentMode,
      ComponentDragData? componentData,
      WireDrawData? wireData,
      GridPosition? targetPosition,
      bool isValid,
      List<GridPosition> path,
      String? errorMessage});

  $WireDrawDataCopyWith<$Res>? get wireData;
  $GridPositionCopyWith<$Res>? get targetPosition;
}

/// @nodoc
class _$InteractionStateCopyWithImpl<$Res, $Val extends InteractionState>
    implements $InteractionStateCopyWith<$Res> {
  _$InteractionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentMode = null,
    Object? componentData = freezed,
    Object? wireData = freezed,
    Object? targetPosition = freezed,
    Object? isValid = null,
    Object? path = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      currentMode: null == currentMode
          ? _value.currentMode
          : currentMode // ignore: cast_nullable_to_non_nullable
              as InteractionMode,
      componentData: freezed == componentData
          ? _value.componentData
          : componentData // ignore: cast_nullable_to_non_nullable
              as ComponentDragData?,
      wireData: freezed == wireData
          ? _value.wireData
          : wireData // ignore: cast_nullable_to_non_nullable
              as WireDrawData?,
      targetPosition: freezed == targetPosition
          ? _value.targetPosition
          : targetPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as List<GridPosition>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WireDrawDataCopyWith<$Res>? get wireData {
    if (_value.wireData == null) {
      return null;
    }

    return $WireDrawDataCopyWith<$Res>(_value.wireData!, (value) {
      return _then(_value.copyWith(wireData: value) as $Val);
    });
  }

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridPositionCopyWith<$Res>? get targetPosition {
    if (_value.targetPosition == null) {
      return null;
    }

    return $GridPositionCopyWith<$Res>(_value.targetPosition!, (value) {
      return _then(_value.copyWith(targetPosition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InteractionStateImplCopyWith<$Res>
    implements $InteractionStateCopyWith<$Res> {
  factory _$$InteractionStateImplCopyWith(_$InteractionStateImpl value,
          $Res Function(_$InteractionStateImpl) then) =
      __$$InteractionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {InteractionMode currentMode,
      ComponentDragData? componentData,
      WireDrawData? wireData,
      GridPosition? targetPosition,
      bool isValid,
      List<GridPosition> path,
      String? errorMessage});

  @override
  $WireDrawDataCopyWith<$Res>? get wireData;
  @override
  $GridPositionCopyWith<$Res>? get targetPosition;
}

/// @nodoc
class __$$InteractionStateImplCopyWithImpl<$Res>
    extends _$InteractionStateCopyWithImpl<$Res, _$InteractionStateImpl>
    implements _$$InteractionStateImplCopyWith<$Res> {
  __$$InteractionStateImplCopyWithImpl(_$InteractionStateImpl _value,
      $Res Function(_$InteractionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentMode = null,
    Object? componentData = freezed,
    Object? wireData = freezed,
    Object? targetPosition = freezed,
    Object? isValid = null,
    Object? path = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$InteractionStateImpl(
      currentMode: null == currentMode
          ? _value.currentMode
          : currentMode // ignore: cast_nullable_to_non_nullable
              as InteractionMode,
      componentData: freezed == componentData
          ? _value.componentData
          : componentData // ignore: cast_nullable_to_non_nullable
              as ComponentDragData?,
      wireData: freezed == wireData
          ? _value.wireData
          : wireData // ignore: cast_nullable_to_non_nullable
              as WireDrawData?,
      targetPosition: freezed == targetPosition
          ? _value.targetPosition
          : targetPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      path: null == path
          ? _value._path
          : path // ignore: cast_nullable_to_non_nullable
              as List<GridPosition>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$InteractionStateImpl implements _InteractionState {
  const _$InteractionStateImpl(
      {required this.currentMode,
      this.componentData,
      this.wireData,
      this.targetPosition,
      this.isValid = false,
      final List<GridPosition> path = const [],
      this.errorMessage})
      : _path = path;

  @override
  final InteractionMode currentMode;
  @override
  final ComponentDragData? componentData;
  @override
  final WireDrawData? wireData;
  @override
  final GridPosition? targetPosition;
  @override
  @JsonKey()
  final bool isValid;
  final List<GridPosition> _path;
  @override
  @JsonKey()
  List<GridPosition> get path {
    if (_path is EqualUnmodifiableListView) return _path;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_path);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'InteractionState(currentMode: $currentMode, componentData: $componentData, wireData: $wireData, targetPosition: $targetPosition, isValid: $isValid, path: $path, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InteractionStateImpl &&
            (identical(other.currentMode, currentMode) ||
                other.currentMode == currentMode) &&
            (identical(other.componentData, componentData) ||
                other.componentData == componentData) &&
            (identical(other.wireData, wireData) ||
                other.wireData == wireData) &&
            (identical(other.targetPosition, targetPosition) ||
                other.targetPosition == targetPosition) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            const DeepCollectionEquality().equals(other._path, _path) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentMode,
      componentData,
      wireData,
      targetPosition,
      isValid,
      const DeepCollectionEquality().hash(_path),
      errorMessage);

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InteractionStateImplCopyWith<_$InteractionStateImpl> get copyWith =>
      __$$InteractionStateImplCopyWithImpl<_$InteractionStateImpl>(
          this, _$identity);
}

abstract class _InteractionState implements InteractionState {
  const factory _InteractionState(
      {required final InteractionMode currentMode,
      final ComponentDragData? componentData,
      final WireDrawData? wireData,
      final GridPosition? targetPosition,
      final bool isValid,
      final List<GridPosition> path,
      final String? errorMessage}) = _$InteractionStateImpl;

  @override
  InteractionMode get currentMode;
  @override
  ComponentDragData? get componentData;
  @override
  WireDrawData? get wireData;
  @override
  GridPosition? get targetPosition;
  @override
  bool get isValid;
  @override
  List<GridPosition> get path;
  @override
  String? get errorMessage;

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InteractionStateImplCopyWith<_$InteractionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WireDrawData {
  ComponentPort get startPort => throw _privateConstructorUsedError;
  ComponentPort? get endPort => throw _privateConstructorUsedError;

  /// Create a copy of WireDrawData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WireDrawDataCopyWith<WireDrawData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WireDrawDataCopyWith<$Res> {
  factory $WireDrawDataCopyWith(
          WireDrawData value, $Res Function(WireDrawData) then) =
      _$WireDrawDataCopyWithImpl<$Res, WireDrawData>;
  @useResult
  $Res call({ComponentPort startPort, ComponentPort? endPort});

  $ComponentPortCopyWith<$Res> get startPort;
  $ComponentPortCopyWith<$Res>? get endPort;
}

/// @nodoc
class _$WireDrawDataCopyWithImpl<$Res, $Val extends WireDrawData>
    implements $WireDrawDataCopyWith<$Res> {
  _$WireDrawDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WireDrawData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startPort = null,
    Object? endPort = freezed,
  }) {
    return _then(_value.copyWith(
      startPort: null == startPort
          ? _value.startPort
          : startPort // ignore: cast_nullable_to_non_nullable
              as ComponentPort,
      endPort: freezed == endPort
          ? _value.endPort
          : endPort // ignore: cast_nullable_to_non_nullable
              as ComponentPort?,
    ) as $Val);
  }

  /// Create a copy of WireDrawData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ComponentPortCopyWith<$Res> get startPort {
    return $ComponentPortCopyWith<$Res>(_value.startPort, (value) {
      return _then(_value.copyWith(startPort: value) as $Val);
    });
  }

  /// Create a copy of WireDrawData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ComponentPortCopyWith<$Res>? get endPort {
    if (_value.endPort == null) {
      return null;
    }

    return $ComponentPortCopyWith<$Res>(_value.endPort!, (value) {
      return _then(_value.copyWith(endPort: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WireDrawDataImplCopyWith<$Res>
    implements $WireDrawDataCopyWith<$Res> {
  factory _$$WireDrawDataImplCopyWith(
          _$WireDrawDataImpl value, $Res Function(_$WireDrawDataImpl) then) =
      __$$WireDrawDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ComponentPort startPort, ComponentPort? endPort});

  @override
  $ComponentPortCopyWith<$Res> get startPort;
  @override
  $ComponentPortCopyWith<$Res>? get endPort;
}

/// @nodoc
class __$$WireDrawDataImplCopyWithImpl<$Res>
    extends _$WireDrawDataCopyWithImpl<$Res, _$WireDrawDataImpl>
    implements _$$WireDrawDataImplCopyWith<$Res> {
  __$$WireDrawDataImplCopyWithImpl(
      _$WireDrawDataImpl _value, $Res Function(_$WireDrawDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WireDrawData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startPort = null,
    Object? endPort = freezed,
  }) {
    return _then(_$WireDrawDataImpl(
      startPort: null == startPort
          ? _value.startPort
          : startPort // ignore: cast_nullable_to_non_nullable
              as ComponentPort,
      endPort: freezed == endPort
          ? _value.endPort
          : endPort // ignore: cast_nullable_to_non_nullable
              as ComponentPort?,
    ));
  }
}

/// @nodoc

class _$WireDrawDataImpl implements _WireDrawData {
  const _$WireDrawDataImpl({required this.startPort, this.endPort});

  @override
  final ComponentPort startPort;
  @override
  final ComponentPort? endPort;

  @override
  String toString() {
    return 'WireDrawData(startPort: $startPort, endPort: $endPort)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WireDrawDataImpl &&
            (identical(other.startPort, startPort) ||
                other.startPort == startPort) &&
            (identical(other.endPort, endPort) || other.endPort == endPort));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startPort, endPort);

  /// Create a copy of WireDrawData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WireDrawDataImplCopyWith<_$WireDrawDataImpl> get copyWith =>
      __$$WireDrawDataImplCopyWithImpl<_$WireDrawDataImpl>(this, _$identity);
}

abstract class _WireDrawData implements WireDrawData {
  const factory _WireDrawData(
      {required final ComponentPort startPort,
      final ComponentPort? endPort}) = _$WireDrawDataImpl;

  @override
  ComponentPort get startPort;
  @override
  ComponentPort? get endPort;

  /// Create a copy of WireDrawData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WireDrawDataImplCopyWith<_$WireDrawDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ComponentPort {
  String get id => throw _privateConstructorUsedError;
  GridPosition get position => throw _privateConstructorUsedError;
  PortType get type => throw _privateConstructorUsedError;

  /// Create a copy of ComponentPort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComponentPortCopyWith<ComponentPort> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComponentPortCopyWith<$Res> {
  factory $ComponentPortCopyWith(
          ComponentPort value, $Res Function(ComponentPort) then) =
      _$ComponentPortCopyWithImpl<$Res, ComponentPort>;
  @useResult
  $Res call({String id, GridPosition position, PortType type});

  $GridPositionCopyWith<$Res> get position;
}

/// @nodoc
class _$ComponentPortCopyWithImpl<$Res, $Val extends ComponentPort>
    implements $ComponentPortCopyWith<$Res> {
  _$ComponentPortCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComponentPort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? position = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as GridPosition,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PortType,
    ) as $Val);
  }

  /// Create a copy of ComponentPort
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridPositionCopyWith<$Res> get position {
    return $GridPositionCopyWith<$Res>(_value.position, (value) {
      return _then(_value.copyWith(position: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComponentPortImplCopyWith<$Res>
    implements $ComponentPortCopyWith<$Res> {
  factory _$$ComponentPortImplCopyWith(
          _$ComponentPortImpl value, $Res Function(_$ComponentPortImpl) then) =
      __$$ComponentPortImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, GridPosition position, PortType type});

  @override
  $GridPositionCopyWith<$Res> get position;
}

/// @nodoc
class __$$ComponentPortImplCopyWithImpl<$Res>
    extends _$ComponentPortCopyWithImpl<$Res, _$ComponentPortImpl>
    implements _$$ComponentPortImplCopyWith<$Res> {
  __$$ComponentPortImplCopyWithImpl(
      _$ComponentPortImpl _value, $Res Function(_$ComponentPortImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComponentPort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? position = null,
    Object? type = null,
  }) {
    return _then(_$ComponentPortImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as GridPosition,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PortType,
    ));
  }
}

/// @nodoc

class _$ComponentPortImpl implements _ComponentPort {
  const _$ComponentPortImpl(
      {required this.id, required this.position, required this.type});

  @override
  final String id;
  @override
  final GridPosition position;
  @override
  final PortType type;

  @override
  String toString() {
    return 'ComponentPort(id: $id, position: $position, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComponentPortImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, position, type);

  /// Create a copy of ComponentPort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComponentPortImplCopyWith<_$ComponentPortImpl> get copyWith =>
      __$$ComponentPortImplCopyWithImpl<_$ComponentPortImpl>(this, _$identity);
}

abstract class _ComponentPort implements ComponentPort {
  const factory _ComponentPort(
      {required final String id,
      required final GridPosition position,
      required final PortType type}) = _$ComponentPortImpl;

  @override
  String get id;
  @override
  GridPosition get position;
  @override
  PortType get type;

  /// Create a copy of ComponentPort
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComponentPortImplCopyWith<_$ComponentPortImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
