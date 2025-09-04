// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalImpl _$$GoalImplFromJson(Map json) => $checkedCreate(
      r'_$GoalImpl',
      json,
      ($checkedConvert) {
        final val = _$GoalImpl(
          type: $checkedConvert('type', (v) => v as String),
          parameters: $checkedConvert(
              'parameters', (v) => Map<String, dynamic>.from(v as Map)),
          targetId: $checkedConvert('targetId', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'parameters': instance.parameters,
      'targetId': instance.targetId,
    };
