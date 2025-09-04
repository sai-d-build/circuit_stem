import '../core/result.dart';
import '../transaction.dart';
import '../services/power_simulation_service.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

/// Use case for updating a component's internal state and applying changes directly to notifiers
class UpdateComponentUseCase extends NotifierIntegratedUseCase<UpdateComponentAction> {
  final PowerSimulationService _simulation;

  const UpdateComponentUseCase(this._simulation);

  @override
  Result<void> validate(UpdateComponentAction action, NotifierContext notifiers) {
    final component = notifiers.grid.current.componentsById[action.componentId];
    if (component == null) {
      return const Failure('Component not found');
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    UpdateComponentAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final currentGrid = notifiers.grid.current;
      final component = currentGrid.componentsById[action.componentId];
      if (component == null) {
        return const Failure('Component not found');
      }

      // Compute updated component
      final updatedComponent = component.copyWith(properties: action.newState);

      // Compute newGrid eagerly (pure computation)
      var newGrid = currentGrid.copyWithUpdatedComponent(updatedComponent);
      newGrid = _simulation.simulatePowerFlow(newGrid);

      // Compute win state if possible (level context may not be present here; callers should ensure level is available)
      // We can't reliably compute win here without level context; win computation should be handled by callers if needed.

      // Register commit handler to apply grid and optionally progress/history changes
      transaction.onCommit(() async {
        notifiers.grid.setState(newGrid);
        // History updates should be handled by HistoryNotifier commit handlers if required by business rules
      });

      // Register rollback handler for diagnostics
      transaction.onRollback(() {
        // No-op: Notifiers' own rollback handlers handle state restoration
      });

      return const Success(null);
    } catch (e) {
      return Failure('UpdateComponentUseCase error: $e');
    }
  }
}