// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LevelGoalImpl _$$LevelGoalImplFromJson(Map json) => $checkedCreate(
      r'_$LevelGoalImpl',
      json,
      ($checkedConvert) {
        final val = _$LevelGoalImpl(
          id: $checkedConvert('id', (v) => v as String),
          type: $checkedConvert('type', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String?),
          conditions: $checkedConvert(
              'conditions',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
          timeLimit: $checkedConvert('timeLimit', (v) => (v as num?)?.toInt()),
          hints: $checkedConvert(
              'hints',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => Hint.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$$LevelGoalImplToJson(_$LevelGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'description': instance.description,
      'conditions': instance.conditions,
      'timeLimit': instance.timeLimit,
      'hints': instance.hints?.map((e) => e.toJson()).toList(),
    };
