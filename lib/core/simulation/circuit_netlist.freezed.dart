// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'circuit_netlist.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SimComponent _$SimComponentFromJson(Map<String, dynamic> json) {
  return _SimComponent.fromJson(json);
}

/// @nodoc
mixin _$SimComponent {
  String get id => throw _privateConstructorUsedError;
  ComponentType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;
  List<String> get connectedNodes => throw _privateConstructorUsedError;

  /// Serializes this SimComponent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimComponentCopyWith<SimComponent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimComponentCopyWith<$Res> {
  factory $SimComponentCopyWith(
          SimComponent value, $Res Function(SimComponent) then) =
      _$SimComponentCopyWithImpl<$Res, SimComponent>;
  @useResult
  $Res call(
      {String id,
      ComponentType type,
      Map<String, dynamic> properties,
      List<String> connectedNodes});
}

/// @nodoc
class _$SimComponentCopyWithImpl<$Res, $Val extends SimComponent>
    implements $SimComponentCopyWith<$Res> {
  _$SimComponentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? properties = null,
    Object? connectedNodes = null,
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
      properties: null == properties
          ? _value.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      connectedNodes: null == connectedNodes
          ? _value.connectedNodes
          : connectedNodes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimComponentImplCopyWith<$Res>
    implements $SimComponentCopyWith<$Res> {
  factory _$$SimComponentImplCopyWith(
          _$SimComponentImpl value, $Res Function(_$SimComponentImpl) then) =
      __$$SimComponentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ComponentType type,
      Map<String, dynamic> properties,
      List<String> connectedNodes});
}

