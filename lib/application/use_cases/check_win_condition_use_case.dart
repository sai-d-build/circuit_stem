import '../core/result.dart';
import '../transaction.dart';
import '../services/goal_checking_service.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class CheckWinConditionUseCase extends NotifierIntegratedUseCase<ComponentAction> {
  final GoalCheckingService _goalCheckingService;

  const CheckWinConditionUseCase(this._goalCheckingService);

  @override
  Future<Result<void>> executeWithNotifiers(
    ComponentAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    final level = notifiers.progress.current.level;
    if (level == null) {
      return const Success(null); // No level loaded, can't check win condition
    }

    // Use the goal checking service to determine if level is complete
    final isWin = _goalCheckingService.isLevelComplete(notifiers.grid.current, level);

    if (isWin) {
      notifiers.progress.setWinState(true);
    }
    return const Success(null);
  }
}