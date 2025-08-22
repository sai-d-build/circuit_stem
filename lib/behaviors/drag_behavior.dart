
// lib/behaviors/drag_behavior.dart
import 'package:flutter/widgets.dart';
import '../engine/game_engine_notifier.dart';
import '../models/grid_cell.dart';
import '../widgets/grid_widget.dart'; // Added import for GridWidgetState
import 'behavior.dart';
import 'movable_behavior.dart';

class DragBehavior extends Behavior {
  final GameEngineNotifierV2 gameEngineNotifier;
  final GlobalKey<GridWidgetState> gridKey;

  DragBehavior({
    required this.gameEngineNotifier,
    required this.gridKey,
  });

  void onDragEnd(DraggableDetails details, String componentId) {
    final renderBox = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final grid = gameEngineNotifier.state.grid;
    final translator = CoordinateTranslator(renderBox);
    final cell = translator.globalToCell(details.offset, grid.rows, grid.cols);

    if (cell != null) {
      final movable = getBehavior<MovableBehavior>();
      movable?.moveToCell(componentId, cell);
    }
  }
}
