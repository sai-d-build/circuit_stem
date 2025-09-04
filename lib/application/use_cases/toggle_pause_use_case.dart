import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class TogglePauseUseCase extends NotifierIntegratedUseCase<TogglePauseAction> {
  const TogglePauseUseCase();

  @override
  Future<Result<void>> executeWithNotifiers(
    TogglePauseAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    // Register pause state toggle with transaction
    transaction.onCommit(() async {
      notifiers.progress.togglePause();
    });

    // Register rollback handler
    transaction.onRollback(() {
      // Rollback is handled automatically by the progress notifier's transaction support
    });

    return const Success(null);
  }
}