import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/domain/behaviors/move_behavior.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/common/logger.dart';
import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class MoveComponentUseCaseV2 extends NotifierIntegratedUseCase<MoveComponentAction> {
  final PowerSimulationService _simulation;

  const MoveComponentUseCaseV2(this._simulation);

  @override
  Result<void> validate(MoveComponentAction action, NotifierContext notifiers) {
    final component = notifiers.grid.current.componentsById[action.componentId];
    if (component == null) {
      return const Failure('Component not found');
    }
    
    if (action.newRow < 0 || action.newCol < 0) {
      return const Failure('Invalid position: coordinates must be non-negative');
    }
    
    final existingComponent = notifiers.grid.current.componentAt(action.newRow, action.newCol);
    if (existingComponent != null && existingComponent.id != action.componentId) {
      return const Failure('Target cell already occupied');
    }
    
    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    MoveComponentAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final currentGrid = notifiers.grid.current;
      final component = currentGrid.componentsById[action.componentId];
      
      if (component == null) {
        Logger.log('[MoveComponentUseCaseV2] Component with id ${action.componentId} not found.');
        return const Failure('Component not found');
      }

      Logger.log('[MoveComponentUseCaseV2] Found component: ${component.id}');

      final moveBehavior = component.behaviors.whereType<MoveBehavior>().firstOrNull;
      if (moveBehavior == null) {
        Logger.log('❌ MoveComponentUseCaseV2: MoveBehavior not found for ${component.id}');
        return const Failure('MoveBehavior not found');
      }

      final context = GameContext(
        grid: currentGrid,
        toRow: action.newRow,
        toCol: action.newCol,
      );

      final updatedComponent = moveBehavior.handle(component, 'move', context);
      if (updatedComponent == null) {
        Logger.log('❌ MoveComponentUseCaseV2: handle returned null for ${component.id}');
        return const Failure('Move operation failed');
      }

      // Register grid update with transaction
      transaction.onCommit(() async {
        var newGrid = currentGrid.copyWithUpdatedComponent(updatedComponent);
        newGrid = _simulation.simulatePowerFlow(newGrid);
        notifiers.grid.setState(newGrid);
      });

      // Register rollback handler
      transaction.onRollback(() {
        Logger.log('MoveComponent: rollback - component position reverted');
      });

      return const Success(null);
    } catch (e) {
      Logger.log('❌ MoveComponentUseCaseV2 error: $e');
      return Failure('MoveComponent error: $e');
    }
  }
}

// Safe extension for firstOrNull
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}