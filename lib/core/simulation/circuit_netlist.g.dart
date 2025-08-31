// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circuit_netlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimComponentImpl _$$SimComponentImplFromJson(Map<String, dynamic> json) =>
    _$SimComponentImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ComponentTypeEnumMap, json['type']),
      properties: json['properties'] as Map<String, dynamic>,
      connectedNodes: (json['connectedNodes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SimComponentImplToJson(_$SimComponentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ComponentTypeEnumMap[instance.type]!,
      'properties': instance.properties,
      'connectedNodes': instance.connectedNodes,
    };

const _$ComponentTypeEnumMap = {
  ComponentType.battery: 'battery',
  ComponentType.resistor: 'resistor',
  ComponentType.capacitor: 'capacitor',
  ComponentType.inductor: 'inductor',
  ComponentType.diode: 'diode',
  ComponentType.transistor: 'transistor',
  ComponentType.switch_: 'switch_',
  ComponentType.bulb: 'bulb',
  ComponentType.buzzer: 'buzzer',
  ComponentType.timer: 'timer',
  ComponentType.wire: 'wire',
  ComponentType.ground: 'ground',
};

_$SimConnectionImpl _$$SimConnectionImplFromJson(Map<String, dynamic> json) =>
    _$SimConnectionImpl(
      id: json['id'] as String,
      node1Id: json['node1Id'] as String,
      node2Id: json['node2Id'] as String,
    );

Map<String, dynamic> _$$SimConnectionImplToJson(_$SimConnectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'node1Id': instance.node1Id,
      'node2Id': instance.node2Id,
    };

_$SimNodeImpl _$$SimNodeImplFromJson(Map<String, dynamic> json) =>
    _$SimNodeImpl(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$$SimNodeImplToJson(_$SimNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'x': instance.x,
      'y': instance.y,
    };

_$CircuitNetlistImpl _$$CircuitNetlistImplFromJson(Map<String, dynamic> json) =>
    _$CircuitNetlistImpl(
      components: (json['components'] as List<dynamic>)
          .map((e) => SimComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      connections: (json['connections'] as List<dynamic>)
          .map((e) => SimConnection.fromJson(e as Map<String, dynamic>))
          .toList(),
      nodes: (json['nodes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, SimNode.fromJson(e as Map<String, dynamic>)),
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$CircuitNetlistImplToJson(
        _$CircuitNetlistImpl instance) =>
    <String, dynamic>{
      'components': instance.components,
      'connections': instance.connections,
      'nodes': instance.nodes,
      'timestamp': instance.timestamp.toIso8601String(),
    };
