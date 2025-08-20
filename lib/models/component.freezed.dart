// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'component.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CellOffset {
  int get x => throw _privateConstructorUsedError;
  int get y => throw _privateConstructorUsedError;

  /// Create a copy of CellOffset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CellOffsetCopyWith<CellOffset> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CellOffsetCopyWith<$Res> {
  factory $CellOffsetCopyWith(
          CellOffset value, $Res Function(CellOffset) then) =
      _$CellOffsetCopyWithImpl<$Res, CellOffset>;
  @useResult
  $Res call({int x, int y});
}

/// @nodoc
class _$CellOffsetCopyWithImpl<$Res, $Val extends CellOffset>
    implements $CellOffsetCopyWith<$Res> {
  _$CellOffsetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CellOffset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_value.copyWith(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as int,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CellOffsetImplCopyWith<$Res>
    implements $CellOffsetCopyWith<$Res> {
  factory _$$CellOffsetImplCopyWith(
          _$CellOffsetImpl value, $Res Function(_$CellOffsetImpl) then) =
      __$$CellOffsetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int x, int y});
}

/// @nodoc
class __$$CellOffsetImplCopyWithImpl<$Res>
    extends _$CellOffsetCopyWithImpl<$Res, _$CellOffsetImpl>
    implements _$$CellOffsetImplCopyWith<$Res> {
  __$$CellOffsetImplCopyWithImpl(
      _$CellOffsetImpl _value, $Res Function(_$CellOffsetImpl) _then)
      : super(_value, _then);

  /// Create a copy of CellOffset
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_$CellOffsetImpl(
      null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as int,
      null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$CellOffsetImpl extends _CellOffset with DiagnosticableTreeMixin {
  const _$CellOffsetImpl(this.x, this.y) : super._();

  @override
  final int x;
  @override
  final int y;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CellOffset(x: $x, y: $y)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CellOffset'))
      ..add(DiagnosticsProperty('x', x))
      ..add(DiagnosticsProperty('y', y));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CellOffsetImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @override
  int get hashCode => Object.hash(runtimeType, x, y);

  /// Create a copy of CellOffset
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CellOffsetImplCopyWith<_$CellOffsetImpl> get copyWith =>
      __$$CellOffsetImplCopyWithImpl<_$CellOffsetImpl>(this, _$identity);
}

abstract class _CellOffset extends CellOffset {
  const factory _CellOffset(final int x, final int y) = _$CellOffsetImpl;
  const _CellOffset._() : super._();

  @override
  int get x;
  @override
  int get y;

  /// Create a copy of CellOffset
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CellOffsetImplCopyWith<_$CellOffsetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TerminalSpec {
  CellOffset get offset => throw _privateConstructorUsedError;
  Dir get direction => throw _privateConstructorUsedError;
  TerminalType get type => throw _privateConstructorUsedError;

  /// Create a copy of TerminalSpec
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TerminalSpecCopyWith<TerminalSpec> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TerminalSpecCopyWith<$Res> {
  factory $TerminalSpecCopyWith(
          TerminalSpec value, $Res Function(TerminalSpec) then) =
      _$TerminalSpecCopyWithImpl<$Res, TerminalSpec>;
  @useResult
  $Res call({CellOffset offset, Dir direction, TerminalType type});

  $CellOffsetCopyWith<$Res> get offset;
}

/// @nodoc
class _$TerminalSpecCopyWithImpl<$Res, $Val extends TerminalSpec>
    implements $TerminalSpecCopyWith<$Res> {
  _$TerminalSpecCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TerminalSpec
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = null,
    Object? direction = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as CellOffset,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as Dir,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TerminalType,
    ) as $Val);
  }

  /// Create a copy of TerminalSpec
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CellOffsetCopyWith<$Res> get offset {
    return $CellOffsetCopyWith<$Res>(_value.offset, (value) {
      return _then(_value.copyWith(offset: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TerminalSpecImplCopyWith<$Res>
    implements $TerminalSpecCopyWith<$Res> {
  factory _$$TerminalSpecImplCopyWith(
          _$TerminalSpecImpl value, $Res Function(_$TerminalSpecImpl) then) =
      __$$TerminalSpecImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CellOffset offset, Dir direction, TerminalType type});

  @override
  $CellOffsetCopyWith<$Res> get offset;
}

/// @nodoc
class __$$TerminalSpecImplCopyWithImpl<$Res>
    extends _$TerminalSpecCopyWithImpl<$Res, _$TerminalSpecImpl>
    implements _$$TerminalSpecImplCopyWith<$Res> {
  __$$TerminalSpecImplCopyWithImpl(
      _$TerminalSpecImpl _value, $Res Function(_$TerminalSpecImpl) _then)
      : super(_value, _then);

  /// Create a copy of TerminalSpec
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = null,
    Object? direction = null,
    Object? type = null,
  }) {
    return _then(_$TerminalSpecImpl(
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as CellOffset,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as Dir,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TerminalType,
    ));
  }
}

/// @nodoc

class _$TerminalSpecImpl with DiagnosticableTreeMixin implements _TerminalSpec {
  const _$TerminalSpecImpl(
      {required this.offset, required this.direction, required this.type});

  @override
  final CellOffset offset;
  @override
  final Dir direction;
  @override
  final TerminalType type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TerminalSpec(offset: $offset, direction: $direction, type: $type)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TerminalSpec'))
      ..add(DiagnosticsProperty('offset', offset))
      ..add(DiagnosticsProperty('direction', direction))
      ..add(DiagnosticsProperty('type', type));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TerminalSpecImpl &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, offset, direction, type);

  /// Create a copy of TerminalSpec
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TerminalSpecImplCopyWith<_$TerminalSpecImpl> get copyWith =>
      __$$TerminalSpecImplCopyWithImpl<_$TerminalSpecImpl>(this, _$identity);
}

abstract class _TerminalSpec implements TerminalSpec {
  const factory _TerminalSpec(
      {required final CellOffset offset,
      required final Dir direction,
      required final TerminalType type}) = _$TerminalSpecImpl;

  @override
  CellOffset get offset;
  @override
  Dir get direction;
  @override
  TerminalType get type;

  /// Create a copy of TerminalSpec
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TerminalSpecImplCopyWith<_$TerminalSpecImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ComponentModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get r => throw _privateConstructorUsedError;
  int get c => throw _privateConstructorUsedError;
  int get rotation => throw _privateConstructorUsedError;
  bool get isPowered => throw _privateConstructorUsedError;
  Map<String, dynamic> get state => throw _privateConstructorUsedError;
  List<CellOffset> get shapeOffsets => throw _privateConstructorUsedError;
  List<TerminalSpec> get terminals => throw _privateConstructorUsedError;
  List<List<int>> get internalConnections => throw _privateConstructorUsedError;
  List<dynamic> get behaviors => throw _privateConstructorUsedError;
  bool get isDraggable => throw _privateConstructorUsedError;

  /// Create a copy of ComponentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComponentModelCopyWith<ComponentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComponentModelCopyWith<$Res> {
  factory $ComponentModelCopyWith(
          ComponentModel value, $Res Function(ComponentModel) then) =
      _$ComponentModelCopyWithImpl<$Res, ComponentModel>;
  @useResult
  $Res call(
      {String id,
      String type,
      int r,
      int c,
      int rotation,
      bool isPowered,
      Map<String, dynamic> state,
      List<CellOffset> shapeOffsets,
      List<TerminalSpec> terminals,
      List<List<int>> internalConnections,
      List<dynamic> behaviors,
      bool isDraggable});
}

/// @nodoc
class _$ComponentModelCopyWithImpl<$Res, $Val extends ComponentModel>
    implements $ComponentModelCopyWith<$Res> {
  _$ComponentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComponentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? r = null,
    Object? c = null,
    Object? rotation = null,
    Object? isPowered = null,
    Object? state = null,
    Object? shapeOffsets = null,
    Object? terminals = null,
    Object? internalConnections = null,
    Object? behaviors = null,
    Object? isDraggable = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      r: null == r
          ? _value.r
          : r // ignore: cast_nullable_to_non_nullable
              as int,
      c: null == c
          ? _value.c
          : c // ignore: cast_nullable_to_non_nullable
              as int,
      rotation: null == rotation
          ? _value.rotation
          : rotation // ignore: cast_nullable_to_non_nullable
              as int,
      isPowered: null == isPowered
          ? _value.isPowered
          : isPowered // ignore: cast_nullable_to_non_nullable
              as bool,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      shapeOffsets: null == shapeOffsets
          ? _value.shapeOffsets
          : shapeOffsets // ignore: cast_nullable_to_non_nullable
              as List<CellOffset>,
      terminals: null == terminals
          ? _value.terminals
          : terminals // ignore: cast_nullable_to_non_nullable
              as List<TerminalSpec>,
      internalConnections: null == internalConnections
          ? _value.internalConnections
          : internalConnections // ignore: cast_nullable_to_non_nullable
              as List<List<int>>,
      behaviors: null == behaviors
          ? _value.behaviors
          : behaviors // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      isDraggable: null == isDraggable
          ? _value.isDraggable
          : isDraggable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComponentModelImplCopyWith<$Res>
    implements $ComponentModelCopyWith<$Res> {
  factory _$$ComponentModelImplCopyWith(_$ComponentModelImpl value,
          $Res Function(_$ComponentModelImpl) then) =
      __$$ComponentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      int r,
      int c,
      int rotation,
      bool isPowered,
      Map<String, dynamic> state,
      List<CellOffset> shapeOffsets,
      List<TerminalSpec> terminals,
      List<List<int>> internalConnections,
      List<dynamic> behaviors,
      bool isDraggable});
}

/// @nodoc
class __$$ComponentModelImplCopyWithImpl<$Res>
    extends _$ComponentModelCopyWithImpl<$Res, _$ComponentModelImpl>
    implements _$$ComponentModelImplCopyWith<$Res> {
  __$$ComponentModelImplCopyWithImpl(
      _$ComponentModelImpl _value, $Res Function(_$ComponentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComponentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? r = null,
    Object? c = null,
    Object? rotation = null,
    Object? isPowered = null,
    Object? state = null,
    Object? shapeOffsets = null,
    Object? terminals = null,
    Object? internalConnections = null,
    Object? behaviors = null,
    Object? isDraggable = null,
  }) {
    return _then(_$ComponentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      r: null == r
          ? _value.r
          : r // ignore: cast_nullable_to_non_nullable
              as int,
      c: null == c
          ? _value.c
          : c // ignore: cast_nullable_to_non_nullable
              as int,
      rotation: null == rotation
          ? _value.rotation
          : rotation // ignore: cast_nullable_to_non_nullable
              as int,
      isPowered: null == isPowered
          ? _value.isPowered
          : isPowered // ignore: cast_nullable_to_non_nullable
              as bool,
      state: null == state
          ? _value._state
          : state // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      shapeOffsets: null == shapeOffsets
          ? _value._shapeOffsets
          : shapeOffsets // ignore: cast_nullable_to_non_nullable
              as List<CellOffset>,
      terminals: null == terminals
          ? _value._terminals
          : terminals // ignore: cast_nullable_to_non_nullable
              as List<TerminalSpec>,
      internalConnections: null == internalConnections
          ? _value._internalConnections
          : internalConnections // ignore: cast_nullable_to_non_nullable
              as List<List<int>>,
      behaviors: null == behaviors
          ? _value._behaviors
          : behaviors // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      isDraggable: null == isDraggable
          ? _value.isDraggable
          : isDraggable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ComponentModelImpl extends _ComponentModel
    with DiagnosticableTreeMixin {
  const _$ComponentModelImpl(
      {required this.id,
      required this.type,
      required this.r,
      required this.c,
      this.rotation = 0,
      this.isPowered = false,
      final Map<String, dynamic> state = const {},
      final List<CellOffset> shapeOffsets = const [CellOffset(0, 0)],
      final List<TerminalSpec> terminals = const [
        TerminalSpec(
            offset: CellOffset(0, 0),
            direction: Dir.north,
            type: TerminalType.power),
        TerminalSpec(
            offset: CellOffset(0, 0),
            direction: Dir.south,
            type: TerminalType.power)
      ],
      final List<List<int>> internalConnections = const [],
      final List<dynamic> behaviors = const [],
      this.isDraggable = false})
      : _state = state,
        _shapeOffsets = shapeOffsets,
        _terminals = terminals,
        _internalConnections = internalConnections,
        _behaviors = behaviors,
        super._();

  @override
  final String id;
  @override
  final String type;
  @override
  final int r;
  @override
  final int c;
  @override
  @JsonKey()
  final int rotation;
  @override
  @JsonKey()
  final bool isPowered;
  final Map<String, dynamic> _state;
  @override
  @JsonKey()
  Map<String, dynamic> get state {
    if (_state is EqualUnmodifiableMapView) return _state;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_state);
  }

  final List<CellOffset> _shapeOffsets;
  @override
  @JsonKey()
  List<CellOffset> get shapeOffsets {
    if (_shapeOffsets is EqualUnmodifiableListView) return _shapeOffsets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shapeOffsets);
  }

  final List<TerminalSpec> _terminals;
  @override
  @JsonKey()
  List<TerminalSpec> get terminals {
    if (_terminals is EqualUnmodifiableListView) return _terminals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_terminals);
  }

  final List<List<int>> _internalConnections;
  @override
  @JsonKey()
  List<List<int>> get internalConnections {
    if (_internalConnections is EqualUnmodifiableListView)
      return _internalConnections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_internalConnections);
  }

  final List<dynamic> _behaviors;
  @override
  @JsonKey()
  List<dynamic> get behaviors {
    if (_behaviors is EqualUnmodifiableListView) return _behaviors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_behaviors);
  }

  @override
  @JsonKey()
  final bool isDraggable;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ComponentModel(id: $id, type: $type, r: $r, c: $c, rotation: $rotation, isPowered: $isPowered, state: $state, shapeOffsets: $shapeOffsets, terminals: $terminals, internalConnections: $internalConnections, behaviors: $behaviors, isDraggable: $isDraggable)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ComponentModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('r', r))
      ..add(DiagnosticsProperty('c', c))
      ..add(DiagnosticsProperty('rotation', rotation))
      ..add(DiagnosticsProperty('isPowered', isPowered))
      ..add(DiagnosticsProperty('state', state))
      ..add(DiagnosticsProperty('shapeOffsets', shapeOffsets))
      ..add(DiagnosticsProperty('terminals', terminals))
      ..add(DiagnosticsProperty('internalConnections', internalConnections))
      ..add(DiagnosticsProperty('behaviors', behaviors))
      ..add(DiagnosticsProperty('isDraggable', isDraggable));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComponentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.r, r) || other.r == r) &&
            (identical(other.c, c) || other.c == c) &&
            (identical(other.rotation, rotation) ||
                other.rotation == rotation) &&
            (identical(other.isPowered, isPowered) ||
                other.isPowered == isPowered) &&
            const DeepCollectionEquality().equals(other._state, _state) &&
            const DeepCollectionEquality()
                .equals(other._shapeOffsets, _shapeOffsets) &&
            const DeepCollectionEquality()
                .equals(other._terminals, _terminals) &&
            const DeepCollectionEquality()
                .equals(other._internalConnections, _internalConnections) &&
            const DeepCollectionEquality()
                .equals(other._behaviors, _behaviors) &&
            (identical(other.isDraggable, isDraggable) ||
                other.isDraggable == isDraggable));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      r,
      c,
      rotation,
      isPowered,
      const DeepCollectionEquality().hash(_state),
      const DeepCollectionEquality().hash(_shapeOffsets),
      const DeepCollectionEquality().hash(_terminals),
      const DeepCollectionEquality().hash(_internalConnections),
      const DeepCollectionEquality().hash(_behaviors),
      isDraggable);

  /// Create a copy of ComponentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComponentModelImplCopyWith<_$ComponentModelImpl> get copyWith =>
      __$$ComponentModelImplCopyWithImpl<_$ComponentModelImpl>(
          this, _$identity);
}

abstract class _ComponentModel extends ComponentModel {
  const factory _ComponentModel(
      {required final String id,
      required final String type,
      required final int r,
      required final int c,
      final int rotation,
      final bool isPowered,
      final Map<String, dynamic> state,
      final List<CellOffset> shapeOffsets,
      final List<TerminalSpec> terminals,
      final List<List<int>> internalConnections,
      final List<dynamic> behaviors,
      final bool isDraggable}) = _$ComponentModelImpl;
  const _ComponentModel._() : super._();

  @override
  String get id;
  @override
  String get type;
  @override
  int get r;
  @override
  int get c;
  @override
  int get rotation;
  @override
  bool get isPowered;
  @override
  Map<String, dynamic> get state;
  @override
  List<CellOffset> get shapeOffsets;
  @override
  List<TerminalSpec> get terminals;
  @override
  List<List<int>> get internalConnections;
  @override
  List<dynamic> get behaviors;
  @override
  bool get isDraggable;

  /// Create a copy of ComponentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComponentModelImplCopyWith<_$ComponentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
