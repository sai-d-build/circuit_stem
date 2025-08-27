import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
class Goal with _$Goal {
  const Goal._();

  const factory Goal({
    required String type,
    String? targetId,
    int? r,
    int? c,
    String? from,
    String? to,
    Map<String, dynamic>? parameters,
    @Default([]) List<dynamic> behaviors,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);

  T? getBehavior<T>() {
    for (final behavior in behaviors) {
      if (behavior is T) {
        return behavior;
      }
    }
    return null;
  }
}
