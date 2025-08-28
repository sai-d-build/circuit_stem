import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/grid_widget.dart';

class CircuitGrid extends ConsumerStatefulWidget {
  final GameCanvasController controller;
  final String levelId;

  const CircuitGrid({
    super.key,
    required this.controller,
    required this.levelId,
  });

  @override
  ConsumerState<CircuitGrid> createState() => _CircuitGridState();
}

class _CircuitGridState extends ConsumerState<CircuitGrid> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update controller with canvas size
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller.updateCanvasSize(constraints.biggest);
        });

        return CustomPaint(
          painter: GridPainter(
            controller: widget.controller,
            circuitColors: Theme.of(context).extension<CircuitColorScheme>()!,
          ),
          child: Container(),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final GameCanvasController controller;
  final CircuitColorScheme circuitColors;

  GridPainter({
    required this.controller,
    required this.circuitColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = circuitColors.gridLine
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final majorGridPaint = Paint()
      ..color = circuitColors.gridLine.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cellSize = controller.scaledCellSize;
    final panOffset = controller.panOffset;

    // Calculate visible grid bounds
    final startX = (-panOffset.dx / cellSize).floor();
    final endX = ((size.width - panOffset.dx) / cellSize).ceil();
    final startY = (-panOffset.dy / cellSize).floor();
    final endY = ((size.height - panOffset.dy) / cellSize).ceil();

    // Draw vertical lines
    for (int i = startX; i <= endX; i++) {
      final x = i * cellSize + panOffset.dx;
      if (x >= -1 && x <= size.width + 1) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }

    // Draw horizontal lines
    for (int i = startY; i <= endY; i++) {
      final y = i * cellSize + panOffset.dy;
      if (y >= -1 && y <= size.height + 1) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }

    // Draw origin marker if visible
    final originX = panOffset.dx;
    final originY = panOffset.dy;
    if (originX >= -10 && originX <= size.width + 10 &&
        originY >= -10 && originY <= size.height + 10) {
      _drawOriginMarker(canvas, Offset(originX, originY));
    }
  }

  void _drawOriginMarker(Canvas canvas, Offset origin) {
    final originPaint = Paint()
      ..color = circuitColors.primary.withValues(alpha: 0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final originFillPaint = Paint()
      ..color = circuitColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw origin circle
    canvas.drawCircle(origin, 6, originFillPaint);
    canvas.drawCircle(origin, 6, originPaint);

    // Draw coordinate axes (small)
    canvas.drawLine(
      origin + const Offset(-10, 0),
      origin + const Offset(10, 0),
      originPaint,
    );
    canvas.drawLine(
      origin + const Offset(0, -10),
      origin + const Offset(0, 10),
      originPaint,
    );
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.controller != controller ||
           oldDelegate.circuitColors != circuitColors;
  }
}