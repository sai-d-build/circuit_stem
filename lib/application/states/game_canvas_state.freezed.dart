// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_canvas_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GameCanvasState {
  LevelDefinition? get currentLevel => throw _privateConstructorUsedError;
  CanvasRenderingData get renderingData => throw _privateConstructorUsedError;
  InteractionState get interactionState => throw _privateConstructorUsedError;
  ViewportState get viewportState => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, dynamic> get debugInfo => throw _privateConstructorUsedError;

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCanvasStateCopyWith<GameCanvasState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCanvasStateCopyWith<$Res> {
  factory $GameCanvasStateCopyWith(
          GameCanvasState value, $Res Function(GameCanvasState) then) =
      _$GameCanvasStateCopyWithImpl<$Res, GameCanvasState>;
  @useResult
  $Res call(
      {LevelDefinition? currentLevel,
      CanvasRenderingData renderingData,
      InteractionState interactionState,
      ViewportState viewportState,
      bool isLoading,
      String? error,
      Map<String, dynamic> debugInfo});

  $LevelDefinitionCopyWith<$Res>? get currentLevel;
  $CanvasRenderingDataCopyWith<$Res> get renderingData;
  $InteractionStateCopyWith<$Res> get interactionState;
  $ViewportStateCopyWith<$Res> get viewportState;
}

