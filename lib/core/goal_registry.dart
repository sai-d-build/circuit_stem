
import '../models/goal.dart';
import 'component_registry.dart'; // For getBehavior

class GoalRegistry {
  static final Map<String, List<Type>> _behaviors = {};

  static void register({
    required String type,
    required List<Type> behaviors,
  }) {
    _behaviors[type] = behaviors;
  }

  static Goal create(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final behaviorTypes = _behaviors[type];
    if (behaviorTypes == null) throw Exception('Unknown goal type: $type');

    final behaviorInstances = behaviorTypes.map((t) => getBehavior<dynamic>()).toList();

    return Goal.fromJson(json).copyWith(behaviors: behaviorInstances);
  }
}
