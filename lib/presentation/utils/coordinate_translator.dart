// lib/ui/utils/coordinate_translator.dart
import 'package:flutter/widgets.dart';
import '../../domain/entities/grid_cell.dart';
import '../../common/constants.dart';

class CoordinateTranslator {
  final RenderBox gridBox;

  CoordinateTranslator(this.gridBox);

  GridCell? globalToCell(Offset globalOffset, int rows, int cols) {
    final localOffset = gridBox.globalToLocal(globalOffset);

    final col = (localOffset.dx / cellSize).floor();
    final row = (localOffset.dy / cellSize).floor();

    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return null;
    }
    return GridCell(row, col);
  }
}