/// @nodoc
class __$$SimComponentImplCopyWithImpl<$Res>
    extends _$SimComponentCopyWithImpl<$Res, _$SimComponentImpl>
    implements _$$SimComponentImplCopyWith<$Res> {
  __$$SimComponentImplCopyWithImpl(
      _$SimComponentImpl _value, $Res Function(_$SimComponentImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimComponent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? properties = null,
    Object? connectedNodes = null,
  }) {
    return _then(_$SimComponentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ComponentType,
      properties: null == properties
          ? _value._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      connectedNodes: null == connectedNodes
          ? _value._connectedNodes
          : connectedNodes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimComponentImpl implements _SimComponent {
  const _$SimComponentImpl(
      {required this.id,
      required this.type,
      required final Map<String, dynamic> properties,
      required final List<String> connectedNodes})
      : _properties = properties,
        _connectedNodes = connectedNodes;

  factory _$SimComponentImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimComponentImplFromJson(json);

  @override
  final String id;
  @override
  final ComponentType type;
  final Map<String, dynamic> _properties;
  @override
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  final List<String> _connectedNodes;
  @override
  List<String> get connectedNodes {
    if (_connectedNodes is EqualUnmodifiableListView) return _connectedNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_connectedNodes);
  }

  @override
  String toString() {
    return 'SimComponent(id: $id, type: $type, properties: $properties, connectedNodes: $connectedNodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimComponentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties) &&
            const DeepCollectionEquality()
                .equals(other._connectedNodes, _connectedNodes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      const DeepCollectionEquality().hash(_properties),
      const DeepCollectionEquality().hash(_connectedNodes));

  /// Create a copy of SimComponent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimComponentImplCopyWith<_$SimComponentImpl> get copyWith =>
      __$$SimComponentImplCopyWithImpl<_$SimComponentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimComponentImplToJson(
      this,
    );
  }
}

abstract class _SimComponent implements SimComponent {
  const factory _SimComponent(
      {required final String id,
      required final ComponentType type,
      required final Map<String, dynamic> properties,
      required final List<String> connectedNodes}) = _$SimComponentImpl;

  factory _SimComponent.fromJson(Map<String, dynamic> json) =
      _$SimComponentImpl.fromJson;

  @override
  String get id;
  @override
  ComponentType get type;
  @override
  Map<String, dynamic> get properties;
  @override
  List<String> get connectedNodes;

  /// Create a copy of SimComponent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimComponentImplCopyWith<_$SimComponentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimConnection _$SimConnectionFromJson(Map<String, dynamic> json) {
  return _SimConnection.fromJson(json);
}

/// @nodoc
mixin _$SimConnection {
  String get id => throw _privateConstructorUsedError;
  String get node1Id => throw _privateConstructorUsedError;
  String get node2Id => throw _privateConstructorUsedError;

  /// Serializes this SimConnection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimConnectionCopyWith<SimConnection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimConnectionCopyWith<$Res> {
  factory $SimConnectionCopyWith(
          SimConnection value, $Res Function(SimConnection) then) =
      _$SimConnectionCopyWithImpl<$Res, SimConnection>;
  @useResult
  $Res call({String id, String node1Id, String node2Id});
}

/// @nodoc
class _$SimConnectionCopyWithImpl<$Res, $Val extends SimConnection>
    implements $SimConnectionCopyWith<$Res> {
  _$SimConnectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? node1Id = null,
    Object? node2Id = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      node1Id: null == node1Id
          ? _value.node1Id
          : node1Id // ignore: cast_nullable_to_non_nullable
              as String,
      node2Id: null == node2Id
          ? _value.node2Id
          : node2Id // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimConnectionImplCopyWith<$Res>
    implements $SimConnectionCopyWith<$Res> {
  factory _$$SimConnectionImplCopyWith(
          _$SimConnectionImpl value, $Res Function(_$SimConnectionImpl) then) =
      __$$SimConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String node1Id, String node2Id});
}

/// @nodoc
class __$$SimConnectionImplCopyWithImpl<$Res>
    extends _$SimConnectionCopyWithImpl<$Res, _$SimConnectionImpl>
    implements _$$SimConnectionImplCopyWith<$Res> {
  __$$SimConnectionImplCopyWithImpl(
      _$SimConnectionImpl _value, $Res Function(_$SimConnectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? node1Id = null,
    Object? node2Id = null,
  }) {
    return _then(_$SimConnectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      node1Id: null == node1Id
          ? _value.node1Id
          : node1Id // ignore: cast_nullable_to_non_nullable
              as String,
      node2Id: null == node2Id
          ? _value.node2Id
          : node2Id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimConnectionImpl implements _SimConnection {
  const _$SimConnectionImpl(
      {required this.id, required this.node1Id, required this.node2Id});

  factory _$SimConnectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimConnectionImplFromJson(json);

  @override
  final String id;
  @override
  final String node1Id;
  @override
  final String node2Id;

  @override
  String toString() {
    return 'SimConnection(id: $id, node1Id: $node1Id, node2Id: $node2Id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimConnectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.node1Id, node1Id) || other.node1Id == node1Id) &&
            (identical(other.node2Id, node2Id) || other.node2Id == node2Id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, node1Id, node2Id);

  /// Create a copy of SimConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimConnectionImplCopyWith<_$SimConnectionImpl> get copyWith =>
      __$$SimConnectionImplCopyWithImpl<_$SimConnectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimConnectionImplToJson(
      this,
    );
  }
}

abstract class _SimConnection implements SimConnection {
  const factory _SimConnection(
      {required final String id,
      required final String node1Id,
      required final String node2Id}) = _$SimConnectionImpl;

  factory _SimConnection.fromJson(Map<String, dynamic> json) =
      _$SimConnectionImpl.fromJson;

  @override
  String get id;
  @override
  String get node1Id;
  @override
  String get node2Id;

  /// Create a copy of SimConnection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimConnectionImplCopyWith<_$SimConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SimNode _$SimNodeFromJson(Map<String, dynamic> json) {
  return _SimNode.fromJson(json);
}

/// @nodoc
mixin _$SimNode {
  String get id => throw _privateConstructorUsedError;
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;

  /// Serializes this SimNode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimNodeCopyWith<SimNode> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimNodeCopyWith<$Res> {
  factory $SimNodeCopyWith(SimNode value, $Res Function(SimNode) then) =
      _$SimNodeCopyWithImpl<$Res, SimNode>;
  @useResult
  $Res call({String id, double x, double y});
}

/// @nodoc
class _$SimNodeCopyWithImpl<$Res, $Val extends SimNode>
    implements $SimNodeCopyWith<$Res> {
  _$SimNodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimNodeImplCopyWith<$Res> implements $SimNodeCopyWith<$Res> {
  factory _$$SimNodeImplCopyWith(
          _$SimNodeImpl value, $Res Function(_$SimNodeImpl) then) =
      __$$SimNodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, double x, double y});
}

/// @nodoc
class __$$SimNodeImplCopyWithImpl<$Res>
    extends _$SimNodeCopyWithImpl<$Res, _$SimNodeImpl>
    implements _$$SimNodeImplCopyWith<$Res> {
  __$$SimNodeImplCopyWithImpl(
      _$SimNodeImpl _value, $Res Function(_$SimNodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimNode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_$SimNodeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimNodeImpl implements _SimNode {
  const _$SimNodeImpl({required this.id, required this.x, required this.y});

  factory _$SimNodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimNodeImplFromJson(json);

  @override
  final String id;
  @override
  final double x;
  @override
  final double y;

  @override
  String toString() {
    return 'SimNode(id: $id, x: $x, y: $y)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimNodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, x, y);

  /// Create a copy of SimNode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimNodeImplCopyWith<_$SimNodeImpl> get copyWith =>
      __$$SimNodeImplCopyWithImpl<_$SimNodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimNodeImplToJson(
      this,
    );
  }
}

abstract class _SimNode implements SimNode {
  const factory _SimNode(
      {required final String id,
      required final double x,
      required final double y}) = _$SimNodeImpl;

  factory _SimNode.fromJson(Map<String, dynamic> json) = _$SimNodeImpl.fromJson;

  @override
  String get id;
  @override
  double get x;
  @override
  double get y;

  /// Create a copy of SimNode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimNodeImplCopyWith<_$SimNodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CircuitNetlist _$CircuitNetlistFromJson(Map<String, dynamic> json) {
  return _CircuitNetlist.fromJson(json);
}

/// @nodoc
mixin _$CircuitNetlist {
  List<SimComponent> get components => throw _privateConstructorUsedError;
  List<SimConnection> get connections => throw _privateConstructorUsedError;
  Map<String, SimNode> get nodes => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this CircuitNetlist to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CircuitNetlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CircuitNetlistCopyWith<CircuitNetlist> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CircuitNetlistCopyWith<$Res> {
  factory $CircuitNetlistCopyWith(
          CircuitNetlist value, $Res Function(CircuitNetlist) then) =
      _$CircuitNetlistCopyWithImpl<$Res, CircuitNetlist>;
  @useResult
  $Res call(
      {List<SimComponent> components,
      List<SimConnection> connections,
      Map<String, SimNode> nodes,
      DateTime timestamp});
}

/// @nodoc
class _$CircuitNetlistCopyWithImpl<$Res, $Val extends CircuitNetlist>
    implements $CircuitNetlistCopyWith<$Res> {
  _$CircuitNetlistCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CircuitNetlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? components = null,
    Object? connections = null,
    Object? nodes = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      components: null == components
          ? _value.components
          : components // ignore: cast_nullable_to_non_nullable
              as List<SimComponent>,
      connections: null == connections
          ? _value.connections
          : connections // ignore: cast_nullable_to_non_nullable
              as List<SimConnection>,
      nodes: null == nodes
          ? _value.nodes
          : nodes // ignore: cast_nullable_to_non_nullable
              as Map<String, SimNode>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CircuitNetlistImplCopyWith<$Res>
    implements $CircuitNetlistCopyWith<$Res> {
  factory _$$CircuitNetlistImplCopyWith(_$CircuitNetlistImpl value,
          $Res Function(_$CircuitNetlistImpl) then) =
      __$$CircuitNetlistImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SimComponent> components,
      List<SimConnection> connections,
      Map<String, SimNode> nodes,
      DateTime timestamp});
}

/// @nodoc
class __$$CircuitNetlistImplCopyWithImpl<$Res>
    extends _$CircuitNetlistCopyWithImpl<$Res, _$CircuitNetlistImpl>
    implements _$$CircuitNetlistImplCopyWith<$Res> {
  __$$CircuitNetlistImplCopyWithImpl(
      _$CircuitNetlistImpl _value, $Res Function(_$CircuitNetlistImpl) _then)
      : super(_value, _then);

  /// Create a copy of CircuitNetlist
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? components = null,
    Object? connections = null,
    Object? nodes = null,
    Object? timestamp = null,
  }) {
    return _then(_$CircuitNetlistImpl(
      components: null == components
          ? _value._components
          : components // ignore: cast_nullable_to_non_nullable
              as List<SimComponent>,
      connections: null == connections
          ? _value._connections
          : connections // ignore: cast_nullable_to_non_nullable
              as List<SimConnection>,
      nodes: null == nodes
          ? _value._nodes
          : nodes // ignore: cast_nullable_to_non_nullable
              as Map<String, SimNode>,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CircuitNetlistImpl implements _CircuitNetlist {
  const _$CircuitNetlistImpl(
      {required final List<SimComponent> components,
      required final List<SimConnection> connections,
      required final Map<String, SimNode> nodes,
      required this.timestamp})
      : _components = components,
        _connections = connections,
        _nodes = nodes;

  factory _$CircuitNetlistImpl.fromJson(Map<String, dynamic> json) =>
      _$$CircuitNetlistImplFromJson(json);

  final List<SimComponent> _components;
  @override
  List<SimComponent> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  final List<SimConnection> _connections;
  @override
  List<SimConnection> get connections {
    if (_connections is EqualUnmodifiableListView) return _connections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_connections);
  }

  final Map<String, SimNode> _nodes;
  @override
  Map<String, SimNode> get nodes {
    if (_nodes is EqualUnmodifiableMapView) return _nodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nodes);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'CircuitNetlist(components: $components, connections: $connections, nodes: $nodes, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CircuitNetlistImpl &&
            const DeepCollectionEquality()
                .equals(other._components, _components) &&
            const DeepCollectionEquality()
                .equals(other._connections, _connections) &&
            const DeepCollectionEquality().equals(other._nodes, _nodes) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_components),
      const DeepCollectionEquality().hash(_connections),
      const DeepCollectionEquality().hash(_nodes),
      timestamp);

  /// Create a copy of CircuitNetlist
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CircuitNetlistImplCopyWith<_$CircuitNetlistImpl> get copyWith =>
      __$$CircuitNetlistImplCopyWithImpl<_$CircuitNetlistImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CircuitNetlistImplToJson(
      this,
    );
  }
}

abstract class _CircuitNetlist implements CircuitNetlist {
  const factory _CircuitNetlist(
      {required final List<SimComponent> components,
      required final List<SimConnection> connections,
      required final Map<String, SimNode> nodes,
      required final DateTime timestamp}) = _$CircuitNetlistImpl;

  factory _CircuitNetlist.fromJson(Map<String, dynamic> json) =
      _$CircuitNetlistImpl.fromJson;

  @override
  List<SimComponent> get components;
  @override
  List<SimConnection> get connections;
  @override
  Map<String, SimNode> get nodes;
  @override
  DateTime get timestamp;

  /// Create a copy of CircuitNetlist
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CircuitNetlistImplCopyWith<_$CircuitNetlistImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
