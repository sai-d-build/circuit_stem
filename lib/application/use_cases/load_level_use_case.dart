
import 'package:circuit_stem/application/use_cases/check_win_condition_use_case.dart';
import 'package:circuit_stem/application/use_cases/simulate_power_flow_use_case.dart';
import 'package:circuit_stem/domain/entities/grid.dart';

import '../core/result.dart';
import '../game_engine_state.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class LoadLevelUseCase extends UseCase<LoadLevelAction, GameEngineState> {
  final SimulatePowerFlowUseCase _simulatePowerFlowUseCase;
  final CheckWinConditionUseCase _checkWinConditionUseCase;

  const LoadLevelUseCase(this._simulatePowerFlowUseCase, this._checkWinConditionUseCase);

  @override
  Result<GameEngineState> execute(GameEngineState state, LoadLevelAction action) {
    try {
      final level = action.level;
      var grid = Grid(
        rows: level.rows,
        cols: level.cols,
        components: level.initialComponents,
      );

      final simulationResult = _simulatePowerFlowUseCase.execute(
        state, 
        const SimulatePowerFlowAction()
      );
      
      if (simulationResult.isSuccess) {
        grid = simulationResult.data!;
      }

      final newState = GameEngineState.initial(level).copyWith(
        grid: grid,
        paletteComponents: level.paletteComponents,
      );

      final winResult = _checkWinConditionUseCase.execute(
        newState,
        const CheckWinConditionAction()
      );

      return Success(newState.copyWith(
        isWin: winResult.isSuccess ? winResult.data! : false,
      ));
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
