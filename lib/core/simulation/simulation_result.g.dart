// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimulationResultImpl _$$SimulationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$SimulationResultImpl(
      nodeVoltages: (json['nodeVoltages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      branchCurrents: (json['branchCurrents'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      componentStates: (json['componentStates'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, ComponentState.fromJson(e as Map<String, dynamic>)),
      ),
      connectionStates: (json['connectionStates'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, ConnectionState.fromJson(e as Map<String, dynamic>)),
      ),
      diagnostics: (json['diagnostics'] as List<dynamic>)
          .map((e) => SimulationDiagnostic.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isValid: json['isValid'] as bool,
    );

Map<String, dynamic> _$$SimulationResultImplToJson(
        _$SimulationResultImpl instance) =>
    <String, dynamic>{
      'nodeVoltages': instance.nodeVoltages,
      'branchCurrents': instance.branchCurrents,
      'componentStates': instance.componentStates,
      'connectionStates': instance.connectionStates,
      'diagnostics': instance.diagnostics,
      'timestamp': instance.timestamp.toIso8601String(),
      'isValid': instance.isValid,
    };

_$ComponentStateImpl _$$ComponentStateImplFromJson(Map<String, dynamic> json) =>
    _$ComponentStateImpl(
      id: json['id'] as String,
      properties: json['properties'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$ComponentStateImplToJson(
        _$ComponentStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'properties': instance.properties,
    };

_$ConnectionStateImpl _$$ConnectionStateImplFromJson(
        Map<String, dynamic> json) =>
    _$ConnectionStateImpl(
      id: json['id'] as String,
      properties: json['properties'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$ConnectionStateImplToJson(
        _$ConnectionStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'properties': instance.properties,
    };

_$SimulationDiagnosticImpl _$$SimulationDiagnosticImplFromJson(
        Map<String, dynamic> json) =>
    _$SimulationDiagnosticImpl(
      message: json['message'] as String,
      level: json['level'] as String,
      componentId: json['componentId'] as String?,
    );

Map<String, dynamic> _$$SimulationDiagnosticImplToJson(
        _$SimulationDiagnosticImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'level': instance.level,
      'componentId': instance.componentId,
    };
