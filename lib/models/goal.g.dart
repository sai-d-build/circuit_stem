// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
      type: json['type'] as String,
      targetId: json['targetId'] as String?,
      r: (json['r'] as num?)?.toInt(),
      c: (json['c'] as num?)?.toInt(),
      from: json['from'] as String?,
      to: json['to'] as String?,
      behaviors: json['behaviors'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'targetId': instance.targetId,
      'r': instance.r,
      'c': instance.c,
      'from': instance.from,
      'to': instance.to,
      'behaviors': instance.behaviors,
    };
