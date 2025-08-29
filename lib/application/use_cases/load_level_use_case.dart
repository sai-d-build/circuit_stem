import 'package:circuit_stem/application/use_cases/check_win_condition_use_case.dart';
import 'package:circuit_stem/application/use_cases/simulate_power_flow_use_case.dart';
import 'package:circuit_stem/application/use_cases/simulate_power_flow_action.dart';

import '../game_engine_state.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class LoadLevelUseCase extends UseCase<LoadLevelAction> {
  // Removed GameEngineState TResult
  final SimulatePowerFlowUseCase _simulatePowerFlowUseCase;
  final CheckWinConditionUseCase _checkWinConditionUseCase;

  const LoadLevelUseCase(
      this._simulatePowerFlowUseCase, this._checkWinConditionUseCase);

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState state, LoadLevelAction action) async {
    try {
      final level = action.level;
      var newState = GameEngineState.initial(level).copyWith(
        paletteComponents: level.paletteComponents,
      );

      // Simulate power flow
      final simulatedStateResult = await _simulatePowerFlowUseCase.execute(
        newState,
        const SimulatePowerFlowAction(),
      );

      if (simulatedStateResult.isSuccess) {
        newState = simulatedStateResult.data!;
      } else {
        // Handle simulation failure, maybe log it
        // For now, proceed with the initial state if simulation fails
      }

      // Check win condition
      final winCheckedStateResult = await _checkWinConditionUseCase.execute(
        newState,
        const CheckWinConditionAction(),
      );

      if (winCheckedStateResult.isSuccess) {
        newState = winCheckedStateResult.data!;
      } else {
        // Handle win check failure, maybe log it
      }

      return newState;
    } catch (e) {
      rethrow; // Rethrow to be caught by the base UseCase
    }
  }
}
