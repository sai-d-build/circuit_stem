import './goal.dart';
import './grid.dart';
import 'package:json_annotation/json_annotation.dart';

part 'level_goal.g.dart';

@JsonSerializable()
class LevelGoal {
  final Goal goal;

  LevelGoal({required this.goal});

  factory LevelGoal.fromJson(Map<String, dynamic> json) => _$LevelGoalFromJson(json);

  bool isMet(Grid grid) {
    // This will need to be implemented based on the goal type
    return false;
  }

  Map<String, dynamic> toJson() => _$LevelGoalToJson(this);
}