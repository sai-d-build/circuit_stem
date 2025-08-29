import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/domain/behaviors/move_behavior.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/common/logger.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'component_action.dart';
import 'base_use_case.dart';

class MoveComponentUseCase extends UseCase<MoveComponentAction> {
  final PowerSimulationService simulation;

  MoveComponentUseCase(this.simulation);

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState state, MoveComponentAction action) async {
    final comp = state.grid.componentsById[action.componentId];
    if (comp == null) {
      Logger.log(
          '[MoveComponentUseCase] Component with id ${action.componentId} not found.');
      return state; // unchanged
    }

    Logger.log('[MoveComponentUseCase] Found component: ${comp.id}');

    final moveBehavior = comp.behaviors.whereType<MoveBehavior>().firstOrNull;
    if (moveBehavior == null) {
      Logger.log(
          '❌ MoveComponentUseCase: MoveBehavior not found for ${comp.id}');
      return state;
    }

    final context = GameContext(
      grid: state.grid,
      toRow: action.newRow,
      toCol: action.newCol,
    );

    final updated = moveBehavior.handle(comp, 'move', context);
    if (updated == null) {
      Logger.log('❌ MoveComponentUseCase: handle returned null for ${comp.id}');
      return state;
    }

    var newGrid = state.grid.copyWithUpdatedComponent(updated);
    newGrid = simulation.simulatePowerFlow(newGrid);

    return state.copyWith(grid: newGrid);
  }
}

// Safe extension
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
