import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/common/logger.dart';
import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class UndoUseCaseV2 extends NotifierIntegratedUseCase<UndoAction> {
  final PowerSimulationService _simulation;

  const UndoUseCaseV2(this._simulation);

  @override
  Result<void> validate(UndoAction action, NotifierContext notifiers) {
    if (notifiers.history.current.isEmpty) {
      return const Failure('No actions to undo');
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    UndoAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    try {
      final lastState = notifiers.history.getLastState();
      if (lastState == null) {
        Logger.log('[UndoUseCaseV2] No history to undo');
        return const Failure('No actions to undo');
      }

      // Register commit handler to restore previous state atomically.
      transaction.onCommit(() async {
        // Recompute power flow based on the previous grid to ensure consistent powered states.
        final restoredGrid = _simulation.simulatePowerFlow(lastState.grid);
        notifiers.grid.setState(restoredGrid);

        // Restore progress (win / paused)
        notifiers.progress.setWinState(lastState.isWin);
        if (lastState.isPaused != notifiers.progress.current.isPaused) {
          // Align pause state using public setter
          notifiers.progress.setState(notifiers.progress.current.copyWith(isPaused: lastState.isPaused));
        }

        // Restore selection
        if (lastState.selectedComponentId != null) {
          notifiers.selection.selectComponent(lastState.selectedComponentId!);
        } else {
          notifiers.selection.clearSelection();
        }

        // Restore interaction state (drag)
        if (lastState.draggedComponentId != null && lastState.dragPosition != null) {
          notifiers.interaction.startDrag(lastState.draggedComponentId!, lastState.dragPosition!);
        } else {
          notifiers.interaction.endDrag();
        }

        // Pop the last history entry now that we've restored it.
        notifiers.history.popLastState();

        Logger.log('[UndoUseCaseV2] Undo committed - restored previous state');
      });

      // Register a rollback handler to log (history was not mutated until commit)
      transaction.onRollback(() {
        Logger.log('[UndoUseCaseV2] Undo rolled back');
      });

      return const Success(null);
    } catch (e) {
      Logger.log('[UndoUseCaseV2] error: $e');
      return Failure('Undo error: $e');
    }
  }
}