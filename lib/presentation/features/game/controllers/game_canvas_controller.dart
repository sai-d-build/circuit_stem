import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/common/constants.dart'; // For cellSize
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/presentation/state/game_state.dart' hide gameEngineProvider, gridProvider; // Hide to avoid conflicts
import 'package:circuit_stem/application/providers.dart'; // Use consolidated providers
import 'package:circuit_stem/presentation/utils/coordinate_translator.dart';

class GameCanvasController extends StateNotifier<void> {
  GameCanvasController() : super(null); // No specific state to manage yet

  final GlobalKey gridKey = GlobalKey();

  Offset getGridCoordinates(Offset globalPosition) {
    final RenderBox renderBox =
        gridKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalPosition);
    final int col = (localPosition.dx / cellSize).floor();
    final int row = (localPosition.dy / cellSize).floor();
    return Offset(col.toDouble(), row.toDouble());
  }

  void handleDragEnd(DragTargetDetails<ComponentModel> details, WidgetRef ref) {
    final renderBox = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final grid = ref.read(gridProvider);
    final notifier = ref.read(gameEngineNotifierProvider);
    final translator = CoordinateTranslator(renderBox);
    final cell = translator.globalToCell(details.offset, grid.rows, grid.cols);

    if (cell != null) {
      notifier.inputManager.handleMove(details.data.id, cell.row, cell.col);
    }
  }
}

final gameCanvasControllerProvider =
    StateNotifierProvider<GameCanvasController, void>((ref) {
  return GameCanvasController();
});
