// lib/behaviors/drag_behavior.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/services/providers.dart';
import '../entities/component.dart';
import '../../presentation/utils/coordinate_translator.dart';

class DragBehavior {
  final WidgetRef ref;
  final GlobalKey gridKey;

  DragBehavior({required this.ref, required this.gridKey});

  void onDragEnd(DragTargetDetails<ComponentModel> details) {
    final renderBox = gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final grid = ref.read(gridProvider);
    final notifier = ref.read(gameEngineProvider.notifier);
    final translator = CoordinateTranslator(renderBox);
    final cell = translator.globalToCell(details.offset, grid.rows, grid.cols);

    if (cell != null) {
      notifier.inputManager.handleMove(details.data.id, cell.row, cell.col);
    }
  }
}
