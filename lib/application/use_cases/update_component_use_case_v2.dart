import '../core/result.dart';
import '../transaction.dart';
import '../services/power_simulation_service.dart';
import '../services/goal_checking_service.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

/// V2 use-case: update a component's internal state and apply changes directly to notifiers
class UpdateComponentUseCaseV2 extends NotifierIntegratedUseCase<UpdateComponentAction> {
  final PowerSimulationService _simulation;

  const UpdateComponentUseCaseV2(this._simulation);

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
      bool? isWin;
      // We can't reliably compute win here without level context; leave isWin null.

      // Register commit handler to apply grid and optionally progress/history changes
      transaction.onCommit(() async {
        notifiers.grid.setState(newGrid);
        if (isWin != null) {
          notifiers.progress.setWinState(isWin);
        }
        // History updates should be handled by HistoryNotifier commit handlers if required by business rules
      });

      // Register rollback handler for diagnostics
      transaction.onRollback(() {
        // No-op: Notifiers' own rollback handlers handle state restoration
      });

      return const Success(null);
    } catch (e) {
      return Failure('UpdateComponentUseCaseV2 error: $e');
    }
  }
}