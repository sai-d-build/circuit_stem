// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

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
      throw _privateConstructorUsedError; // ✅ REQUIRED: Error handling
  List<Wire> get wires =>
      throw _privateConstructorUsedError; // ✅ REQUIRED: Wire management
  Offset? get wireDrawStartPos =>
      throw _privateConstructorUsedError; // ✅ REQUIRED: Wire drawing state
  bool get isDrawingWire =>
      throw _privateConstructorUsedError; // ✅ REQUIRED: Wire interaction
  int? get hoveredCellIndex => throw _privateConstructorUsedError;

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
      bool isDrawingWire,
      int? hoveredCellIndex});

  $LevelDefinitionCopyWith<$Res>? get currentLevel;
  $SimulationResultCopyWith<$Res>? get simulationResult;
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
    Object? hoveredCellIndex = freezed,
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
      hoveredCellIndex: freezed == hoveredCellIndex
          ? _value.hoveredCellIndex
          : hoveredCellIndex // ignore: cast_nullable_to_non_nullable
              as int?,
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
      bool isDrawingWire,
      int? hoveredCellIndex});

  @override
  $LevelDefinitionCopyWith<$Res>? get currentLevel;
  @override
  $SimulationResultCopyWith<$Res>? get simulationResult;
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
    Object? hoveredCellIndex = freezed,
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
      hoveredCellIndex: freezed == hoveredCellIndex
          ? _value.hoveredCellIndex
          : hoveredCellIndex // ignore: cast_nullable_to_non_nullable
              as int?,
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
      this.isDrawingWire = false,
      this.hoveredCellIndex})
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
// ✅ REQUIRED: Error handling
  final List<Wire> _wires;
// ✅ REQUIRED: Error handling
  @override
  @JsonKey()
  List<Wire> get wires {
    if (_wires is EqualUnmodifiableListView) return _wires;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wires);
  }

// ✅ REQUIRED: Wire management
  @override
  final Offset? wireDrawStartPos;
// ✅ REQUIRED: Wire drawing state
  @override
  @JsonKey()
  final bool isDrawingWire;
// ✅ REQUIRED: Wire interaction
  @override
  final int? hoveredCellIndex;

  @override
  String toString() {
    return 'GameState(grid: $grid, isPaused: $isPaused, isWin: $isWin, currentLevel: $currentLevel, simulationResult: $simulationResult, lastUpdated: $lastUpdated, isDebugOverlayVisible: $isDebugOverlayVisible, interactionState: $interactionState, history: $history, error: $error, wires: $wires, wireDrawStartPos: $wireDrawStartPos, isDrawingWire: $isDrawingWire, hoveredCellIndex: $hoveredCellIndex)';
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
                other.isDrawingWire == isDrawingWire) &&
            (identical(other.hoveredCellIndex, hoveredCellIndex) ||
                other.hoveredCellIndex == hoveredCellIndex));
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
      isDrawingWire,
      hoveredCellIndex);

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
      final bool isDrawingWire,
      final int? hoveredCellIndex}) = _$GameStateImpl;

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
  String? get error; // ✅ REQUIRED: Error handling
  @override
  List<Wire> get wires; // ✅ REQUIRED: Wire management
  @override
  Offset? get wireDrawStartPos; // ✅ REQUIRED: Wire drawing state
  @override
  bool get isDrawingWire; // ✅ REQUIRED: Wire interaction
  @override
  int? get hoveredCellIndex;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
