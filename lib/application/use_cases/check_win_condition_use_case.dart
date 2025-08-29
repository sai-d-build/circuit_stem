import '../game_engine_state.dart';
import '../services/goal_checking_service.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class CheckWinConditionAction extends ComponentAction {
  const CheckWinConditionAction();

  @override
  List<Object?> get props => [];
}

class CheckWinConditionUseCase extends UseCase<CheckWinConditionAction> {
  // Removed bool TResult
  final GoalCheckingService _goalCheckingService;

  const CheckWinConditionUseCase(this._goalCheckingService);

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState state, CheckWinConditionAction action) async {
    if (state.currentLevel == null) {
      return state.copyWith(isWin: false); // Return state with isWin: false
    }
    final isWin =
        _goalCheckingService.isLevelComplete(state.grid, state.currentLevel!);
    return state.copyWith(isWin: isWin); // Return state with updated isWin
  }
}
