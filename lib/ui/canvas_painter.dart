
import 'package:flutter/material.dart';
import '../common/constants.dart';
import '../engine/render_state.dart';
import '../models/component.dart';
import '../services/asset_manager_state.dart';
import '../behaviors/drawing_behavior.dart';

class CanvasPainter extends CustomPainter {
  final RenderState? renderState;
  final bool showDebugOverlay;
  final AssetState assetState;
  final bool isDark;
  final Color gridColor;
  final Color draggedComponentBackgroundColor;

  CanvasPainter({
    this.renderState,
    this.showDebugOverlay = false,
    required this.assetState,
    required this.isDark,
    required this.gridColor,
    required this.draggedComponentBackgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (renderState == null) return;

    final grid = renderState!.grid;
    _drawGrid(canvas, size, grid.rows, grid.cols);

    // Draw all components except dragged preview
    for (final comp in renderState!.grid.componentsById.values) {
      if (comp.id != renderState!.draggedComponentId) {
        final drawingBehavior = comp.getBehavior<DrawingBehavior>();
        drawingBehavior?.draw(canvas, const Size(cellSize, cellSize), comp, assetState.assetManager!);
      }
    }

    // Draw dragged preview
    if (renderState!.draggedComponentId != null && renderState!.dragPosition != null) {
      final comp = renderState!.grid.componentsById[renderState!.draggedComponentId!];
      if (comp != null) {
        // This also needs to be behavior-driven
        final drawingBehavior = comp.getBehavior<DrawingBehavior>();
        drawingBehavior?.draw(canvas, const Size(cellSize, cellSize), comp, assetState.assetManager!);
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, int rows, int cols) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke;
    const double cw = cellSize, ch = cellSize;

    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(Offset(0, i * ch), Offset(cols * cw, i * ch), paint);
    }
    for (int j = 0; j <= cols; j++) {
      canvas.drawLine(Offset(j * cw, 0), Offset(j * cw, rows * ch), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) =>
      oldDelegate.renderState != renderState ||
      oldDelegate.assetState != assetState ||
      oldDelegate.isDark != isDark ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.draggedComponentBackgroundColor != draggedComponentBackgroundColor;
}
