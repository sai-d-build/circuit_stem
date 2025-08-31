// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelDefinitionImpl _$$LevelDefinitionImplFromJson(
        Map<String, dynamic> json) =>
    _$LevelDefinitionImpl(
      id: json['id'] as String,
      levelNumber: (json['levelNumber'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      rows: (json['rows'] as num).toInt(),
      cols: (json['cols'] as num).toInt(),
      initialComponentsList: (json['initialComponentsList'] as List<dynamic>)
          .map((e) => ComponentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      paletteComponents: (json['paletteComponents'] as List<dynamic>)
          .map((e) => $enumDecode(_$ComponentTypeEnumMap, e))
          .toList(),
      validationRules: (json['validationRules'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$$LevelDefinitionImplToJson(
        _$LevelDefinitionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'levelNumber': instance.levelNumber,
      'title': instance.title,
      'description': instance.description,
      'rows': instance.rows,
      'cols': instance.cols,
      'initialComponentsList': instance.initialComponentsList,
      'paletteComponents': instance.paletteComponents
          .map((e) => _$ComponentTypeEnumMap[e]!)
          .toList(),
      'validationRules': instance.validationRules,
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
