import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../common/logger.dart';

class GoalRegistry {
  static final Map<String, List<Type>> _behaviors = {};

  static dynamic _getBehaviorByType(Type type) {
    // This is a simplified implementation that doesn't actually instantiate types
    // In a real implementation, you would need a proper factory or DI system
    // For now, we'll throw an error to indicate the missing implementation
    throw UnsupportedError(
        'Behavior instantiation for type $type is not yet implemented');
  }

  static void register({
    required String type,
    required List<Type> behaviors,
  }) {
    Logger.log(
        'GoalRegistry: Registering type \'$type\' with behaviors: $behaviors');
    _behaviors[type] = behaviors;
  }

  static LevelGoal create(Map<String, dynamic> json) {
    final type = json['type'] as String;
    Logger.log('GoalRegistry: Creating goal of type: \'$type\'');
    final behaviorTypes = _behaviors[type];
    if (behaviorTypes == null) {
      Logger.log(
          'GoalRegistry: ERROR - No behaviors registered for type: \'$type\'');
      throw Exception('Unknown goal type: $type');
    }

    final behaviorInstances = behaviorTypes.map(_getBehaviorByType).toList();
    Logger.log(
        'GoalRegistry: Instantiated behaviors for \'$type\': $behaviorInstances');

    return LevelGoal.fromJson(json);
  }
}
