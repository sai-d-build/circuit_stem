
import 'package:sparkcircuit/application/core/result.dart';
import 'package:sparkcircuit/application/transaction.dart';
import '../../domain/entities/level_goal.dart';

import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class CheckWinConditionUseCaseV2 extends NotifierIntegratedUseCase<ComponentAction> {
  CheckWinConditionUseCaseV2();

  @override
  Future<Result<void>> executeWithNotifiers(
    ComponentAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    final level = notifiers.progress.state.level;
    if (level == null) {
      return const Success(null); // No level loaded, can't check win condition
    }

    final goals = level.goals;
    bool allGoalsMet = true;
    for (final goal in goals) {
      if (!goal.isMet(notifiers.grid.state)) {
        allGoalsMet = false;
        break;
      }
    }

    if (allGoalsMet) {
      notifiers.progress.setWinState(true);
    }
    return const Success(null);
  }
}
