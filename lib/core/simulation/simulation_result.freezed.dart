// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simulation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SimulationResult _$SimulationResultFromJson(Map<String, dynamic> json) {
  return _SimulationResult.fromJson(json);
}

/// @nodoc
mixin _$SimulationResult {
  Map<String, double> get nodeVoltages => throw _privateConstructorUsedError;
  Map<String, double> get branchCurrents => throw _privateConstructorUsedError;
  Map<String, ComponentState> get componentStates =>
      throw _privateConstructorUsedError;
  Map<String, ConnectionState> get connectionStates =>
      throw _privateConstructorUsedError;
  List<SimulationDiagnostic> get diagnostics =>
      throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;

  /// Serializes this SimulationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimulationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimulationResultCopyWith<SimulationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimulationResultCopyWith<$Res> {
  factory $SimulationResultCopyWith(
          SimulationResult value, $Res Function(SimulationResult) then) =
      _$SimulationResultCopyWithImpl<$Res, SimulationResult>;
  @useResult
  $Res call(
      {Map<String, double> nodeVoltages,
      Map<String, double> branchCurrents,
      Map<String, ComponentState> componentStates,
      Map<String, ConnectionState> connectionStates,
      List<SimulationDiagnostic> diagnostics,
      DateTime timestamp,
      bool isValid});
}