/// @nodoc
class _$GameCanvasStateCopyWithImpl<$Res, $Val extends GameCanvasState>
    implements $GameCanvasStateCopyWith<$Res> {
  _$GameCanvasStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = freezed,
    Object? renderingData = null,
    Object? interactionState = null,
    Object? viewportState = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? debugInfo = null,
  }) {
    return _then(_value.copyWith(
      currentLevel: freezed == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as LevelDefinition?,
      renderingData: null == renderingData
          ? _value.renderingData
          : renderingData // ignore: cast_nullable_to_non_nullable
              as CanvasRenderingData,
      interactionState: null == interactionState
          ? _value.interactionState
          : interactionState // ignore: cast_nullable_to_non_nullable
              as InteractionState,
      viewportState: null == viewportState
          ? _value.viewportState
          : viewportState // ignore: cast_nullable_to_non_nullable
              as ViewportState,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      debugInfo: null == debugInfo
          ? _value.debugInfo
          : debugInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LevelDefinitionCopyWith<$Res>? get currentLevel {
    if (_value.currentLevel == null) {
      return null;
    }

    return $LevelDefinitionCopyWith<$Res>(_value.currentLevel!, (value) {
      return _then(_value.copyWith(currentLevel: value) as $Val);
    });
  }

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CanvasRenderingDataCopyWith<$Res> get renderingData {
    return $CanvasRenderingDataCopyWith<$Res>(_value.renderingData, (value) {
      return _then(_value.copyWith(renderingData: value) as $Val);
    });
  }

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InteractionStateCopyWith<$Res> get interactionState {
    return $InteractionStateCopyWith<$Res>(_value.interactionState, (value) {
      return _then(_value.copyWith(interactionState: value) as $Val);
    });
  }

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ViewportStateCopyWith<$Res> get viewportState {
    return $ViewportStateCopyWith<$Res>(_value.viewportState, (value) {
      return _then(_value.copyWith(viewportState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameCanvasStateImplCopyWith<$Res>
    implements $GameCanvasStateCopyWith<$Res> {
  factory _$$GameCanvasStateImplCopyWith(_$GameCanvasStateImpl value,
          $Res Function(_$GameCanvasStateImpl) then) =
      __$$GameCanvasStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LevelDefinition? currentLevel,
      CanvasRenderingData renderingData,
      InteractionState interactionState,
      ViewportState viewportState,
      bool isLoading,
      String? error,
      Map<String, dynamic> debugInfo});

  @override
  $LevelDefinitionCopyWith<$Res>? get currentLevel;
  @override
  $CanvasRenderingDataCopyWith<$Res> get renderingData;
  @override
  $InteractionStateCopyWith<$Res> get interactionState;
  @override
  $ViewportStateCopyWith<$Res> get viewportState;
}

/// @nodoc
class __$$GameCanvasStateImplCopyWithImpl<$Res>
    extends _$GameCanvasStateCopyWithImpl<$Res, _$GameCanvasStateImpl>
    implements _$$GameCanvasStateImplCopyWith<$Res> {
  __$$GameCanvasStateImplCopyWithImpl(
      _$GameCanvasStateImpl _value, $Res Function(_$GameCanvasStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = freezed,
    Object? renderingData = null,
    Object? interactionState = null,
    Object? viewportState = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? debugInfo = null,
  }) {
    return _then(_$GameCanvasStateImpl(
      currentLevel: freezed == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as LevelDefinition?,
      renderingData: null == renderingData
          ? _value.renderingData
          : renderingData // ignore: cast_nullable_to_non_nullable
              as CanvasRenderingData,
      interactionState: null == interactionState
          ? _value.interactionState
          : interactionState // ignore: cast_nullable_to_non_nullable
              as InteractionState,
      viewportState: null == viewportState
          ? _value.viewportState
          : viewportState // ignore: cast_nullable_to_non_nullable
              as ViewportState,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      debugInfo: null == debugInfo
          ? _value._debugInfo
          : debugInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc

class _$GameCanvasStateImpl implements _GameCanvasState {
  const _$GameCanvasStateImpl(
      {required this.currentLevel,
      required this.renderingData,
      required this.interactionState,
      required this.viewportState,
      this.isLoading = false,
      this.error = null,
      final Map<String, dynamic> debugInfo = const {}})
      : _debugInfo = debugInfo;

  @override
  final LevelDefinition? currentLevel;
  @override
  final CanvasRenderingData renderingData;
  @override
  final InteractionState interactionState;
  @override
  final ViewportState viewportState;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;
  final Map<String, dynamic> _debugInfo;
  @override
  @JsonKey()
  Map<String, dynamic> get debugInfo {
    if (_debugInfo is EqualUnmodifiableMapView) return _debugInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_debugInfo);
  }

  @override
  String toString() {
    return 'GameCanvasState(currentLevel: $currentLevel, renderingData: $renderingData, interactionState: $interactionState, viewportState: $viewportState, isLoading: $isLoading, error: $error, debugInfo: $debugInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameCanvasStateImpl &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.renderingData, renderingData) ||
                other.renderingData == renderingData) &&
            (identical(other.interactionState, interactionState) ||
                other.interactionState == interactionState) &&
            (identical(other.viewportState, viewportState) ||
                other.viewportState == viewportState) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._debugInfo, _debugInfo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentLevel,
      renderingData,
      interactionState,
      viewportState,
      isLoading,
      error,
      const DeepCollectionEquality().hash(_debugInfo));

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameCanvasStateImplCopyWith<_$GameCanvasStateImpl> get copyWith =>
      __$$GameCanvasStateImplCopyWithImpl<_$GameCanvasStateImpl>(
          this, _$identity);
}

abstract class _GameCanvasState implements GameCanvasState {
  const factory _GameCanvasState(
      {required final LevelDefinition? currentLevel,
      required final CanvasRenderingData renderingData,
      required final InteractionState interactionState,
      required final ViewportState viewportState,
      final bool isLoading,
      final String? error,
      final Map<String, dynamic> debugInfo}) = _$GameCanvasStateImpl;

  @override
  LevelDefinition? get currentLevel;
  @override
  CanvasRenderingData get renderingData;
  @override
  InteractionState get interactionState;
  @override
  ViewportState get viewportState;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  Map<String, dynamic> get debugInfo;

  /// Create a copy of GameCanvasState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameCanvasStateImplCopyWith<_$GameCanvasStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InteractionState _$InteractionStateFromJson(Map<String, dynamic> json) {
  return _InteractionState.fromJson(json);
}

/// @nodoc
mixin _$InteractionState {
  GestureMode get mode => throw _privateConstructorUsedError;
  String? get selectedComponentId => throw _privateConstructorUsedError;
  String? get draggedComponentId => throw _privateConstructorUsedError;
  ComponentType? get placingComponentType => throw _privateConstructorUsedError;
  GridPosition? get dragStartPosition => throw _privateConstructorUsedError;
  GridPosition? get currentDragPosition => throw _privateConstructorUsedError;
  @OffsetConverter()
  Offset? get dragPosition => throw _privateConstructorUsedError;
  ComponentType? get draggedComponentType => throw _privateConstructorUsedError;
  @OffsetConverter()
  Offset? get mousePosition => throw _privateConstructorUsedError;

  /// Serializes this InteractionState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

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
      {GestureMode mode,
      String? selectedComponentId,
      String? draggedComponentId,
      ComponentType? placingComponentType,
      GridPosition? dragStartPosition,
      GridPosition? currentDragPosition,
      @OffsetConverter() Offset? dragPosition,
      ComponentType? draggedComponentType,
      @OffsetConverter() Offset? mousePosition});

  $GridPositionCopyWith<$Res>? get dragStartPosition;
  $GridPositionCopyWith<$Res>? get currentDragPosition;
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
    Object? mode = null,
    Object? selectedComponentId = freezed,
    Object? draggedComponentId = freezed,
    Object? placingComponentType = freezed,
    Object? dragStartPosition = freezed,
    Object? currentDragPosition = freezed,
    Object? dragPosition = freezed,
    Object? draggedComponentType = freezed,
    Object? mousePosition = freezed,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as GestureMode,
      selectedComponentId: freezed == selectedComponentId
          ? _value.selectedComponentId
          : selectedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      placingComponentType: freezed == placingComponentType
          ? _value.placingComponentType
          : placingComponentType // ignore: cast_nullable_to_non_nullable
              as ComponentType?,
      dragStartPosition: freezed == dragStartPosition
          ? _value.dragStartPosition
          : dragStartPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      currentDragPosition: freezed == currentDragPosition
          ? _value.currentDragPosition
          : currentDragPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      dragPosition: freezed == dragPosition
          ? _value.dragPosition
          : dragPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      draggedComponentType: freezed == draggedComponentType
          ? _value.draggedComponentType
          : draggedComponentType // ignore: cast_nullable_to_non_nullable
              as ComponentType?,
      mousePosition: freezed == mousePosition
          ? _value.mousePosition
          : mousePosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
    ) as $Val);
  }

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridPositionCopyWith<$Res>? get dragStartPosition {
    if (_value.dragStartPosition == null) {
      return null;
    }

    return $GridPositionCopyWith<$Res>(_value.dragStartPosition!, (value) {
      return _then(_value.copyWith(dragStartPosition: value) as $Val);
    });
  }

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridPositionCopyWith<$Res>? get currentDragPosition {
    if (_value.currentDragPosition == null) {
      return null;
    }

    return $GridPositionCopyWith<$Res>(_value.currentDragPosition!, (value) {
      return _then(_value.copyWith(currentDragPosition: value) as $Val);
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
      {GestureMode mode,
      String? selectedComponentId,
      String? draggedComponentId,
      ComponentType? placingComponentType,
      GridPosition? dragStartPosition,
      GridPosition? currentDragPosition,
      @OffsetConverter() Offset? dragPosition,
      ComponentType? draggedComponentType,
      @OffsetConverter() Offset? mousePosition});

  @override
  $GridPositionCopyWith<$Res>? get dragStartPosition;
  @override
  $GridPositionCopyWith<$Res>? get currentDragPosition;
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
    Object? mode = null,
    Object? selectedComponentId = freezed,
    Object? draggedComponentId = freezed,
    Object? placingComponentType = freezed,
    Object? dragStartPosition = freezed,
    Object? currentDragPosition = freezed,
    Object? dragPosition = freezed,
    Object? draggedComponentType = freezed,
    Object? mousePosition = freezed,
  }) {
    return _then(_$InteractionStateImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as GestureMode,
      selectedComponentId: freezed == selectedComponentId
          ? _value.selectedComponentId
          : selectedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      placingComponentType: freezed == placingComponentType
          ? _value.placingComponentType
          : placingComponentType // ignore: cast_nullable_to_non_nullable
              as ComponentType?,
      dragStartPosition: freezed == dragStartPosition
          ? _value.dragStartPosition
          : dragStartPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      currentDragPosition: freezed == currentDragPosition
          ? _value.currentDragPosition
          : currentDragPosition // ignore: cast_nullable_to_non_nullable
              as GridPosition?,
      dragPosition: freezed == dragPosition
          ? _value.dragPosition
          : dragPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      draggedComponentType: freezed == draggedComponentType
          ? _value.draggedComponentType
          : draggedComponentType // ignore: cast_nullable_to_non_nullable
              as ComponentType?,
      mousePosition: freezed == mousePosition
          ? _value.mousePosition
          : mousePosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InteractionStateImpl implements _InteractionState {
  const _$InteractionStateImpl(
      {required this.mode,
      this.selectedComponentId = null,
      this.draggedComponentId = null,
      this.placingComponentType = null,
      this.dragStartPosition = null,
      this.currentDragPosition = null,
      @OffsetConverter() this.dragPosition,
      this.draggedComponentType = null,
      @OffsetConverter() this.mousePosition});

  factory _$InteractionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$InteractionStateImplFromJson(json);

  @override
  final GestureMode mode;
  @override
  @JsonKey()
  final String? selectedComponentId;
  @override
  @JsonKey()
  final String? draggedComponentId;
  @override
  @JsonKey()
  final ComponentType? placingComponentType;
  @override
  @JsonKey()
  final GridPosition? dragStartPosition;
  @override
  @JsonKey()
  final GridPosition? currentDragPosition;
  @override
  @OffsetConverter()
  final Offset? dragPosition;
  @override
  @JsonKey()
  final ComponentType? draggedComponentType;
  @override
  @OffsetConverter()
  final Offset? mousePosition;

  @override
  String toString() {
    return 'InteractionState(mode: $mode, selectedComponentId: $selectedComponentId, draggedComponentId: $draggedComponentId, placingComponentType: $placingComponentType, dragStartPosition: $dragStartPosition, currentDragPosition: $currentDragPosition, dragPosition: $dragPosition, draggedComponentType: $draggedComponentType, mousePosition: $mousePosition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InteractionStateImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.selectedComponentId, selectedComponentId) ||
                other.selectedComponentId == selectedComponentId) &&
            (identical(other.draggedComponentId, draggedComponentId) ||
                other.draggedComponentId == draggedComponentId) &&
            (identical(other.placingComponentType, placingComponentType) ||
                other.placingComponentType == placingComponentType) &&
            (identical(other.dragStartPosition, dragStartPosition) ||
                other.dragStartPosition == dragStartPosition) &&
            (identical(other.currentDragPosition, currentDragPosition) ||
                other.currentDragPosition == currentDragPosition) &&
            (identical(other.dragPosition, dragPosition) ||
                other.dragPosition == dragPosition) &&
            (identical(other.draggedComponentType, draggedComponentType) ||
                other.draggedComponentType == draggedComponentType) &&
            (identical(other.mousePosition, mousePosition) ||
                other.mousePosition == mousePosition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mode,
      selectedComponentId,
      draggedComponentId,
      placingComponentType,
      dragStartPosition,
      currentDragPosition,
      dragPosition,
      draggedComponentType,
      mousePosition);

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InteractionStateImplCopyWith<_$InteractionStateImpl> get copyWith =>
      __$$InteractionStateImplCopyWithImpl<_$InteractionStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InteractionStateImplToJson(
      this,
    );
  }
}

abstract class _InteractionState implements InteractionState {
  const factory _InteractionState(
      {required final GestureMode mode,
      final String? selectedComponentId,
      final String? draggedComponentId,
      final ComponentType? placingComponentType,
      final GridPosition? dragStartPosition,
      final GridPosition? currentDragPosition,
      @OffsetConverter() final Offset? dragPosition,
      final ComponentType? draggedComponentType,
      @OffsetConverter() final Offset? mousePosition}) = _$InteractionStateImpl;

  factory _InteractionState.fromJson(Map<String, dynamic> json) =
      _$InteractionStateImpl.fromJson;

  @override
  GestureMode get mode;
  @override
  String? get selectedComponentId;
  @override
  String? get draggedComponentId;
  @override
  ComponentType? get placingComponentType;
  @override
  GridPosition? get dragStartPosition;
  @override
  GridPosition? get currentDragPosition;
  @override
  @OffsetConverter()
  Offset? get dragPosition;
  @override
  ComponentType? get draggedComponentType;
  @override
  @OffsetConverter()
  Offset? get mousePosition;

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InteractionStateImplCopyWith<_$InteractionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ViewportState {
  double get scale => throw _privateConstructorUsedError;
  @OffsetConverter()
  Offset get panOffset => throw _privateConstructorUsedError;
  Size get canvasSize => throw _privateConstructorUsedError;
  GridConfiguration get gridConfiguration => throw _privateConstructorUsedError;

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
      @OffsetConverter() Offset panOffset,
      Size canvasSize,
      GridConfiguration gridConfiguration});

  $GridConfigurationCopyWith<$Res> get gridConfiguration;
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
              as GridConfiguration,
    ) as $Val);
  }

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridConfigurationCopyWith<$Res> get gridConfiguration {
    return $GridConfigurationCopyWith<$Res>(_value.gridConfiguration, (value) {
      return _then(_value.copyWith(gridConfiguration: value) as $Val);
    });
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
      @OffsetConverter() Offset panOffset,
      Size canvasSize,
      GridConfiguration gridConfiguration});

  @override
  $GridConfigurationCopyWith<$Res> get gridConfiguration;
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
              as GridConfiguration,
    ));
  }
}

