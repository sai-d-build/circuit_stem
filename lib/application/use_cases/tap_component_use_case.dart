import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../common/logger.dart';
import '../../domain/behaviors/behavior.dart';
import '../core/result.dart';
import '../game_context.dart';
import '../services/power_simulation_service.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class TapComponentUseCase
    extends NotifierIntegratedUseCase<TapComponentAction> {
  final PowerSimulationService _simulation;

  const TapComponentUseCase(this._simulation);

  @override
  Result<void> validate(TapComponentAction action, NotifierContext notifiers) {
    final component = notifiers.grid.current.componentsById[action.componentId];
    if (component == null) {
      return const Failure('Component not found');
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    TapComponentAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final currentGrid = notifiers.grid.current;
      final component = currentGrid.componentsById[action.componentId];

      if (component == null) {
        return const Failure('Component not found');
      }

      // Execute component behaviors
      ComponentModel? updatedComponent;
      final gameContext = GameContext(grid: currentGrid);

      for (final behavior
          in component.behaviors.whereType<ComponentBehavior>()) {
        final result = behavior.handle(component, 'tap', gameContext);
        if (result != null) {
          updatedComponent = result;
          Logger.log(
              'TapComponent: behavior updated component ${component.id}');
          break; // Assuming only one behavior handles a 'tap' action
        }
      }

      if (updatedComponent != null) {
        // Register grid update with transaction
        transaction.onCommit(() async {
          var newGrid = currentGrid.copyWithUpdatedComponent(updatedComponent!);
          newGrid = _simulation.simulatePowerFlow(newGrid);
          notifiers.grid.setState(newGrid);

          // Check win condition and update progress
          // Note: We'll need to get the current level from somewhere else
          // For now, skip win condition checking as it requires level context
          // This could be improved by passing level through NotifierContext
        });

        // Register rollback handler
        transaction.onRollback(() {
          Logger.log('TapComponent: rollback - component changes reverted');
        });
      }

      return const Success(null);
    } catch (e) {
      Logger.log('❌ TapComponentUseCase error: $e');
      return Failure('TapComponent error: $e');
    }
  }
}