/// @nodoc
class _$SimulationResultCopyWithImpl<$Res, $Val extends SimulationResult>
    implements $SimulationResultCopyWith<$Res> {
  _$SimulationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimulationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nodeVoltages = null,
    Object? branchCurrents = null,
    Object? componentStates = null,
    Object? connectionStates = null,
    Object? diagnostics = null,
    Object? timestamp = null,
    Object? isValid = null,
  }) {
    return _then(_value.copyWith(
      nodeVoltages: null == nodeVoltages
          ? _value.nodeVoltages
          : nodeVoltages // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      branchCurrents: null == branchCurrents
          ? _value.branchCurrents
          : branchCurrents // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      componentStates: null == componentStates
          ? _value.componentStates
          : componentStates // ignore: cast_nullable_to_non_nullable
              as Map<String, ComponentState>,
      connectionStates: null == connectionStates
          ? _value.connectionStates
          : connectionStates // ignore: cast_nullable_to_non_nullable
              as Map<String, ConnectionState>,
      diagnostics: null == diagnostics
          ? _value.diagnostics
          : diagnostics // ignore: cast_nullable_to_non_nullable
              as List<SimulationDiagnostic>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimulationResultImplCopyWith<$Res>
    implements $SimulationResultCopyWith<$Res> {
  factory _$$SimulationResultImplCopyWith(_$SimulationResultImpl value,
          $Res Function(_$SimulationResultImpl) then) =
      __$$SimulationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, double> nodeVoltages,
      Map<String, double> branchCurrents,
      Map<String, ComponentState> componentStates,
      Map<String, ConnectionState> connectionStates,
      List<SimulationDiagnostic> diagnostics,
      DateTime timestamp,
      bool isValid});
}

/// @nodoc
class __$$SimulationResultImplCopyWithImpl<$Res>
    extends _$SimulationResultCopyWithImpl<$Res, _$SimulationResultImpl>
    implements _$$SimulationResultImplCopyWith<$Res> {
  __$$SimulationResultImplCopyWithImpl(_$SimulationResultImpl _value,
      $Res Function(_$SimulationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimulationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nodeVoltages = null,
    Object? branchCurrents = null,
    Object? componentStates = null,
    Object? connectionStates = null,
    Object? diagnostics = null,
    Object? timestamp = null,
    Object? isValid = null,
  }) {
    return _then(_$SimulationResultImpl(
      nodeVoltages: null == nodeVoltages
          ? _value._nodeVoltages
          : nodeVoltages // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      branchCurrents: null == branchCurrents
          ? _value._branchCurrents
          : branchCurrents // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      componentStates: null == componentStates
          ? _value._componentStates
          : componentStates // ignore: cast_nullable_to_non_nullable
              as Map<String, ComponentState>,
      connectionStates: null == connectionStates
          ? _value._connectionStates
          : connectionStates // ignore: cast_nullable_to_non_nullable
              as Map<String, ConnectionState>,
      diagnostics: null == diagnostics
          ? _value._diagnostics
          : diagnostics // ignore: cast_nullable_to_non_nullable
              as List<SimulationDiagnostic>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimulationResultImpl implements _SimulationResult {
  const _$SimulationResultImpl(
      {required final Map<String, double> nodeVoltages,
      required final Map<String, double> branchCurrents,
      required final Map<String, ComponentState> componentStates,
      required final Map<String, ConnectionState> connectionStates,
      required final List<SimulationDiagnostic> diagnostics,
      required this.timestamp,
      required this.isValid})
      : _nodeVoltages = nodeVoltages,
        _branchCurrents = branchCurrents,
        _componentStates = componentStates,
        _connectionStates = connectionStates,
        _diagnostics = diagnostics;

  factory _$SimulationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimulationResultImplFromJson(json);

  final Map<String, double> _nodeVoltages;
  @override
  Map<String, double> get nodeVoltages {
    if (_nodeVoltages is EqualUnmodifiableMapView) return _nodeVoltages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nodeVoltages);
  }

  final Map<String, double> _branchCurrents;
  @override
  Map<String, double> get branchCurrents {
    if (_branchCurrents is EqualUnmodifiableMapView) return _branchCurrents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_branchCurrents);
  }

  final Map<String, ComponentState> _componentStates;
  @override
  Map<String, ComponentState> get componentStates {
    if (_componentStates is EqualUnmodifiableMapView) return _componentStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_componentStates);
  }

  final Map<String, ConnectionState> _connectionStates;
  @override
  Map<String, ConnectionState> get connectionStates {
    if (_connectionStates is EqualUnmodifiableMapView) return _connectionStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_connectionStates);
  }

  final List<SimulationDiagnostic> _diagnostics;
  @override
  List<SimulationDiagnostic> get diagnostics {
    if (_diagnostics is EqualUnmodifiableListView) return _diagnostics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diagnostics);
  }

  @override
  final DateTime timestamp;
  @override
  final bool isValid;

  @override
  String toString() {
    return 'SimulationResult(nodeVoltages: $nodeVoltages, branchCurrents: $branchCurrents, componentStates: $componentStates, connectionStates: $connectionStates, diagnostics: $diagnostics, timestamp: $timestamp, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationResultImpl &&
            const DeepCollectionEquality()
                .equals(other._nodeVoltages, _nodeVoltages) &&
            const DeepCollectionEquality()
                .equals(other._branchCurrents, _branchCurrents) &&
            const DeepCollectionEquality()
                .equals(other._componentStates, _componentStates) &&
            const DeepCollectionEquality()
                .equals(other._connectionStates, _connectionStates) &&
            const DeepCollectionEquality()
                .equals(other._diagnostics, _diagnostics) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isValid, isValid) || other.isValid == isValid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_nodeVoltages),
      const DeepCollectionEquality().hash(_branchCurrents),
      const DeepCollectionEquality().hash(_componentStates),
      const DeepCollectionEquality().hash(_connectionStates),
      const DeepCollectionEquality().hash(_diagnostics),
      timestamp,
      isValid);

  /// Create a copy of SimulationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationResultImplCopyWith<_$SimulationResultImpl> get copyWith =>
      __$$SimulationResultImplCopyWithImpl<_$SimulationResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimulationResultImplToJson(
      this,
    );
  }
}

abstract class _SimulationResult implements SimulationResult {
  const factory _SimulationResult(
      {required final Map<String, double> nodeVoltages,
      required final Map<String, double> branchCurrents,
      required final Map<String, ComponentState> componentStates,
      required final Map<String, ConnectionState> connectionStates,
      required final List<SimulationDiagnostic> diagnostics,
      required final DateTime timestamp,
      required final bool isValid}) = _$SimulationResultImpl;

  factory _SimulationResult.fromJson(Map<String, dynamic> json) =
      _$SimulationResultImpl.fromJson;

  @override
  Map<String, double> get nodeVoltages;
  @override
  Map<String, double> get branchCurrents;
  @override
  Map<String, ComponentState> get componentStates;
  @override
  Map<String, ConnectionState> get connectionStates;
  @override
  List<SimulationDiagnostic> get diagnostics;
  @override
  DateTime get timestamp;
  @override
  bool get isValid;

  /// Create a copy of SimulationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimulationResultImplCopyWith<_$SimulationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ComponentState _$ComponentStateFromJson(Map<String, dynamic> json) {
  return _ComponentState.fromJson(json);
}

