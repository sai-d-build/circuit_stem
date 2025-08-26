import '../game_engine_state.dart';
import '../services/goal_checking_service.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class CheckWinConditionAction extends ComponentAction {
  const CheckWinConditionAction();
  
  @override
  List<Object?> get props => [];
}

class CheckWinConditionUseCase extends UseCase<CheckWinConditionAction, bool> {
  final GoalCheckingService _goalCheckingService;
  
  const CheckWinConditionUseCase(this._goalCheckingService);
  
  @override
  bool executeInternal(GameEngineState state, CheckWinConditionAction action) {
    if (state.currentLevel == null) return false;
    return _goalCheckingService.isLevelComplete(state.grid, state.currentLevel!);
  }
}
