// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_engine_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GameEngineState {
  Grid get grid => throw _privateConstructorUsedError;
  bool get isPaused => throw _privateConstructorUsedError;
  bool get isWin => throw _privateConstructorUsedError;
  LevelDefinition? get currentLevel => throw _privateConstructorUsedError;
  String? get draggedComponentId => throw _privateConstructorUsedError;
  String? get selectedComponentId => throw _privateConstructorUsedError;
  Offset? get dragPosition => throw _privateConstructorUsedError;
  bool get isShortCircuit => throw _privateConstructorUsedError;
  RenderState? get renderState => throw _privateConstructorUsedError;
  List<ComponentModel> get paletteComponents =>
      throw _privateConstructorUsedError;
  Set<String> get poweredBuzzerIds => throw _privateConstructorUsedError;

  /// Create a copy of GameEngineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameEngineStateCopyWith<GameEngineState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameEngineStateCopyWith<$Res> {
  factory $GameEngineStateCopyWith(
          GameEngineState value, $Res Function(GameEngineState) then) =
      _$GameEngineStateCopyWithImpl<$Res, GameEngineState>;
  @useResult
  $Res call(
      {Grid grid,
      bool isPaused,
      bool isWin,
      LevelDefinition? currentLevel,
      String? draggedComponentId,
      String? selectedComponentId,
      Offset? dragPosition,
      bool isShortCircuit,
      RenderState? renderState,
      List<ComponentModel> paletteComponents,
      Set<String> poweredBuzzerIds});

  $GridCopyWith<$Res> get grid;
  $LevelDefinitionCopyWith<$Res>? get currentLevel;
}

/// @nodoc
class _$GameEngineStateCopyWithImpl<$Res, $Val extends GameEngineState>
    implements $GameEngineStateCopyWith<$Res> {
  _$GameEngineStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameEngineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grid = null,
    Object? isPaused = null,
    Object? isWin = null,
    Object? currentLevel = freezed,
    Object? draggedComponentId = freezed,
    Object? selectedComponentId = freezed,
    Object? dragPosition = freezed,
    Object? isShortCircuit = null,
    Object? renderState = freezed,
    Object? paletteComponents = null,
    Object? poweredBuzzerIds = null,
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
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedComponentId: freezed == selectedComponentId
          ? _value.selectedComponentId
          : selectedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      dragPosition: freezed == dragPosition
          ? _value.dragPosition
          : dragPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      isShortCircuit: null == isShortCircuit
          ? _value.isShortCircuit
          : isShortCircuit // ignore: cast_nullable_to_non_nullable
              as bool,
      renderState: freezed == renderState
          ? _value.renderState
          : renderState // ignore: cast_nullable_to_non_nullable
              as RenderState?,
      paletteComponents: null == paletteComponents
          ? _value.paletteComponents
          : paletteComponents // ignore: cast_nullable_to_non_nullable
              as List<ComponentModel>,
      poweredBuzzerIds: null == poweredBuzzerIds
          ? _value.poweredBuzzerIds
          : poweredBuzzerIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ) as $Val);
  }

  /// Create a copy of GameEngineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridCopyWith<$Res> get grid {
    return $GridCopyWith<$Res>(_value.grid, (value) {
      return _then(_value.copyWith(grid: value) as $Val);
    });
  }

  /// Create a copy of GameEngineState
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
}

/// @nodoc
abstract class _$$GameEngineStateImplCopyWith<$Res>
    implements $GameEngineStateCopyWith<$Res> {
  factory _$$GameEngineStateImplCopyWith(_$GameEngineStateImpl value,
          $Res Function(_$GameEngineStateImpl) then) =
      __$$GameEngineStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Grid grid,
      bool isPaused,
      bool isWin,
      LevelDefinition? currentLevel,
      String? draggedComponentId,
      String? selectedComponentId,
      Offset? dragPosition,
      bool isShortCircuit,
      RenderState? renderState,
      List<ComponentModel> paletteComponents,
      Set<String> poweredBuzzerIds});

  @override
  $GridCopyWith<$Res> get grid;
  @override
  $LevelDefinitionCopyWith<$Res>? get currentLevel;
}