/// @nodoc

class _$ViewportStateImpl implements _ViewportState {
  const _$ViewportStateImpl(
      {required this.scale,
      @OffsetConverter() required this.panOffset,
      required this.canvasSize,
      required this.gridConfiguration});

  @override
  final double scale;
  @override
  @OffsetConverter()
  final Offset panOffset;
  @override
  final Size canvasSize;
  @override
  final GridConfiguration gridConfiguration;

  @override
  String toString() {
    return 'ViewportState(scale: $scale, panOffset: $panOffset, canvasSize: $canvasSize, gridConfiguration: $gridConfiguration)';
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
                other.gridConfiguration == gridConfiguration));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, scale, panOffset, canvasSize, gridConfiguration);

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
          {required final double scale,
          @OffsetConverter() required final Offset panOffset,
          required final Size canvasSize,
          required final GridConfiguration gridConfiguration}) =
      _$ViewportStateImpl;

  @override
  double get scale;
  @override
  @OffsetConverter()
  Offset get panOffset;
  @override
  Size get canvasSize;
  @override
  GridConfiguration get gridConfiguration;

  /// Create a copy of ViewportState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ViewportStateImplCopyWith<_$ViewportStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CanvasRenderingData _$CanvasRenderingDataFromJson(Map<String, dynamic> json) {
  return _CanvasRenderingData.fromJson(json);
}

