// lib/behaviors/movable_behavior.dart
import '../../application/game_engine_notifier.dart';
import '../entities/core/grid_cell.dart';

class MovableBehavior {
  final GameEngineNotifier gameEngineNotifier;

  MovableBehavior({required this.gameEngineNotifier});

  void moveToCell(String componentId, GridCell cell) {
    // In the future, boundary checks, snapping, or collision rules could be added here.
    gameEngineNotifier.inputManager.handleMove(componentId, cell.row, cell.col);
  }
}
