import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';

class WirePreviewPainter extends CustomPainter {
  final List<GridPosition> path;
  final ICoordinateService coordinateService;
  final CoordinateContext context;

  WirePreviewPainter({
    required this.path,
    required this.coordinateService,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pathPoints = path.map((pos) => coordinateService.gridToLocal(pos, context)).toList();

    if (pathPoints.length >= 2) {
      final path = Path();
      path.moveTo(pathPoints[0].dx, pathPoints[0].dy);

      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
      }

      canvas.drawPath(path, paint);

      // Draw connection points
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      for (final point in pathPoints) {
        canvas.drawCircle(point, 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(WirePreviewPainter oldDelegate) =>
      path != oldDelegate.path;
}