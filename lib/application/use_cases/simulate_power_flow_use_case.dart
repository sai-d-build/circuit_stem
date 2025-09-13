import '../core/result.dart';
import '../services/power_simulation_service.dart';
import '../transaction.dart';
import 'notifier_integrated_use_case.dart';
import 'simulate_power_flow_action.dart';

/// Use case for simulating power flow and applying result directly to GridNotifier
class SimulatePowerFlowUseCase
    extends NotifierIntegratedUseCase<SimulatePowerFlowAction> {
  final PowerSimulationService _simulationService;

  const SimulatePowerFlowUseCase(this._simulationService);

  @override
  Result<void> validate(
      SimulatePowerFlowAction action, NotifierContext notifiers) {
    // No-op validation for now; grid always exists
    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    SimulatePowerFlowAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final currentGrid = notifiers.grid.current;

      // Compute simulated grid now (pure computation); we delay committing it until transaction commit.
      final simulatedGrid = _simulationService.simulatePowerFlow(currentGrid);

      // Register commit handler that applies the simulated grid to the GridNotifier
      transaction.onCommit(() async {
        notifiers.grid.setState(simulatedGrid);
      });

      // Register rollback handler for observability (notifier rollback handlers handle state restore)
      transaction.onRollback(() {
        // Logging / diagnostics could be added here if needed
      });

      return const Success(null);
    } catch (e) {
      return Failure('SimulatePowerFlowUseCase error: $e');
    }
  }
}
