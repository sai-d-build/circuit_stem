import 'package:flutter/material.dart';

class GridWidget extends StatelessWidget {
  final int rows;
  final int cols;
  final double cellSize;

  const GridWidget({
    super.key,
    required this.rows,
    required this.cols,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(rows: rows, cols: cols, cellSize: cellSize),
      size: Size(cols * cellSize, rows * cellSize),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final double cellSize;
  final Paint _paint = Paint()
    ..color = Colors.grey.withAlpha((255 * 0.5).round());

  _GridPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i <= rows; i++) {
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }

    for (int i = 0; i <= cols; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
