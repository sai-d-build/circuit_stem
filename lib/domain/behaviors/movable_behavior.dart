
// lib/behaviors/movable_behavior.dart
import '../../application/game_engine_notifier.dart';
import '../entities/grid_cell.dart';
import 'behavior.dart';

class MovableBehavior extends Behavior {
  final GameEngineNotifierV2 gameEngineNotifier;

  MovableBehavior({required this.gameEngineNotifier});

  void moveToCell(String componentId, GridCell cell) {
    // In the future, boundary checks, snapping, or collision rules could be added here.
    gameEngineNotifier.inputManager.handleMove(componentId, cell.row, cell.col);
  }
}
