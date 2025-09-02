// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Goal _$GoalFromJson(Map json) => $checkedCreate(
      'Goal',
      json,
      ($checkedConvert) {
        final val = Goal(
          type: $checkedConvert('type', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$GoalToJson(Goal instance) => <String, dynamic>{
      'type': instance.type,
    };
