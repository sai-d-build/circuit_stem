

import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../application/render_state.dart';
import '../../infrastructure/rendering/asset_manager.dart';
import '../../domain/behaviors/drawing_behavior.dart';
import '../../common/logger.dart';

class CanvasPainter extends CustomPainter {
  final RenderState? renderState;
  final bool showDebugOverlay;
  final AssetManagerNotifier assetManager;
  final bool isDark;
  final Color gridColor;
  final Color draggedComponentBackgroundColor;

  CanvasPainter({
    this.renderState,
    this.showDebugOverlay = false,
    required this.assetManager,
    required this.isDark,
    required this.gridColor,
    required this.draggedComponentBackgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Logger.log('CanvasPainter: paint called.');
    if (renderState == null) {
      Logger.log('CanvasPainter: renderState is null. Skipping paint.');
      return;
    }

    final grid = renderState!.grid;
    Logger.log('CanvasPainter: Grid dimensions: \${grid.rows}x\${grid.cols}');

    _drawGrid(canvas, size, grid.rows, grid.cols);
    Logger.log('CanvasPainter: Grid drawn.');

    // Draw all components except dragged preview
    for (final comp in renderState!.grid.components) {
      if (comp.id != renderState!.draggedComponentId) {
        final drawingBehavior = comp.getBehavior<DrawingBehavior>();
        if (drawingBehavior != null) {
          Logger.log('CanvasPainter: Drawing component: \${comp.id} (type: \${comp.type})');
          drawingBehavior.draw(canvas, const Size(cellSize, cellSize), comp, assetManager);
        } else {
          Logger.log('CanvasPainter: No DrawingBehavior for component: \${comp.id} (type: \${comp.type})');
        }
      }
    }
    Logger.log('CanvasPainter: Components drawn.');

    // Draw dragged preview
    if (renderState!.draggedComponentId != null && renderState!.dragPosition != null) {
      final comp = renderState!.grid.components.firstWhere((c) => c.id == renderState!.draggedComponentId);
      final drawingBehavior = comp.getBehavior<DrawingBehavior>();
      if (drawingBehavior != null) {
        Logger.log('CanvasPainter: Drawing dragged component: \${comp.id} (type: \${comp.type})');
        drawingBehavior.draw(canvas, const Size(cellSize, cellSize), comp, assetManager);
      } else {
        Logger.log('CanvasPainter: No DrawingBehavior for dragged component: \${comp.id} (type: \${comp.type})');
      }
    }
    Logger.log('CanvasPainter: Paint complete.');
  }

  void _drawGrid(Canvas canvas, Size size, int rows, int cols) {
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), gridPaint);
    }
    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) =>
      oldDelegate.renderState != renderState ||
      oldDelegate.assetManager != assetManager ||
      oldDelegate.isDark != isDark ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.draggedComponentBackgroundColor != draggedComponentBackgroundColor;
}
