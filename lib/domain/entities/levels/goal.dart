import 'package:freezed_annotation/freezed_annotation.dart';
import 'hint.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
class LevelGoal with _$LevelGoal {
  const factory LevelGoal({
    required String id,
    required String type,
    String? description,
    Map<String, dynamic>? conditions,
    int? timeLimit,
    List<Hint>? hints,
  }) = _LevelGoal;

  factory LevelGoal.fromJson(Map<String, dynamic> json) =>
      _$LevelGoalFromJson(json);
}