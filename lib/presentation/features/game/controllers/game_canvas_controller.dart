import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/common/constants.dart'; // For cellSize

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
}

final gameCanvasControllerProvider =
    StateNotifierProvider<GameCanvasController, void>((ref) {
  return GameCanvasController();
});
