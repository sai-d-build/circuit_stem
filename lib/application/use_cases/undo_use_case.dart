import '../core/result.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';
import '../transaction.dart';

class UndoUseCase extends NotifierIntegratedUseCase<UndoAction> {
  UndoUseCase();

  @override
    Future<Result<void>> executeWithNotifiers(
    UndoAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
        if (!notifiers.history.canUndo) {
      return const Failure('No actions to undo');
    }

    // The actual undo logic is handled by the command stack within the orchestrator
    // This use case just triggers the undo on the history notifier
    transaction.onCommit(() async {
      notifiers.history.popState();
    });

    return const Success(null);
  }
}
