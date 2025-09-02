// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimulationResultImpl _$$SimulationResultImplFromJson(Map json) =>
    $checkedCreate(
      r'_$SimulationResultImpl',
      json,
      ($checkedConvert) {
        final val = _$SimulationResultImpl(
          nodeVoltages: $checkedConvert(
              'nodeVoltages',
              (v) => (v as Map).map(
                    (k, e) => MapEntry(k as String, (e as num).toDouble()),
                  )),
          branchCurrents: $checkedConvert(
              'branchCurrents',
              (v) => (v as Map).map(
                    (k, e) => MapEntry(k as String, (e as num).toDouble()),
                  )),
          componentStates: $checkedConvert(
              'componentStates',
              (v) => (v as Map).map(
                    (k, e) => MapEntry(
                        k as String,
                        ComponentState.fromJson(
                            Map<String, dynamic>.from(e as Map))),
                  )),
          connectionStates: $checkedConvert(
              'connectionStates',
              (v) => (v as Map).map(
                    (k, e) => MapEntry(
                        k as String,
                        ConnectionState.fromJson(
                            Map<String, dynamic>.from(e as Map))),
                  )),
          diagnostics: $checkedConvert(
              'diagnostics',
              (v) => (v as List<dynamic>)
                  .map((e) => SimulationDiagnostic.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList()),
          timestamp:
              $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
          isValid: $checkedConvert('isValid', (v) => v as bool),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SimulationResultImplToJson(
        _$SimulationResultImpl instance) =>
    <String, dynamic>{
      'nodeVoltages': instance.nodeVoltages,
      'branchCurrents': instance.branchCurrents,
      'componentStates':
          instance.componentStates.map((k, e) => MapEntry(k, e.toJson())),
      'connectionStates':
          instance.connectionStates.map((k, e) => MapEntry(k, e.toJson())),
      'diagnostics': instance.diagnostics.map((e) => e.toJson()).toList(),
      'timestamp': instance.timestamp.toIso8601String(),
      'isValid': instance.isValid,
    };

_$ComponentStateImpl _$$ComponentStateImplFromJson(Map json) => $checkedCreate(
      r'_$ComponentStateImpl',
      json,
      ($checkedConvert) {
        final val = _$ComponentStateImpl(
          id: $checkedConvert('id', (v) => v as String),
          properties: $checkedConvert(
              'properties', (v) => Map<String, dynamic>.from(v as Map)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ComponentStateImplToJson(
        _$ComponentStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'properties': instance.properties,
    };

_$ConnectionStateImpl _$$ConnectionStateImplFromJson(Map json) =>
    $checkedCreate(
      r'_$ConnectionStateImpl',
      json,
      ($checkedConvert) {
        final val = _$ConnectionStateImpl(
          id: $checkedConvert('id', (v) => v as String),
          properties: $checkedConvert(
              'properties', (v) => Map<String, dynamic>.from(v as Map)),
        );
        return val;
      },
    );

Map<String, dynamic> _$$ConnectionStateImplToJson(
        _$ConnectionStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'properties': instance.properties,
    };

_$SimulationDiagnosticImpl _$$SimulationDiagnosticImplFromJson(Map json) =>
    $checkedCreate(
      r'_$SimulationDiagnosticImpl',
      json,
      ($checkedConvert) {
        final val = _$SimulationDiagnosticImpl(
          message: $checkedConvert('message', (v) => v as String),
          level: $checkedConvert('level', (v) => v as String),
          componentId: $checkedConvert('componentId', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$SimulationDiagnosticImplToJson(
        _$SimulationDiagnosticImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'level': instance.level,
      'componentId': instance.componentId,
    };
