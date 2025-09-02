import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
@JsonSerializable()
class Goal with _$Goal {
  const factory Goal({
    required String type,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
