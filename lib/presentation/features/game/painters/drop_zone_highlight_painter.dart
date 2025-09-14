import 'package:flutter/material.dart';
import '../entity/grid_configuration.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';

/// DropZoneHighlightPainter handles the visual highlighting of valid drop zones.
/// This painter extracts the drop zone highlighting logic from GameCanvas.
class DropZoneHighlightPainter extends CustomPainter {
  final CircuitColorScheme circuitColors;
  final ComponentDragData dragData;
  final GameState gameState;
  final GridConfiguration gridConfig;

  DropZoneHighlightPainter({
    required this.circuitColors,
    required this.dragData,
    required this.gameState,
    required this.gridConfig,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 🎯 PHASE 3: Draw highlights for valid drop positions using 20x20 visual grid
    // This replaces the limited gameplay bounds with full visual grid coverage
    for (var row = 0; row < 20; row++) {  // ✅ Always use 20x20 visual grid
      for (var col = 0; col < 20; col++) {  // ✅ Always use 20x20 visual grid
        final screenX = col * gridConfig.cellSize * gridConfig.scale +
            gridConfig.panOffset.dx;
        final screenY = row * gridConfig.cellSize * gridConfig.scale +
            gridConfig.panOffset.dy;

        // Check if this position is valid for dropping
        final isValid = _isValidDropPosition(row, col);

        if (isValid) {
          // Draw valid drop highlight with more prominent styling
          final validPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.4)
            ..style = PaintingStyle.fill;

          canvas.drawRect(
            Rect.fromLTWH(
                screenX,
                screenY,
                gridConfig.cellSize * gridConfig.scale,
                gridConfig.cellSize * gridConfig.scale),
            validPaint,
          );

          // Draw inner highlight
          final innerPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.2)
            ..style = PaintingStyle.fill;

          final innerRect = Rect.fromLTWH(
              screenX + 4,
              screenY + 4,
              (gridConfig.cellSize * gridConfig.scale) - 8,
              (gridConfig.cellSize * gridConfig.scale) - 8);
          canvas.drawRect(innerRect, innerPaint);

          // Draw border with glow effect
          final borderPaint = Paint()
            ..color = circuitColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;

          canvas.drawRect(
            Rect.fromLTWH(
                screenX,
                screenY,
                gridConfig.cellSize * gridConfig.scale,
                gridConfig.cellSize * gridConfig.scale),
            borderPaint,
          );

          // Draw corner markers for better visibility
          final cornerPaint = Paint()
            ..color = circuitColors.primary
            ..style = PaintingStyle.fill;

          const cornerSize = 6.0;
          // Top-left corner
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, cornerSize, cornerSize),
            cornerPaint,
          );
          // Top-right corner
          canvas.drawRect(
            Rect.fromLTWH(
                screenX + (gridConfig.cellSize * gridConfig.scale) - cornerSize,
                screenY,
                cornerSize,
                cornerSize),
            cornerPaint,
          );
          // Bottom-left corner
          canvas.drawRect(
            Rect.fromLTWH(
                screenX,
                screenY + (gridConfig.cellSize * gridConfig.scale) - cornerSize,
                cornerSize,
                cornerSize),
            cornerPaint,
          );
          // Bottom-right corner
          canvas.drawRect(
            Rect.fromLTWH(
                screenX + (gridConfig.cellSize * gridConfig.scale) - cornerSize,
                screenY + (gridConfig.cellSize * gridConfig.scale) - cornerSize,
                cornerSize,
                cornerSize),
            cornerPaint,
          );
        }
      }
    }
  }

  bool _isValidDropPosition(int row, int col) {
    // 🎯 PHASE 3: Check if position is within 20x20 visual grid bounds
    // This allows drops across the full visual canvas, not just gameplay area
    if (row < 0 || row >= 20 || col < 0 || col >= 20) {  // ✅ Use 20x20 bounds
      return false;
    }

    // Check if position is occupied
    final existingComponent = gameState.grid.components.values
        .where((component) => component.row == row && component.col == col)
        .isNotEmpty;

    if (existingComponent) {
      return false;
    }

    // Check if component is available in inventory (simplified check)
    // In a real implementation, this would check the palette state
    return true;
  }

  @override
  bool shouldRepaint(DropZoneHighlightPainter oldDelegate) {
    return oldDelegate.dragData != dragData ||
        oldDelegate.gameState != gameState ||
        oldDelegate.gridConfig != gridConfig;
  }
}
