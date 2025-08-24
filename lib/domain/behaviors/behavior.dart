import 'package:circuit_stem/domain/entities/component_entity.dart';
import 'package:circuit_stem/domain/value_objects/action_context.dart';

abstract class Behavior {
  String get type;
  bool canExecute(ComponentEntity component, String action);
  ComponentEntity execute(ComponentEntity component, String action, ActionContext context);
}