/// @nodoc
mixin _$ComponentState {
  String get id => throw _privateConstructorUsedError;
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;

  /// Serializes this ComponentState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ComponentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComponentStateCopyWith<ComponentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComponentStateCopyWith<$Res> {
  factory $ComponentStateCopyWith(
          ComponentState value, $Res Function(ComponentState) then) =
      _$ComponentStateCopyWithImpl<$Res, ComponentState>;
  @useResult
  $Res call({String id, Map<String, dynamic> properties});
}

/// @nodoc
class _$ComponentStateCopyWithImpl<$Res, $Val extends ComponentState>
    implements $ComponentStateCopyWith<$Res> {
  _$ComponentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComponentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? properties = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ComponentStateImplCopyWith<$Res>
    implements $ComponentStateCopyWith<$Res> {
  factory _$$ComponentStateImplCopyWith(_$ComponentStateImpl value,
          $Res Function(_$ComponentStateImpl) then) =
      __$$ComponentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, Map<String, dynamic> properties});
}

/// @nodoc
class __$$ComponentStateImplCopyWithImpl<$Res>
    extends _$ComponentStateCopyWithImpl<$Res, _$ComponentStateImpl>
    implements _$$ComponentStateImplCopyWith<$Res> {
  __$$ComponentStateImplCopyWithImpl(
      _$ComponentStateImpl _value, $Res Function(_$ComponentStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ComponentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? properties = null,
  }) {
    return _then(_$ComponentStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ComponentStateImpl implements _ComponentState {
  const _$ComponentStateImpl(
      {required this.id, required final Map<String, dynamic> properties})
      : _properties = properties;

  factory _$ComponentStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComponentStateImplFromJson(json);

  @override
  final String id;
  final Map<String, dynamic> _properties;
  @override
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  String toString() {
    return 'ComponentState(id: $id, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComponentStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, const DeepCollectionEquality().hash(_properties));

  /// Create a copy of ComponentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComponentStateImplCopyWith<_$ComponentStateImpl> get copyWith =>
      __$$ComponentStateImplCopyWithImpl<_$ComponentStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComponentStateImplToJson(
      this,
    );
  }
}

abstract class _ComponentState implements ComponentState {
  const factory _ComponentState(
      {required final String id,
      required final Map<String, dynamic> properties}) = _$ComponentStateImpl;

  factory _ComponentState.fromJson(Map<String, dynamic> json) =
      _$ComponentStateImpl.fromJson;

  @override
  String get id;
  @override
  Map<String, dynamic> get properties;

  /// Create a copy of ComponentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComponentStateImplCopyWith<_$ComponentStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConnectionState _$ConnectionStateFromJson(Map<String, dynamic> json) {
  return _ConnectionState.fromJson(json);
}

/// @nodoc
mixin _$ConnectionState {
  String get id => throw _privateConstructorUsedError;
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;

  /// Serializes this ConnectionState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionStateCopyWith<ConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionStateCopyWith<$Res> {
  factory $ConnectionStateCopyWith(
          ConnectionState value, $Res Function(ConnectionState) then) =
      _$ConnectionStateCopyWithImpl<$Res, ConnectionState>;
  @useResult
  $Res call({String id, Map<String, dynamic> properties});
}

/// @nodoc
class _$ConnectionStateCopyWithImpl<$Res, $Val extends ConnectionState>
    implements $ConnectionStateCopyWith<$Res> {
  _$ConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? properties = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConnectionStateImplCopyWith<$Res>
    implements $ConnectionStateCopyWith<$Res> {
  factory _$$ConnectionStateImplCopyWith(_$ConnectionStateImpl value,
          $Res Function(_$ConnectionStateImpl) then) =
      __$$ConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, Map<String, dynamic> properties});
}

/// @nodoc
class __$$ConnectionStateImplCopyWithImpl<$Res>
    extends _$ConnectionStateCopyWithImpl<$Res, _$ConnectionStateImpl>
    implements _$$ConnectionStateImplCopyWith<$Res> {
  __$$ConnectionStateImplCopyWithImpl(
      _$ConnectionStateImpl _value, $Res Function(_$ConnectionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? properties = null,
  }) {
    return _then(_$ConnectionStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionStateImpl implements _ConnectionState {
  const _$ConnectionStateImpl(
      {required this.id, required final Map<String, dynamic> properties})
      : _properties = properties;

  factory _$ConnectionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionStateImplFromJson(json);

  @override
  final String id;
  final Map<String, dynamic> _properties;
  @override
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  String toString() {
    return 'ConnectionState(id: $id, properties: $properties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, const DeepCollectionEquality().hash(_properties));

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      __$$ConnectionStateImplCopyWithImpl<_$ConnectionStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionStateImplToJson(
      this,
    );
  }
}

abstract class _ConnectionState implements ConnectionState {
  const factory _ConnectionState(
      {required final String id,
      required final Map<String, dynamic> properties}) = _$ConnectionStateImpl;

  factory _ConnectionState.fromJson(Map<String, dynamic> json) =
      _$ConnectionStateImpl.fromJson;

  @override
  String get id;
  @override
  Map<String, dynamic> get properties;

  /// Create a copy of ConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionStateImplCopyWith<_$ConnectionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimulationDiagnostic _$SimulationDiagnosticFromJson(Map<String, dynamic> json) {
  return _SimulationDiagnostic.fromJson(json);
}

/// @nodoc
mixin _$SimulationDiagnostic {
  String get message => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  String? get componentId => throw _privateConstructorUsedError;

  /// Serializes this SimulationDiagnostic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimulationDiagnostic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimulationDiagnosticCopyWith<SimulationDiagnostic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimulationDiagnosticCopyWith<$Res> {
  factory $SimulationDiagnosticCopyWith(SimulationDiagnostic value,
          $Res Function(SimulationDiagnostic) then) =
      _$SimulationDiagnosticCopyWithImpl<$Res, SimulationDiagnostic>;
  @useResult
  $Res call({String message, String level, String? componentId});
}

/// @nodoc
class _$SimulationDiagnosticCopyWithImpl<$Res,
        $Val extends SimulationDiagnostic>
    implements $SimulationDiagnosticCopyWith<$Res> {
  _$SimulationDiagnosticCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimulationDiagnostic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? level = null,
    Object? componentId = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      componentId: freezed == componentId
          ? _value.componentId
          : componentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimulationDiagnosticImplCopyWith<$Res>
    implements $SimulationDiagnosticCopyWith<$Res> {
  factory _$$SimulationDiagnosticImplCopyWith(_$SimulationDiagnosticImpl value,
          $Res Function(_$SimulationDiagnosticImpl) then) =
      __$$SimulationDiagnosticImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String level, String? componentId});
}

/// @nodoc
class __$$SimulationDiagnosticImplCopyWithImpl<$Res>
    extends _$SimulationDiagnosticCopyWithImpl<$Res, _$SimulationDiagnosticImpl>
    implements _$$SimulationDiagnosticImplCopyWith<$Res> {
  __$$SimulationDiagnosticImplCopyWithImpl(_$SimulationDiagnosticImpl _value,
      $Res Function(_$SimulationDiagnosticImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimulationDiagnostic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? level = null,
    Object? componentId = freezed,
  }) {
    return _then(_$SimulationDiagnosticImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      componentId: freezed == componentId
          ? _value.componentId
          : componentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimulationDiagnosticImpl implements _SimulationDiagnostic {
  const _$SimulationDiagnosticImpl(
      {required this.message, required this.level, this.componentId});

  factory _$SimulationDiagnosticImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimulationDiagnosticImplFromJson(json);

  @override
  final String message;
  @override
  final String level;
  @override
  final String? componentId;

  @override
  String toString() {
    return 'SimulationDiagnostic(message: $message, level: $level, componentId: $componentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationDiagnosticImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.componentId, componentId) ||
                other.componentId == componentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, level, componentId);

  /// Create a copy of SimulationDiagnostic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationDiagnosticImplCopyWith<_$SimulationDiagnosticImpl>
      get copyWith =>
          __$$SimulationDiagnosticImplCopyWithImpl<_$SimulationDiagnosticImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimulationDiagnosticImplToJson(
      this,
    );
  }
}

abstract class _SimulationDiagnostic implements SimulationDiagnostic {
  const factory _SimulationDiagnostic(
      {required final String message,
      required final String level,
      final String? componentId}) = _$SimulationDiagnosticImpl;

  factory _SimulationDiagnostic.fromJson(Map<String, dynamic> json) =
      _$SimulationDiagnosticImpl.fromJson;

  @override
  String get message;
  @override
  String get level;
  @override
  String? get componentId;

  /// Create a copy of SimulationDiagnostic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimulationDiagnosticImplCopyWith<_$SimulationDiagnosticImpl>
      get copyWith => throw _privateConstructorUsedError;
}
