// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LevelGoal _$LevelGoalFromJson(Map json) => $checkedCreate(
      'LevelGoal',
      json,
      ($checkedConvert) {
        final val = LevelGoal(
          goal: $checkedConvert('goal',
              (v) => Goal.fromJson(Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$LevelGoalToJson(LevelGoal instance) => <String, dynamic>{
      'goal': instance.goal.toJson(),
    };
