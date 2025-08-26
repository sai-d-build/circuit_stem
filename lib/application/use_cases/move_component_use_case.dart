import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/domain/behaviors/move_behavior.dart';
import '../services/simulation_service.dart';
import '../../common/logger.dart';

/// Application service that orchestrates a component move:
///  - Finds the component
///  - Delegates to MoveBehavior
///  - Updates the grid
///  - Runs simulation
class MoveComponentUseCase {
  final SimulationService simulation;

  MoveComponentUseCase(this.simulation);

  Grid? execute(
    Grid grid,
    String componentId, {
    required int toRow,
    required int toCol,
  }) {
    final comp = grid.componentsById[componentId];
    if (comp == null) {
      Logger.log('[MoveComponentUseCase] Component with id $componentId not found.');
      return null;
    }

    Logger.log('[MoveComponentUseCase] Found component: ${comp.id}, behaviors: ${comp.behaviors.map((b) => b.runtimeType).join(', ')}');

    // Look for a MoveBehavior attached to this component
    final moveBehavior = comp.behaviors
        .whereType<MoveBehavior>()
        .cast<MoveBehavior?>()
        .firstOrNull;

    if (moveBehavior == null) {
      Logger.log('❌ MoveComponentUseCase: MoveBehavior NOT found on component "${comp.type}" (ID: ${comp.id})');
      return null;
    }

    Logger.log('✅ MoveComponentUseCase: Found MoveBehavior for component ${comp.id}');

    final context = GameContext(
      grid: grid,
      toRow: toRow,
      toCol: toCol,
    );

    final updated = moveBehavior.handle(comp, 'move', context);
    if (updated == null) {
      Logger.log('❌ MoveComponentUseCase: MoveBehavior.handle returned null for component "${comp.type}" (ID: ${comp.id})');
      return null;
    }

    Logger.log('✅ MoveComponentUseCase: MoveBehavior.handle returned updated component: ${updated.id}');

    var newGrid = grid.copyWithUpdatedComponent(updated);
    newGrid = simulation.simulatePowerFlow(newGrid);

    return newGrid;
  }
}

// Small helper to avoid errors on empty .firstOrNull
extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