/// @nodoc
class __$$GameEngineStateImplCopyWithImpl<$Res>
    extends _$GameEngineStateCopyWithImpl<$Res, _$GameEngineStateImpl>
    implements _$$GameEngineStateImplCopyWith<$Res> {
  __$$GameEngineStateImplCopyWithImpl(
      _$GameEngineStateImpl _value, $Res Function(_$GameEngineStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameEngineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grid = null,
    Object? isPaused = null,
    Object? isWin = null,
    Object? currentLevel = freezed,
    Object? draggedComponentId = freezed,
    Object? selectedComponentId = freezed,
    Object? dragPosition = freezed,
    Object? isShortCircuit = null,
    Object? renderState = freezed,
    Object? paletteComponents = null,
    Object? poweredBuzzerIds = null,
  }) {
    return _then(_$GameEngineStateImpl(
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
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedComponentId: freezed == selectedComponentId
          ? _value.selectedComponentId
          : selectedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      dragPosition: freezed == dragPosition
          ? _value.dragPosition
          : dragPosition // ignore: cast_nullable_to_non_nullable
              as Offset?,
      isShortCircuit: null == isShortCircuit
          ? _value.isShortCircuit
          : isShortCircuit // ignore: cast_nullable_to_non_nullable
              as bool,
      renderState: freezed == renderState
          ? _value.renderState
          : renderState // ignore: cast_nullable_to_non_nullable
              as RenderState?,
      paletteComponents: null == paletteComponents
          ? _value._paletteComponents
          : paletteComponents // ignore: cast_nullable_to_non_nullable
              as List<ComponentModel>,
      poweredBuzzerIds: null == poweredBuzzerIds
          ? _value._poweredBuzzerIds
          : poweredBuzzerIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _$GameEngineStateImpl implements _GameEngineState {
  const _$GameEngineStateImpl(
      {required this.grid,
      required this.isPaused,
      required this.isWin,
      this.currentLevel,
      this.draggedComponentId,
      this.selectedComponentId,
      this.dragPosition,
      this.isShortCircuit = false,
      this.renderState,
      final List<ComponentModel> paletteComponents = const [],
      final Set<String> poweredBuzzerIds = const {}})
      : _paletteComponents = paletteComponents,
        _poweredBuzzerIds = poweredBuzzerIds;

  @override
  final Grid grid;
  @override
  final bool isPaused;
  @override
  final bool isWin;
  @override
  final LevelDefinition? currentLevel;
  @override
  final String? draggedComponentId;
  @override
  final String? selectedComponentId;
  @override
  final Offset? dragPosition;
  @override
  @JsonKey()
  final bool isShortCircuit;
  @override
  final RenderState? renderState;
  final List<ComponentModel> _paletteComponents;
  @override
  @JsonKey()
  List<ComponentModel> get paletteComponents {
    if (_paletteComponents is EqualUnmodifiableListView)
      return _paletteComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paletteComponents);
  }

  final Set<String> _poweredBuzzerIds;
  @override
  @JsonKey()
  Set<String> get poweredBuzzerIds {
    if (_poweredBuzzerIds is EqualUnmodifiableSetView) return _poweredBuzzerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_poweredBuzzerIds);
  }

  @override
  String toString() {
    return 'GameEngineState(grid: $grid, isPaused: $isPaused, isWin: $isWin, currentLevel: $currentLevel, draggedComponentId: $draggedComponentId, selectedComponentId: $selectedComponentId, dragPosition: $dragPosition, isShortCircuit: $isShortCircuit, renderState: $renderState, paletteComponents: $paletteComponents, poweredBuzzerIds: $poweredBuzzerIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameEngineStateImpl &&
            (identical(other.grid, grid) || other.grid == grid) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.isWin, isWin) || other.isWin == isWin) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.draggedComponentId, draggedComponentId) ||
                other.draggedComponentId == draggedComponentId) &&
            (identical(other.selectedComponentId, selectedComponentId) ||
                other.selectedComponentId == selectedComponentId) &&
            (identical(other.dragPosition, dragPosition) ||
                other.dragPosition == dragPosition) &&
            (identical(other.isShortCircuit, isShortCircuit) ||
                other.isShortCircuit == isShortCircuit) &&
            (identical(other.renderState, renderState) ||
                other.renderState == renderState) &&
            const DeepCollectionEquality()
                .equals(other._paletteComponents, _paletteComponents) &&
            const DeepCollectionEquality()
                .equals(other._poweredBuzzerIds, _poweredBuzzerIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      grid,
      isPaused,
      isWin,
      currentLevel,
      draggedComponentId,
      selectedComponentId,
      dragPosition,
      isShortCircuit,
      renderState,
      const DeepCollectionEquality().hash(_paletteComponents),
      const DeepCollectionEquality().hash(_poweredBuzzerIds));

  /// Create a copy of GameEngineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameEngineStateImplCopyWith<_$GameEngineStateImpl> get copyWith =>
      __$$GameEngineStateImplCopyWithImpl<_$GameEngineStateImpl>(
          this, _$identity);
}

abstract class _GameEngineState implements GameEngineState {
  const factory _GameEngineState(
      {required final Grid grid,
      required final bool isPaused,
      required final bool isWin,
      final LevelDefinition? currentLevel,
      final String? draggedComponentId,
      final String? selectedComponentId,
      final Offset? dragPosition,
      final bool isShortCircuit,
      final RenderState? renderState,
      final List<ComponentModel> paletteComponents,
      final Set<String> poweredBuzzerIds}) = _$GameEngineStateImpl;

  @override
  Grid get grid;
  @override
  bool get isPaused;
  @override
  bool get isWin;
  @override
  LevelDefinition? get currentLevel;
  @override
  String? get draggedComponentId;
  @override
  String? get selectedComponentId;
  @override
  Offset? get dragPosition;
  @override
  bool get isShortCircuit;
  @override
  RenderState? get renderState;
  @override
  List<ComponentModel> get paletteComponents;
  @override
  Set<String> get poweredBuzzerIds;

  /// Create a copy of GameEngineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameEngineStateImplCopyWith<_$GameEngineStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
