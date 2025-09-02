// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circuit_netlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimComponentImpl _$$SimComponentImplFromJson(Map json) => $checkedCreate(
      r'_$SimComponentImpl',
      json,
      ($checkedConvert) {
        final val = _$SimComponentImpl(
          id: $checkedConvert('id', (v) => v as String),
          type: $checkedConvert(
              'type', (v) => $enumDecode(_$ComponentTypeEnumMap, v)),
          properties: $checkedConvert(
              'properties', (v) => Map<String, dynamic>.from(v as Map)),
          connectedNodes: $checkedConvert('connectedNodes',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
        );
        return val;
      },
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
  ComponentType.voltageSource: 'voltageSource',
  ComponentType.currentSource: 'currentSource',
};

_$SimConnectionImpl _$$SimConnectionImplFromJson(Map json) => $checkedCreate(
      r'_$SimConnectionImpl',
      json,
      ($checkedConvert) {
        final val = _$SimConnectionImpl(
          id: $checkedConvert('id', (v) => v as String),
          node1Id: $checkedConvert('node1Id', (v) => v as String),
          node2Id: $checkedConvert('node2Id', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SimConnectionImplToJson(_$SimConnectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'node1Id': instance.node1Id,
      'node2Id': instance.node2Id,
    };

_$SimNodeImpl _$$SimNodeImplFromJson(Map json) => $checkedCreate(
      r'_$SimNodeImpl',
      json,
      ($checkedConvert) {
        final val = _$SimNodeImpl(
          id: $checkedConvert('id', (v) => v as String),
          x: $checkedConvert('x', (v) => (v as num).toDouble()),
          y: $checkedConvert('y', (v) => (v as num).toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SimNodeImplToJson(_$SimNodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'x': instance.x,
      'y': instance.y,
    };

_$CircuitNetlistImpl _$$CircuitNetlistImplFromJson(Map json) => $checkedCreate(
      r'_$CircuitNetlistImpl',
      json,
      ($checkedConvert) {
        final val = _$CircuitNetlistImpl(
          components: $checkedConvert(
              'components',
              (v) => (v as List<dynamic>)
                  .map((e) => SimComponent.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList()),
          connections: $checkedConvert(
              'connections',
              (v) => (v as List<dynamic>)
                  .map((e) => SimConnection.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList()),
          nodes: $checkedConvert(
              'nodes',
              (v) => (v as Map).map(
                    (k, e) => MapEntry(k as String,
                        SimNode.fromJson(Map<String, dynamic>.from(e as Map))),
                  )),
          timestamp:
              $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$CircuitNetlistImplToJson(
        _$CircuitNetlistImpl instance) =>
    <String, dynamic>{
      'components': instance.components.map((e) => e.toJson()).toList(),
      'connections': instance.connections.map((e) => e.toJson()).toList(),
      'nodes': instance.nodes.map((k, e) => MapEntry(k, e.toJson())),
      'timestamp': instance.timestamp.toIso8601String(),
    };
