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
  List<ComponentModel> get availableComponents =>
      throw _privateConstructorUsedError;
  String? get draggedComponentId => throw _privateConstructorUsedError;
  bool get isShortCircuit => throw _privateConstructorUsedError;
  Map<String, bool> get poweredComponents => throw _privateConstructorUsedError;
  double get bulbIntensity => throw _privateConstructorUsedError;
  double get wireOffset => throw _privateConstructorUsedError;

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
      List<ComponentModel> availableComponents,
      String? draggedComponentId,
      bool isShortCircuit,
      Map<String, bool> poweredComponents,
      double bulbIntensity,
      double wireOffset});

  $GridCopyWith<$Res> get grid;
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
    Object? availableComponents = null,
    Object? draggedComponentId = freezed,
    Object? isShortCircuit = null,
    Object? poweredComponents = null,
    Object? bulbIntensity = null,
    Object? wireOffset = null,
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
      availableComponents: null == availableComponents
          ? _value.availableComponents
          : availableComponents // ignore: cast_nullable_to_non_nullable
              as List<ComponentModel>,
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      isShortCircuit: null == isShortCircuit
          ? _value.isShortCircuit
          : isShortCircuit // ignore: cast_nullable_to_non_nullable
              as bool,
      poweredComponents: null == poweredComponents
          ? _value.poweredComponents
          : poweredComponents // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      bulbIntensity: null == bulbIntensity
          ? _value.bulbIntensity
          : bulbIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      wireOffset: null == wireOffset
          ? _value.wireOffset
          : wireOffset // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GridCopyWith<$Res> get grid {
    return $GridCopyWith<$Res>(_value.grid, (value) {
      return _then(_value.copyWith(grid: value) as $Val);
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
      List<ComponentModel> availableComponents,
      String? draggedComponentId,
      bool isShortCircuit,
      Map<String, bool> poweredComponents,
      double bulbIntensity,
      double wireOffset});

  @override
  $GridCopyWith<$Res> get grid;
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
    Object? availableComponents = null,
    Object? draggedComponentId = freezed,
    Object? isShortCircuit = null,
    Object? poweredComponents = null,
    Object? bulbIntensity = null,
    Object? wireOffset = null,
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
      availableComponents: null == availableComponents
          ? _value._availableComponents
          : availableComponents // ignore: cast_nullable_to_non_nullable
              as List<ComponentModel>,
      draggedComponentId: freezed == draggedComponentId
          ? _value.draggedComponentId
          : draggedComponentId // ignore: cast_nullable_to_non_nullable
              as String?,
      isShortCircuit: null == isShortCircuit
          ? _value.isShortCircuit
          : isShortCircuit // ignore: cast_nullable_to_non_nullable
              as bool,
      poweredComponents: null == poweredComponents
          ? _value._poweredComponents
          : poweredComponents // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      bulbIntensity: null == bulbIntensity
          ? _value.bulbIntensity
          : bulbIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      wireOffset: null == wireOffset
          ? _value.wireOffset
          : wireOffset // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$GameStateImpl implements _GameState {
  const _$GameStateImpl(
      {required this.grid,
      required this.isPaused,
      required this.isWin,
      required final List<ComponentModel> availableComponents,
      this.draggedComponentId,
      this.isShortCircuit = false,
      final Map<String, bool> poweredComponents = const {},
      this.bulbIntensity = 0.0,
      this.wireOffset = 0.0})
      : _availableComponents = availableComponents,
        _poweredComponents = poweredComponents;

  @override
  final Grid grid;
  @override
  final bool isPaused;
  @override
  final bool isWin;
  final List<ComponentModel> _availableComponents;
  @override
  List<ComponentModel> get availableComponents {
    if (_availableComponents is EqualUnmodifiableListView)
      return _availableComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableComponents);
  }

  @override
  final String? draggedComponentId;
  @override
  @JsonKey()
  final bool isShortCircuit;
  final Map<String, bool> _poweredComponents;
  @override
  @JsonKey()
  Map<String, bool> get poweredComponents {
    if (_poweredComponents is EqualUnmodifiableMapView)
      return _poweredComponents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_poweredComponents);
  }

  @override
  @JsonKey()
  final double bulbIntensity;
  @override
  @JsonKey()
  final double wireOffset;

  @override
  String toString() {
    return 'GameState(grid: $grid, isPaused: $isPaused, isWin: $isWin, availableComponents: $availableComponents, draggedComponentId: $draggedComponentId, isShortCircuit: $isShortCircuit, poweredComponents: $poweredComponents, bulbIntensity: $bulbIntensity, wireOffset: $wireOffset)';
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
            const DeepCollectionEquality()
                .equals(other._availableComponents, _availableComponents) &&
            (identical(other.draggedComponentId, draggedComponentId) ||
                other.draggedComponentId == draggedComponentId) &&
            (identical(other.isShortCircuit, isShortCircuit) ||
                other.isShortCircuit == isShortCircuit) &&
            const DeepCollectionEquality()
                .equals(other._poweredComponents, _poweredComponents) &&
            (identical(other.bulbIntensity, bulbIntensity) ||
                other.bulbIntensity == bulbIntensity) &&
            (identical(other.wireOffset, wireOffset) ||
                other.wireOffset == wireOffset));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      grid,
      isPaused,
      isWin,
      const DeepCollectionEquality().hash(_availableComponents),
      draggedComponentId,
      isShortCircuit,
      const DeepCollectionEquality().hash(_poweredComponents),
      bulbIntensity,
      wireOffset);

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
      required final List<ComponentModel> availableComponents,
      final String? draggedComponentId,
      final bool isShortCircuit,
      final Map<String, bool> poweredComponents,
      final double bulbIntensity,
      final double wireOffset}) = _$GameStateImpl;

  @override
  Grid get grid;
  @override
  bool get isPaused;
  @override
  bool get isWin;
  @override
  List<ComponentModel> get availableComponents;
  @override
  String? get draggedComponentId;
  @override
  bool get isShortCircuit;
  @override
  Map<String, bool> get poweredComponents;
  @override
  double get bulbIntensity;
  @override
  double get wireOffset;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
