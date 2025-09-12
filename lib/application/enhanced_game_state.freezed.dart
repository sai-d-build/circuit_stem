// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enhanced_game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GameState {
  Grid get grid => throw _privateConstructorUsedError;
  bool get isPaused => throw _privateConstructorUsedError;
  bool get isWin => throw _privateConstructorUsedError;
  LevelDefinition? get currentLevel => throw _privateConstructorUsedError;
  SimulationResult? get simulationResult => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  bool get isDebugOverlayVisible => throw _privateConstructorUsedError;
  InteractionState get interactionState => throw _privateConstructorUsedError;
  HistoryState get history => throw _privateConstructorUsedError;
  String? get error =>
      throw _privateConstructorUsedError; // ✅ ADDED: Fields needed for InteractionEngine
  List<Wire> get wires => throw _privateConstructorUsedError;
  Offset? get wireDrawStartPos => throw _privateConstructorUsedError;
  bool get isDrawingWire => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call(
      {Grid grid,
      bool isPaused,
      bool isWin,
      LevelDefinition? currentLevel,
      SimulationResult? simulationResult,
      DateTime lastUpdated,
      bool isDebugOverlayVisible,
      InteractionState interactionState,
      HistoryState history,
      String? error,
      List<Wire> wires,
      Offset? wireDrawStartPos,
      bool isDrawingWire});

  $LevelDefinitionCopyWith<$Res>? get currentLevel;
  $SimulationResultCopyWith<$Res>? get simulationResult;
  $InteractionStateCopyWith<$Res> get interactionState;
  $HistoryStateCopyWith<$Res> get history;
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grid = null,
    Object? isPaused = null,
    Object? isWin = null,
    Object? currentLevel = freezed,
    Object? simulationResult = freezed,
    Object? lastUpdated = null,
    Object? isDebugOverlayVisible = null,
    Object? interactionState = null,
    Object? history = null,
    Object? error = freezed,
    Object? wires = null,
    Object? wireDrawStartPos = freezed,
    Object? isDrawingWire = null,
  }) {
    return _then(_value.copyWith(
      grid: null == grid
          ? _value.grid
          : grid // ignore: cast_nullable_to_non_nullable
              as Grid,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      isWin: null == isWin
          ? _value.isWin
          : isWin // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevel: freezed == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as LevelDefinition?,
      simulationResult: freezed == simulationResult
          ? _value.simulationResult
          : simulationResult // ignore: cast_nullable_to_non_nullable
              as SimulationResult?,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDebugOverlayVisible: null == isDebugOverlayVisible
          ? _value.isDebugOverlayVisible
          : isDebugOverlayVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      interactionState: null == interactionState
          ? _value.interactionState
          : interactionState // ignore: cast_nullable_to_non_nullable
              as InteractionState,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as HistoryState,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      wires: null == wires
          ? _value.wires
          : wires // ignore: cast_nullable_to_non_nullable
              as List<Wire>,
      wireDrawStartPos: freezed == wireDrawStartPos
          ? _value.wireDrawStartPos
          : wireDrawStartPos // ignore: cast_nullable_to_non_nullable
              as Offset?,
      isDrawingWire: null == isDrawingWire
          ? _value.isDrawingWire
          : isDrawingWire // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of GameState
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

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SimulationResultCopyWith<$Res>? get simulationResult {
    if (_value.simulationResult == null) {
      return null;
    }

    return $SimulationResultCopyWith<$Res>(_value.simulationResult!, (value) {
      return _then(_value.copyWith(simulationResult: value) as $Val);
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InteractionStateCopyWith<$Res> get interactionState {
    return $InteractionStateCopyWith<$Res>(_value.interactionState, (value) {
      return _then(_value.copyWith(interactionState: value) as $Val);
    });
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HistoryStateCopyWith<$Res> get history {
    return $HistoryStateCopyWith<$Res>(_value.history, (value) {
      return _then(_value.copyWith(history: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
          _$GameStateImpl value, $Res Function(_$GameStateImpl) then) =
      __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Grid grid,
      bool isPaused,
      bool isWin,
      LevelDefinition? currentLevel,
      SimulationResult? simulationResult,
      DateTime lastUpdated,
      bool isDebugOverlayVisible,
      InteractionState interactionState,
      HistoryState history,
      String? error,
      List<Wire> wires,
      Offset? wireDrawStartPos,
      bool isDrawingWire});

  @override
  $LevelDefinitionCopyWith<$Res>? get currentLevel;
  @override
  $SimulationResultCopyWith<$Res>? get simulationResult;
  @override
  $InteractionStateCopyWith<$Res> get interactionState;
  @override
  $HistoryStateCopyWith<$Res> get history;
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
      _$GameStateImpl _value, $Res Function(_$GameStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grid = null,
    Object? isPaused = null,
    Object? isWin = null,
    Object? currentLevel = freezed,
    Object? simulationResult = freezed,
    Object? lastUpdated = null,
    Object? isDebugOverlayVisible = null,
    Object? interactionState = null,
    Object? history = null,
    Object? error = freezed,
    Object? wires = null,
    Object? wireDrawStartPos = freezed,
    Object? isDrawingWire = null,
  }) {
    return _then(_$GameStateImpl(
      grid: null == grid
          ? _value.grid
          : grid // ignore: cast_nullable_to_non_nullable
              as Grid,
      isPaused: null == isPaused
          ? _value.isPaused
          : isPaused // ignore: cast_nullable_to_non_nullable
              as bool,
      isWin: null == isWin
          ? _value.isWin
          : isWin // ignore: cast_nullable_to_non_nullable
              as bool,
      currentLevel: freezed == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as LevelDefinition?,
      simulationResult: freezed == simulationResult
          ? _value.simulationResult
          : simulationResult // ignore: cast_nullable_to_non_nullable
              as SimulationResult?,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDebugOverlayVisible: null == isDebugOverlayVisible
          ? _value.isDebugOverlayVisible
          : isDebugOverlayVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      interactionState: null == interactionState
          ? _value.interactionState
          : interactionState // ignore: cast_nullable_to_non_nullable
              as InteractionState,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as HistoryState,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      wires: null == wires
          ? _value._wires
          : wires // ignore: cast_nullable_to_non_nullable
              as List<Wire>,
      wireDrawStartPos: freezed == wireDrawStartPos
          ? _value.wireDrawStartPos
          : wireDrawStartPos // ignore: cast_nullable_to_non_nullable
              as Offset?,
      isDrawingWire: null == isDrawingWire
          ? _value.isDrawingWire
          : isDrawingWire // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$GameStateImpl implements _GameState {
  const _$GameStateImpl(
      {required this.grid,
      required this.isPaused,
      required this.isWin,
      this.currentLevel,
      this.simulationResult,
      required this.lastUpdated,
      this.isDebugOverlayVisible = false,
      required this.interactionState,
      required this.history,
      this.error,
      final List<Wire> wires = const [],
      this.wireDrawStartPos,
      this.isDrawingWire = false})
      : _wires = wires;

  @override
  final Grid grid;
  @override
  final bool isPaused;
  @override
  final bool isWin;
  @override
  final LevelDefinition? currentLevel;
  @override
  final SimulationResult? simulationResult;
  @override
  final DateTime lastUpdated;
  @override
  @JsonKey()
  final bool isDebugOverlayVisible;
  @override
  final InteractionState interactionState;
  @override
  final HistoryState history;
  @override
  final String? error;
// ✅ ADDED: Fields needed for InteractionEngine
  final List<Wire> _wires;
// ✅ ADDED: Fields needed for InteractionEngine
  @override
  @JsonKey()
  List<Wire> get wires {
    if (_wires is EqualUnmodifiableListView) return _wires;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wires);
  }

  @override
  final Offset? wireDrawStartPos;
  @override
  @JsonKey()
  final bool isDrawingWire;

  @override
  String toString() {
    return 'GameState(grid: $grid, isPaused: $isPaused, isWin: $isWin, currentLevel: $currentLevel, simulationResult: $simulationResult, lastUpdated: $lastUpdated, isDebugOverlayVisible: $isDebugOverlayVisible, interactionState: $interactionState, history: $history, error: $error, wires: $wires, wireDrawStartPos: $wireDrawStartPos, isDrawingWire: $isDrawingWire)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.grid, grid) || other.grid == grid) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.isWin, isWin) || other.isWin == isWin) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.simulationResult, simulationResult) ||
                other.simulationResult == simulationResult) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.isDebugOverlayVisible, isDebugOverlayVisible) ||
                other.isDebugOverlayVisible == isDebugOverlayVisible) &&
            (identical(other.interactionState, interactionState) ||
                other.interactionState == interactionState) &&
            (identical(other.history, history) || other.history == history) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._wires, _wires) &&
            (identical(other.wireDrawStartPos, wireDrawStartPos) ||
                other.wireDrawStartPos == wireDrawStartPos) &&
            (identical(other.isDrawingWire, isDrawingWire) ||
                other.isDrawingWire == isDrawingWire));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      grid,
      isPaused,
      isWin,
      currentLevel,
      simulationResult,
      lastUpdated,
      isDebugOverlayVisible,
      interactionState,
      history,
      error,
      const DeepCollectionEquality().hash(_wires),
      wireDrawStartPos,
      isDrawingWire);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);
}

abstract class _GameState implements GameState {
  const factory _GameState(
      {required final Grid grid,
      required final bool isPaused,
      required final bool isWin,
      final LevelDefinition? currentLevel,
      final SimulationResult? simulationResult,
      required final DateTime lastUpdated,
      final bool isDebugOverlayVisible,
      required final InteractionState interactionState,
      required final HistoryState history,
      final String? error,
      final List<Wire> wires,
      final Offset? wireDrawStartPos,
      final bool isDrawingWire}) = _$GameStateImpl;

  @override
  Grid get grid;
  @override
  bool get isPaused;
  @override
  bool get isWin;
  @override
  LevelDefinition? get currentLevel;
  @override
  SimulationResult? get simulationResult;
  @override
  DateTime get lastUpdated;
  @override
  bool get isDebugOverlayVisible;
  @override
  InteractionState get interactionState;
  @override
  HistoryState get history;
  @override
  String? get error; // ✅ ADDED: Fields needed for InteractionEngine
  @override
  List<Wire> get wires;
  @override
  Offset? get wireDrawStartPos;
  @override
  bool get isDrawingWire;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$InteractionState {
  String? get selectedComponentId => throw _privateConstructorUsedError;
  String? get draggedComponentId => throw _privateConstructorUsedError;
  @OffsetConverter()
  Offset? get dragStartLocalPosition => throw _privateConstructorUsedError;
  @OffsetConverter()
  Offset? get dragUpdateLocalPosition => throw _privateConstructorUsedError;
  bool get isDragging => throw _privateConstructorUsedError;

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
      {String? selectedComponentId,
      String? draggedComponentId,
      @OffsetConverter() Offset? dragStartLocalPosition,
      @OffsetConverter() Offset? dragUpdateLocalPosition,
      bool isDragging});
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
    Object? selectedComponentId = freezed,
    Object? draggedComponentId = freezed,
    Object? dragStartLocalPosition = freezed,
    Object? dragUpdateLocalPosition = freezed,
    Object? isDragging = null,
  }) {
    return _then(_value.copyWith(
      selectedComponentId: freezed == selectedComponentId
          ? _value.selectedComponentId
          : selectedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      dragStartLocalPosition: freezed == dragStartLocalPosition
          ? _value.dragStartLocalPosition
          : dragStartLocalPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      dragUpdateLocalPosition: freezed == dragUpdateLocalPosition
          ? _value.dragUpdateLocalPosition
          : dragUpdateLocalPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      isDragging: null == isDragging
          ? _value.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
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
      {String? selectedComponentId,
      String? draggedComponentId,
      @OffsetConverter() Offset? dragStartLocalPosition,
      @OffsetConverter() Offset? dragUpdateLocalPosition,
      bool isDragging});
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
    Object? selectedComponentId = freezed,
    Object? draggedComponentId = freezed,
    Object? dragStartLocalPosition = freezed,
    Object? dragUpdateLocalPosition = freezed,
    Object? isDragging = null,
  }) {
    return _then(_$InteractionStateImpl(
      selectedComponentId: freezed == selectedComponentId
          ? _value.selectedComponentId
          : selectedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      dragStartLocalPosition: freezed == dragStartLocalPosition
          ? _value.dragStartLocalPosition
          : dragStartLocalPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      dragUpdateLocalPosition: freezed == dragUpdateLocalPosition
          ? _value.dragUpdateLocalPosition
          : dragUpdateLocalPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      isDragging: null == isDragging
          ? _value.isDragging
          : isDragging // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$InteractionStateImpl implements _InteractionState {
  const _$InteractionStateImpl(
      {this.selectedComponentId,
      this.draggedComponentId,
      @OffsetConverter() this.dragStartLocalPosition,
      @OffsetConverter() this.dragUpdateLocalPosition,
      this.isDragging = false});

  @override
  final String? selectedComponentId;
  @override
  final String? draggedComponentId;
  @override
  @OffsetConverter()
  final Offset? dragStartLocalPosition;
  @override
  @OffsetConverter()
  final Offset? dragUpdateLocalPosition;
  @override
  @JsonKey()
  final bool isDragging;

  @override
  String toString() {
    return 'InteractionState(selectedComponentId: $selectedComponentId, draggedComponentId: $draggedComponentId, dragStartLocalPosition: $dragStartLocalPosition, dragUpdateLocalPosition: $dragUpdateLocalPosition, isDragging: $isDragging)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InteractionStateImpl &&
            (identical(other.selectedComponentId, selectedComponentId) ||
                other.selectedComponentId == selectedComponentId) &&
            (identical(other.draggedComponentId, draggedComponentId) ||
                other.draggedComponentId == draggedComponentId) &&
            (identical(other.dragStartLocalPosition, dragStartLocalPosition) ||
                other.dragStartLocalPosition == dragStartLocalPosition) &&
            (identical(
                    other.dragUpdateLocalPosition, dragUpdateLocalPosition) ||
                other.dragUpdateLocalPosition == dragUpdateLocalPosition) &&
            (identical(other.isDragging, isDragging) ||
                other.isDragging == isDragging));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedComponentId,
      draggedComponentId,
      dragStartLocalPosition,
      dragUpdateLocalPosition,
      isDragging);

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
      {final String? selectedComponentId,
      final String? draggedComponentId,
      @OffsetConverter() final Offset? dragStartLocalPosition,
      @OffsetConverter() final Offset? dragUpdateLocalPosition,
      final bool isDragging}) = _$InteractionStateImpl;

  @override
  String? get selectedComponentId;
  @override
  String? get draggedComponentId;
  @override
  @OffsetConverter()
  Offset? get dragStartLocalPosition;
  @override
  @OffsetConverter()
  Offset? get dragUpdateLocalPosition;
  @override
  bool get isDragging;

  /// Create a copy of InteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InteractionStateImplCopyWith<_$InteractionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HistoryState {
  List<String> get commands => throw _privateConstructorUsedError;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryStateCopyWith<HistoryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryStateCopyWith<$Res> {
  factory $HistoryStateCopyWith(
          HistoryState value, $Res Function(HistoryState) then) =
      _$HistoryStateCopyWithImpl<$Res, HistoryState>;
  @useResult
  $Res call({List<String> commands});
}

/// @nodoc
class _$HistoryStateCopyWithImpl<$Res, $Val extends HistoryState>
    implements $HistoryStateCopyWith<$Res> {
  _$HistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commands = null,
  }) {
    return _then(_value.copyWith(
      commands: null == commands
          ? _value.commands
          : commands // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryStateImplCopyWith<$Res>
    implements $HistoryStateCopyWith<$Res> {
  factory _$$HistoryStateImplCopyWith(
          _$HistoryStateImpl value, $Res Function(_$HistoryStateImpl) then) =
      __$$HistoryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> commands});
}

/// @nodoc
class __$$HistoryStateImplCopyWithImpl<$Res>
    extends _$HistoryStateCopyWithImpl<$Res, _$HistoryStateImpl>
    implements _$$HistoryStateImplCopyWith<$Res> {
  __$$HistoryStateImplCopyWithImpl(
      _$HistoryStateImpl _value, $Res Function(_$HistoryStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commands = null,
  }) {
    return _then(_$HistoryStateImpl(
      commands: null == commands
          ? _value._commands
          : commands // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$HistoryStateImpl implements _HistoryState {
  const _$HistoryStateImpl({final List<String> commands = const []})
      : _commands = commands;

  final List<String> _commands;
  @override
  @JsonKey()
  List<String> get commands {
    if (_commands is EqualUnmodifiableListView) return _commands;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commands);
  }

  @override
  String toString() {
    return 'HistoryState(commands: $commands)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryStateImpl &&
            const DeepCollectionEquality().equals(other._commands, _commands));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_commands));

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryStateImplCopyWith<_$HistoryStateImpl> get copyWith =>
      __$$HistoryStateImplCopyWithImpl<_$HistoryStateImpl>(this, _$identity);
}

abstract class _HistoryState implements HistoryState {
  const factory _HistoryState({final List<String> commands}) =
      _$HistoryStateImpl;

  @override
  List<String> get commands;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryStateImplCopyWith<_$HistoryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