/// @nodoc
mixin _$CanvasRenderingData {
  List<CircuitComponent> get components => throw _privateConstructorUsedError;
  List<CircuitWire> get wires => throw _privateConstructorUsedError;
  List<GridCell> get gridCells => throw _privateConstructorUsedError;
  GridConfiguration get gridConfiguration => throw _privateConstructorUsedError;
  Map<String, dynamic> get effectsData => throw _privateConstructorUsedError;

  /// Serializes this CanvasRenderingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CanvasRenderingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CanvasRenderingDataCopyWith<CanvasRenderingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CanvasRenderingDataCopyWith<$Res> {
  factory $CanvasRenderingDataCopyWith(
          CanvasRenderingData value, $Res Function(CanvasRenderingData) then) =
      _$CanvasRenderingDataCopyWithImpl<$Res, CanvasRenderingData>;
  @useResult
  $Res call(
      {List<CircuitComponent> components,
      List<CircuitWire> wires,
      List<GridCell> gridCells,
      GridConfiguration gridConfiguration,
      Map<String, dynamic> effectsData});

  $GridConfigurationCopyWith<$Res> get gridConfiguration;
}

/// @nodoc
class _$CanvasRenderingDataCopyWithImpl<$Res, $Val extends CanvasRenderingData>
    implements $CanvasRenderingDataCopyWith<$Res> {
  _$CanvasRenderingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CanvasRenderingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? components = null,
    Object? wires = null,
    Object? gridCells = null,
    Object? gridConfiguration = null,
    Object? effectsData = null,
  }) {
    return _then(_value.copyWith(
      components: null == components
          ? _value.components
          : components // ignore: cast_nullable_to_non_nullable
              as List<CircuitComponent>,
      wires: null == wires
          ? _value.wires
          : wires // ignore: cast_nullable_to_non_nullable
              as List<CircuitWire>,
      gridCells: null == gridCells
          ? _value.gridCells
          : gridCells // ignore: cast_nullable_to_non_nullable
              as List<GridCell>,
      gridConfiguration: null == gridConfiguration
          ? _value.gridConfiguration
          : gridConfiguration // ignore: cast_nullable_to_non_nullable
              as GridConfiguration,
      effectsData: null == effectsData
          ? _value.effectsData
          : effectsData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of CanvasRenderingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridConfigurationCopyWith<$Res> get gridConfiguration {
    return $GridConfigurationCopyWith<$Res>(_value.gridConfiguration, (value) {
      return _then(_value.copyWith(gridConfiguration: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CanvasRenderingDataImplCopyWith<$Res>
    implements $CanvasRenderingDataCopyWith<$Res> {
  factory _$$CanvasRenderingDataImplCopyWith(_$CanvasRenderingDataImpl value,
          $Res Function(_$CanvasRenderingDataImpl) then) =
      __$$CanvasRenderingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CircuitComponent> components,
      List<CircuitWire> wires,
      List<GridCell> gridCells,
      GridConfiguration gridConfiguration,
      Map<String, dynamic> effectsData});

  @override
  $GridConfigurationCopyWith<$Res> get gridConfiguration;
}

/// @nodoc
class __$$CanvasRenderingDataImplCopyWithImpl<$Res>
    extends _$CanvasRenderingDataCopyWithImpl<$Res, _$CanvasRenderingDataImpl>
    implements _$$CanvasRenderingDataImplCopyWith<$Res> {
  __$$CanvasRenderingDataImplCopyWithImpl(_$CanvasRenderingDataImpl _value,
      $Res Function(_$CanvasRenderingDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CanvasRenderingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? components = null,
    Object? wires = null,
    Object? gridCells = null,
    Object? gridConfiguration = null,
    Object? effectsData = null,
  }) {
    return _then(_$CanvasRenderingDataImpl(
      components: null == components
          ? _value._components
          : components // ignore: cast_nullable_to_non_nullable
              as List<CircuitComponent>,
      wires: null == wires
          ? _value._wires
          : wires // ignore: cast_nullable_to_non_nullable
              as List<CircuitWire>,
      gridCells: null == gridCells
          ? _value._gridCells
          : gridCells // ignore: cast_nullable_to_non_nullable
              as List<GridCell>,
      gridConfiguration: null == gridConfiguration
          ? _value.gridConfiguration
          : gridConfiguration // ignore: cast_nullable_to_non_nullable
              as GridConfiguration,
      effectsData: null == effectsData
          ? _value._effectsData
          : effectsData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CanvasRenderingDataImpl implements _CanvasRenderingData {
  const _$CanvasRenderingDataImpl(
      {final List<CircuitComponent> components = const [],
      final List<CircuitWire> wires = const [],
      final List<GridCell> gridCells = const [],
      required this.gridConfiguration,
      final Map<String, dynamic> effectsData = const {}})
      : _components = components,
        _wires = wires,
        _gridCells = gridCells,
        _effectsData = effectsData;

  factory _$CanvasRenderingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CanvasRenderingDataImplFromJson(json);

  final List<CircuitComponent> _components;
  @override
  @JsonKey()
  List<CircuitComponent> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  final List<CircuitWire> _wires;
  @override
  @JsonKey()
  List<CircuitWire> get wires {
    if (_wires is EqualUnmodifiableListView) return _wires;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wires);
  }

  final List<GridCell> _gridCells;
  @override
  @JsonKey()
  List<GridCell> get gridCells {
    if (_gridCells is EqualUnmodifiableListView) return _gridCells;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gridCells);
  }

  @override
  final GridConfiguration gridConfiguration;
  final Map<String, dynamic> _effectsData;
  @override
  @JsonKey()
  Map<String, dynamic> get effectsData {
    if (_effectsData is EqualUnmodifiableMapView) return _effectsData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_effectsData);
  }

  @override
  String toString() {
    return 'CanvasRenderingData(components: $components, wires: $wires, gridCells: $gridCells, gridConfiguration: $gridConfiguration, effectsData: $effectsData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CanvasRenderingDataImpl &&
            const DeepCollectionEquality()
                .equals(other._components, _components) &&
            const DeepCollectionEquality().equals(other._wires, _wires) &&
            const DeepCollectionEquality()
                .equals(other._gridCells, _gridCells) &&
            (identical(other.gridConfiguration, gridConfiguration) ||
                other.gridConfiguration == gridConfiguration) &&
            const DeepCollectionEquality()
                .equals(other._effectsData, _effectsData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_components),
      const DeepCollectionEquality().hash(_wires),
      const DeepCollectionEquality().hash(_gridCells),
      gridConfiguration,
      const DeepCollectionEquality().hash(_effectsData));

  /// Create a copy of CanvasRenderingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CanvasRenderingDataImplCopyWith<_$CanvasRenderingDataImpl> get copyWith =>
      __$$CanvasRenderingDataImplCopyWithImpl<_$CanvasRenderingDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CanvasRenderingDataImplToJson(
      this,
    );
  }
}

abstract class _CanvasRenderingData implements CanvasRenderingData {
  const factory _CanvasRenderingData(
      {final List<CircuitComponent> components,
      final List<CircuitWire> wires,
      final List<GridCell> gridCells,
      required final GridConfiguration gridConfiguration,
      final Map<String, dynamic> effectsData}) = _$CanvasRenderingDataImpl;

  factory _CanvasRenderingData.fromJson(Map<String, dynamic> json) =
      _$CanvasRenderingDataImpl.fromJson;

  @override
  List<CircuitComponent> get components;
  @override
  List<CircuitWire> get wires;
  @override
  List<GridCell> get gridCells;
  @override
  GridConfiguration get gridConfiguration;
  @override
  Map<String, dynamic> get effectsData;

  /// Create a copy of CanvasRenderingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CanvasRenderingDataImplCopyWith<_$CanvasRenderingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GridPosition _$GridPositionFromJson(Map<String, dynamic> json) {
  return _GridPosition.fromJson(json);
}

/// @nodoc
mixin _$GridPosition {
  int get row => throw _privateConstructorUsedError;
  int get col => throw _privateConstructorUsedError;

  /// Serializes this GridPosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

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
@JsonSerializable()
class _$GridPositionImpl implements _GridPosition {
  const _$GridPositionImpl({required this.row, required this.col});

  factory _$GridPositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GridPositionImplFromJson(json);

  @override
  final int row;
  @override
  final int col;

  @override
  String toString() {
    return 'GridPosition(row: $row, col: $col)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridPositionImpl &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.col, col) || other.col == col));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, row, col);

  /// Create a copy of GridPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridPositionImplCopyWith<_$GridPositionImpl> get copyWith =>
      __$$GridPositionImplCopyWithImpl<_$GridPositionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GridPositionImplToJson(
      this,
    );
  }
}

abstract class _GridPosition implements GridPosition {
  const factory _GridPosition(
      {required final int row, required final int col}) = _$GridPositionImpl;

  factory _GridPosition.fromJson(Map<String, dynamic> json) =
      _$GridPositionImpl.fromJson;

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

GridConfiguration _$GridConfigurationFromJson(Map<String, dynamic> json) {
  return _GridConfiguration.fromJson(json);
}

/// @nodoc
mixin _$GridConfiguration {
  int get rows => throw _privateConstructorUsedError;
  int get cols => throw _privateConstructorUsedError;
  double get cellSize => throw _privateConstructorUsedError;

  /// Serializes this GridConfiguration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GridConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GridConfigurationCopyWith<GridConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GridConfigurationCopyWith<$Res> {
  factory $GridConfigurationCopyWith(
          GridConfiguration value, $Res Function(GridConfiguration) then) =
      _$GridConfigurationCopyWithImpl<$Res, GridConfiguration>;
  @useResult
  $Res call({int rows, int cols, double cellSize});
}

/// @nodoc
class _$GridConfigurationCopyWithImpl<$Res, $Val extends GridConfiguration>
    implements $GridConfigurationCopyWith<$Res> {
  _$GridConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GridConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? cols = null,
    Object? cellSize = null,
  }) {
    return _then(_value.copyWith(
      rows: null == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as int,
      cols: null == cols
          ? _value.cols
          : cols // ignore: cast_nullable_to_non_nullable
              as int,
      cellSize: null == cellSize
          ? _value.cellSize
          : cellSize // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GridConfigurationImplCopyWith<$Res>
    implements $GridConfigurationCopyWith<$Res> {
  factory _$$GridConfigurationImplCopyWith(_$GridConfigurationImpl value,
          $Res Function(_$GridConfigurationImpl) then) =
      __$$GridConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int rows, int cols, double cellSize});
}

/// @nodoc
class __$$GridConfigurationImplCopyWithImpl<$Res>
    extends _$GridConfigurationCopyWithImpl<$Res, _$GridConfigurationImpl>
    implements _$$GridConfigurationImplCopyWith<$Res> {
  __$$GridConfigurationImplCopyWithImpl(_$GridConfigurationImpl _value,
      $Res Function(_$GridConfigurationImpl) _then)
      : super(_value, _then);

  /// Create a copy of GridConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rows = null,
    Object? cols = null,
    Object? cellSize = null,
  }) {
    return _then(_$GridConfigurationImpl(
      rows: null == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as int,
      cols: null == cols
          ? _value.cols
          : cols // ignore: cast_nullable_to_non_nullable
              as int,
      cellSize: null == cellSize
          ? _value.cellSize
          : cellSize // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GridConfigurationImpl implements _GridConfiguration {
  const _$GridConfigurationImpl(
      {this.rows = 20, this.cols = 20, this.cellSize = 60.0});

  factory _$GridConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GridConfigurationImplFromJson(json);

  @override
  @JsonKey()
  final int rows;
  @override
  @JsonKey()
  final int cols;
  @override
  @JsonKey()
  final double cellSize;

  @override
  String toString() {
    return 'GridConfiguration(rows: $rows, cols: $cols, cellSize: $cellSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridConfigurationImpl &&
            (identical(other.rows, rows) || other.rows == rows) &&
            (identical(other.cols, cols) || other.cols == cols) &&
            (identical(other.cellSize, cellSize) ||
                other.cellSize == cellSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rows, cols, cellSize);

  /// Create a copy of GridConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridConfigurationImplCopyWith<_$GridConfigurationImpl> get copyWith =>
      __$$GridConfigurationImplCopyWithImpl<_$GridConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GridConfigurationImplToJson(
      this,
    );
  }
}

abstract class _GridConfiguration implements GridConfiguration {
  const factory _GridConfiguration(
      {final int rows,
      final int cols,
      final double cellSize}) = _$GridConfigurationImpl;

  factory _GridConfiguration.fromJson(Map<String, dynamic> json) =
      _$GridConfigurationImpl.fromJson;

  @override
  int get rows;
  @override
  int get cols;
  @override
  double get cellSize;

  /// Create a copy of GridConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridConfigurationImplCopyWith<_$GridConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CircuitComponent _$CircuitComponentFromJson(Map<String, dynamic> json) {
  return _CircuitComponent.fromJson(json);
}

/// @nodoc
mixin _$CircuitComponent {
  String get id => throw _privateConstructorUsedError;
  ComponentType get type => throw _privateConstructorUsedError;
  int get row => throw _privateConstructorUsedError;
  int get col => throw _privateConstructorUsedError;
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isHighlighted => throw _privateConstructorUsedError;

  /// Serializes this CircuitComponent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircuitComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircuitComponentCopyWith<CircuitComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircuitComponentCopyWith<$Res> {
  factory $CircuitComponentCopyWith(
          CircuitComponent value, $Res Function(CircuitComponent) then) =
      _$CircuitComponentCopyWithImpl<$Res, CircuitComponent>;
  @useResult
  $Res call(
      {String id,
      ComponentType type,
      int row,
      int col,
      Map<String, dynamic> properties,
      bool isSelected,
      bool isHighlighted});
}

/// @nodoc
class _$CircuitComponentCopyWithImpl<$Res, $Val extends CircuitComponent>
    implements $CircuitComponentCopyWith<$Res> {
  _$CircuitComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircuitComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? row = null,
    Object? col = null,
    Object? properties = null,
    Object? isSelected = null,
    Object? isHighlighted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ComponentType,
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isHighlighted: null == isHighlighted
          ? _value.isHighlighted
          : isHighlighted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CircuitComponentImplCopyWith<$Res>
    implements $CircuitComponentCopyWith<$Res> {
  factory _$$CircuitComponentImplCopyWith(_$CircuitComponentImpl value,
          $Res Function(_$CircuitComponentImpl) then) =
      __$$CircuitComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ComponentType type,
      int row,
      int col,
      Map<String, dynamic> properties,
      bool isSelected,
      bool isHighlighted});
}

/// @nodoc
class __$$CircuitComponentImplCopyWithImpl<$Res>
    extends _$CircuitComponentCopyWithImpl<$Res, _$CircuitComponentImpl>
    implements _$$CircuitComponentImplCopyWith<$Res> {
  __$$CircuitComponentImplCopyWithImpl(_$CircuitComponentImpl _value,
      $Res Function(_$CircuitComponentImpl) _then)
      : super(_value, _then);

  /// Create a copy of CircuitComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? row = null,
    Object? col = null,
    Object? properties = null,
    Object? isSelected = null,
    Object? isHighlighted = null,
  }) {
    return _then(_$CircuitComponentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ComponentType,
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
      properties: null == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isHighlighted: null == isHighlighted
          ? _value.isHighlighted
          : isHighlighted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CircuitComponentImpl implements _CircuitComponent {
  const _$CircuitComponentImpl(
      {required this.id,
      required this.type,
      required this.row,
      required this.col,
      final Map<String, dynamic> properties = const {},
      this.isSelected = false,
      this.isHighlighted = false})
      : _properties = properties;

  factory _$CircuitComponentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircuitComponentImplFromJson(json);

  @override
  final String id;
  @override
  final ComponentType type;
  @override
  final int row;
  @override
  final int col;
  final Map<String, dynamic> _properties;
  @override
  @JsonKey()
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  @JsonKey()
  final bool isSelected;
  @override
  @JsonKey()
  final bool isHighlighted;

  @override
  String toString() {
    return 'CircuitComponent(id: $id, type: $type, row: $row, col: $col, properties: $properties, isSelected: $isSelected, isHighlighted: $isHighlighted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircuitComponentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.col, col) || other.col == col) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isHighlighted, isHighlighted) ||
                other.isHighlighted == isHighlighted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      row,
      col,
      const DeepCollectionEquality().hash(_properties),
      isSelected,
      isHighlighted);

  /// Create a copy of CircuitComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircuitComponentImplCopyWith<_$CircuitComponentImpl> get copyWith =>
      __$$CircuitComponentImplCopyWithImpl<_$CircuitComponentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CircuitComponentImplToJson(
      this,
    );
  }
}

abstract class _CircuitComponent implements CircuitComponent {
  const factory _CircuitComponent(
      {required final String id,
      required final ComponentType type,
      required final int row,
      required final int col,
      final Map<String, dynamic> properties,
      final bool isSelected,
      final bool isHighlighted}) = _$CircuitComponentImpl;

  factory _CircuitComponent.fromJson(Map<String, dynamic> json) =
      _$CircuitComponentImpl.fromJson;

  @override
  String get id;
  @override
  ComponentType get type;
  @override
  int get row;
  @override
  int get col;
  @override
  Map<String, dynamic> get properties;
  @override
  bool get isSelected;
  @override
  bool get isHighlighted;

  /// Create a copy of CircuitComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircuitComponentImplCopyWith<_$CircuitComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CircuitWire _$CircuitWireFromJson(Map<String, dynamic> json) {
  return _CircuitWire.fromJson(json);
}

/// @nodoc
mixin _$CircuitWire {
  String get id => throw _privateConstructorUsedError;
  int get startRow => throw _privateConstructorUsedError;
  int get startCol => throw _privateConstructorUsedError;
  int get endRow => throw _privateConstructorUsedError;
  int get endCol => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  double get thickness => throw _privateConstructorUsedError;

  /// Serializes this CircuitWire to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircuitWire
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircuitWireCopyWith<CircuitWire> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircuitWireCopyWith<$Res> {
  factory $CircuitWireCopyWith(
          CircuitWire value, $Res Function(CircuitWire) then) =
      _$CircuitWireCopyWithImpl<$Res, CircuitWire>;
  @useResult
  $Res call(
      {String id,
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      bool isActive,
      double thickness});
}

/// @nodoc
class _$CircuitWireCopyWithImpl<$Res, $Val extends CircuitWire>
    implements $CircuitWireCopyWith<$Res> {
  _$CircuitWireCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircuitWire
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startRow = null,
    Object? startCol = null,
    Object? endRow = null,
    Object? endCol = null,
    Object? isActive = null,
    Object? thickness = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startRow: null == startRow
          ? _value.startRow
          : startRow // ignore: cast_nullable_to_non_nullable
              as int,
      startCol: null == startCol
          ? _value.startCol
          : startCol // ignore: cast_nullable_to_non_nullable
              as int,
      endRow: null == endRow
          ? _value.endRow
          : endRow // ignore: cast_nullable_to_non_nullable
              as int,
      endCol: null == endCol
          ? _value.endCol
          : endCol // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      thickness: null == thickness
          ? _value.thickness
          : thickness // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CircuitWireImplCopyWith<$Res>
    implements $CircuitWireCopyWith<$Res> {
  factory _$$CircuitWireImplCopyWith(
          _$CircuitWireImpl value, $Res Function(_$CircuitWireImpl) then) =
      __$$CircuitWireImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      bool isActive,
      double thickness});
}

/// @nodoc
class __$$CircuitWireImplCopyWithImpl<$Res>
    extends _$CircuitWireCopyWithImpl<$Res, _$CircuitWireImpl>
    implements _$$CircuitWireImplCopyWith<$Res> {
  __$$CircuitWireImplCopyWithImpl(
      _$CircuitWireImpl _value, $Res Function(_$CircuitWireImpl) _then)
      : super(_value, _then);

  /// Create a copy of CircuitWire
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startRow = null,
    Object? startCol = null,
    Object? endRow = null,
    Object? endCol = null,
    Object? isActive = null,
    Object? thickness = null,
  }) {
    return _then(_$CircuitWireImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startRow: null == startRow
          ? _value.startRow
          : startRow // ignore: cast_nullable_to_non_nullable
              as int,
      startCol: null == startCol
          ? _value.startCol
          : startCol // ignore: cast_nullable_to_non_nullable
              as int,
      endRow: null == endRow
          ? _value.endRow
          : endRow // ignore: cast_nullable_to_non_nullable
              as int,
      endCol: null == endCol
          ? _value.endCol
          : endCol // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      thickness: null == thickness
          ? _value.thickness
          : thickness // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CircuitWireImpl implements _CircuitWire {
  const _$CircuitWireImpl(
      {required this.id,
      required this.startRow,
      required this.startCol,
      required this.endRow,
      required this.endCol,
      this.isActive = false,
      this.thickness = 2.0});

  factory _$CircuitWireImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircuitWireImplFromJson(json);

  @override
  final String id;
  @override
  final int startRow;
  @override
  final int startCol;
  @override
  final int endRow;
  @override
  final int endCol;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final double thickness;

  @override
  String toString() {
    return 'CircuitWire(id: $id, startRow: $startRow, startCol: $startCol, endRow: $endRow, endCol: $endCol, isActive: $isActive, thickness: $thickness)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircuitWireImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startRow, startRow) ||
                other.startRow == startRow) &&
            (identical(other.startCol, startCol) ||
                other.startCol == startCol) &&
            (identical(other.endRow, endRow) || other.endRow == endRow) &&
            (identical(other.endCol, endCol) || other.endCol == endCol) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.thickness, thickness) ||
                other.thickness == thickness));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, startRow, startCol, endRow, endCol, isActive, thickness);

  /// Create a copy of CircuitWire
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircuitWireImplCopyWith<_$CircuitWireImpl> get copyWith =>
      __$$CircuitWireImplCopyWithImpl<_$CircuitWireImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CircuitWireImplToJson(
      this,
    );
  }
}

abstract class _CircuitWire implements CircuitWire {
  const factory _CircuitWire(
      {required final String id,
      required final int startRow,
      required final int startCol,
      required final int endRow,
      required final int endCol,
      final bool isActive,
      final double thickness}) = _$CircuitWireImpl;

  factory _CircuitWire.fromJson(Map<String, dynamic> json) =
      _$CircuitWireImpl.fromJson;

  @override
  String get id;
  @override
  int get startRow;
  @override
  int get startCol;
  @override
  int get endRow;
  @override
  int get endCol;
  @override
  bool get isActive;
  @override
  double get thickness;

  /// Create a copy of CircuitWire
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircuitWireImplCopyWith<_$CircuitWireImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GridCell _$GridCellFromJson(Map<String, dynamic> json) {
  return _GridCell.fromJson(json);
}

/// @nodoc
mixin _$GridCell {
  int get row => throw _privateConstructorUsedError;
  int get col => throw _privateConstructorUsedError;
  bool get isOccupied => throw _privateConstructorUsedError;
  bool get isHighlighted => throw _privateConstructorUsedError;
  String? get componentId => throw _privateConstructorUsedError;

  /// Serializes this GridCell to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GridCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GridCellCopyWith<GridCell> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GridCellCopyWith<$Res> {
  factory $GridCellCopyWith(GridCell value, $Res Function(GridCell) then) =
      _$GridCellCopyWithImpl<$Res, GridCell>;
  @useResult
  $Res call(
      {int row,
      int col,
      bool isOccupied,
      bool isHighlighted,
      String? componentId});
}

/// @nodoc
class _$GridCellCopyWithImpl<$Res, $Val extends GridCell>
    implements $GridCellCopyWith<$Res> {
  _$GridCellCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GridCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? col = null,
    Object? isOccupied = null,
    Object? isHighlighted = null,
    Object? componentId = freezed,
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
      isOccupied: null == isOccupied
          ? _value.isOccupied
          : isOccupied // ignore: cast_nullable_to_non_nullable
              as bool,
      isHighlighted: null == isHighlighted
          ? _value.isHighlighted
          : isHighlighted // ignore: cast_nullable_to_non_nullable
              as bool,
      componentId: freezed == componentId
          ? _value.componentId
          : componentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GridCellImplCopyWith<$Res>
    implements $GridCellCopyWith<$Res> {
  factory _$$GridCellImplCopyWith(
          _$GridCellImpl value, $Res Function(_$GridCellImpl) then) =
      __$$GridCellImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int row,
      int col,
      bool isOccupied,
      bool isHighlighted,
      String? componentId});
}

/// @nodoc
class __$$GridCellImplCopyWithImpl<$Res>
    extends _$GridCellCopyWithImpl<$Res, _$GridCellImpl>
    implements _$$GridCellImplCopyWith<$Res> {
  __$$GridCellImplCopyWithImpl(
      _$GridCellImpl _value, $Res Function(_$GridCellImpl) _then)
      : super(_value, _then);

  /// Create a copy of GridCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? row = null,
    Object? col = null,
    Object? isOccupied = null,
    Object? isHighlighted = null,
    Object? componentId = freezed,
  }) {
    return _then(_$GridCellImpl(
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as int,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
      isOccupied: null == isOccupied
          ? _value.isOccupied
          : isOccupied // ignore: cast_nullable_to_non_nullable
              as bool,
      isHighlighted: null == isHighlighted
          ? _value.isHighlighted
          : isHighlighted // ignore: cast_nullable_to_non_nullable
              as bool,
      componentId: freezed == componentId
          ? _value.componentId
          : componentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GridCellImpl implements _GridCell {
  const _$GridCellImpl(
      {required this.row,
      required this.col,
      this.isOccupied = false,
      this.isHighlighted = false,
      this.componentId = null});

  factory _$GridCellImpl.fromJson(Map<String, dynamic> json) =>
      _$$GridCellImplFromJson(json);

  @override
  final int row;
  @override
  final int col;
  @override
  @JsonKey()
  final bool isOccupied;
  @override
  @JsonKey()
  final bool isHighlighted;
  @override
  @JsonKey()
  final String? componentId;

  @override
  String toString() {
    return 'GridCell(row: $row, col: $col, isOccupied: $isOccupied, isHighlighted: $isHighlighted, componentId: $componentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GridCellImpl &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.col, col) || other.col == col) &&
            (identical(other.isOccupied, isOccupied) ||
                other.isOccupied == isOccupied) &&
            (identical(other.isHighlighted, isHighlighted) ||
                other.isHighlighted == isHighlighted) &&
            (identical(other.componentId, componentId) ||
                other.componentId == componentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, row, col, isOccupied, isHighlighted, componentId);

  /// Create a copy of GridCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GridCellImplCopyWith<_$GridCellImpl> get copyWith =>
      __$$GridCellImplCopyWithImpl<_$GridCellImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GridCellImplToJson(
      this,
    );
  }
}

abstract class _GridCell implements GridCell {
  const factory _GridCell(
      {required final int row,
      required final int col,
      final bool isOccupied,
      final bool isHighlighted,
      final String? componentId}) = _$GridCellImpl;

  factory _GridCell.fromJson(Map<String, dynamic> json) =
      _$GridCellImpl.fromJson;

  @override
  int get row;
  @override
  int get col;
  @override
  bool get isOccupied;
  @override
  bool get isHighlighted;
  @override
  String? get componentId;

  /// Create a copy of GridCell
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GridCellImplCopyWith<_$GridCellImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
