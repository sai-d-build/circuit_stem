
import '../../domain/entities/goal.dart';
import 'component_registry.dart'; // For getBehavior
import '../../common/logger.dart';

class GoalRegistry {
  static final Map<String, List<Type>> _behaviors = {};

  static void register({
    required String type,
    required List<Type> behaviors,
  }) {
    Logger.log('GoalRegistry: Registering type \'$type\' with behaviors: $behaviors');
    _behaviors[type] = behaviors;
  }

  static Goal create(Map<String, dynamic> json) {
    final type = json['type'] as String;
    Logger.log('GoalRegistry: Creating goal of type: \'$type\'');
    final behaviorTypes = _behaviors[type];
    if (behaviorTypes == null) {
      Logger.log('GoalRegistry: ERROR - No behaviors registered for type: \'$type\'');
      throw Exception('Unknown goal type: $type');
    }

    final behaviorInstances = behaviorTypes.map((t) => getBehaviorByType(t)).toList();
    Logger.log('GoalRegistry: Instantiated behaviors for \'$type\': $behaviorInstances');

    return Goal.fromJson(json).copyWith(behaviors: behaviorInstances);
  }
}
