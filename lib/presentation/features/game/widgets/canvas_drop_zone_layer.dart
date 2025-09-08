import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// CanvasDropZoneLayer handles drop zone highlighting and validation visualization.
/// This layer extracts the drop zone highlighting logic from GameCanvas.
class CanvasDropZoneLayer extends ConsumerWidget {
  final ComponentDragData? dragData;
  final Widget child;
  final int? hoveredCellIndex;

  const CanvasDropZoneLayer({
    super.key,
    required this.dragData,
    required this.child,
    this.hoveredCellIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    StructuredLogger.trace('CanvasDropZoneLayer: Building drop zone layer', context: {
      'dragData_componentName': dragData?.componentName ?? 'null',
      'dragData_componentType': dragData?.componentType?.toString() ?? 'null',
      'dragData_cost': dragData?.cost ?? 0,
      'context_available': context != null,
    });

    final gameState = ref.watch(providers_v3.enhancedGameStateNotifierProvider);
    final paletteState = ref.watch(paletteStateProvider('default')); // TODO: Use proper levelId
    final circuitColors = Theme.of(context).extension<CircuitColorScheme>() ??
                          _getDefaultCircuitColors();

    StructuredLogger.debug('CanvasDropZoneLayer: State watchers resolved', context: {
      'gameState_available': gameState != null,
      'gameState_grid_components_count': gameState.grid.components.length,
      'paletteState_available': paletteState != null,
      'circuitColors_available': circuitColors != null,
    });

    if (dragData == null) {
      StructuredLogger.info('CanvasDropZoneLayer: No drag data, returning child widget');
      return child;
    }

    StructuredLogger.info('CanvasDropZoneLayer: Rendering drop zone with valid drag data', context: {
      'dragData_valid': dragData != null,
      'will_render_drop_zone': true,
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: circuitColors.primary.withValues(alpha: 0.8),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: circuitColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background overlay to make drop zones more visible
          Container(
            color: circuitColors.primary.withValues(alpha: 0.1),
          ),

          // Drop zone highlighting
          Positioned.fill(
            child: CustomPaint(
              painter: DropZoneHighlightPainter(
                circuitColors: circuitColors,
                dragData: dragData,
                gameState: gameState,
                gridConfig: GridConfiguration(
                  rows: gameState.grid.rows,
                  cols: gameState.grid.cols,
                  cellSize: 60.0,
                  scale: 1.0,
                  panOffset: Offset.zero,
                ),
                hoveredCellIndex: hoveredCellIndex,
              ),
              size: Size.infinite,
            ),
          ),

          // Instruction text overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: circuitColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: circuitColors.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Drop ${dragData!.componentName} on a highlighted grid cell',
                style: TextStyle(
                  color: circuitColors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // The actual child content
          child,
        ],
      ),
    );
  }

  CircuitColorScheme _getDefaultCircuitColors() {
    return const CircuitColorScheme(
      primary: Color(0xFF1E88E5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: Color(0xFF43A047),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFF8F00),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1C1C1C),
      surfaceContainer: Color(0xFFEFEFEF),
      onSurfaceVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      outline: Color(0xFFBDBDBD),
      wireActive: Color(0xFF00E676),
      wireInactive: Color(0xFF616161),
      componentBase: Color(0xFF2196F3),
      gridLine: Color(0xFFE0E0E0),
      glowEffect: Color(0xFF00E5FF),
      neonPrimary: Color(0xFF00E5FF),
      neonAccent: Color(0xFF00BCD4),
      errorGlow: Color(0xFFFF5252),
      energyPulse: Color(0xFF00E676),
      highlightAccent: Color(0xFFFFC107),
    );
  }
}

/// DropZoneHighlightPainter handles the visual highlighting of valid drop zones.
class DropZoneHighlightPainter extends CustomPainter {
  final CircuitColorScheme circuitColors;
  final ComponentDragData? dragData;
  final GameState gameState;
  final GridConfiguration gridConfig;
  final int? hoveredCellIndex;

  DropZoneHighlightPainter({
    required this.circuitColors,
    this.dragData,
    required this.gameState,
    required this.gridConfig,
    this.hoveredCellIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    StructuredLogger.trace('DropZoneHighlightPainter: Starting to paint drop zones', context: {
      'grid_rows': gameState.grid.rows,
      'grid_cols': gameState.grid.cols,
      'size': '${size.width.toInt()}x${size.height.toInt()}',
      'cellSize': gridConfig.cellSize,
      'hasDragData': dragData != null,
      'hoveredCellIndex': hoveredCellIndex,
    });

    // If we have drag data, highlight all valid drop positions
    if (dragData != null) {
      _paintDragHighlights(canvas, size);
    }
    // If we have a hovered cell but no drag data, show hover feedback
    else if (hoveredCellIndex != null) {
      _paintHoverFeedback(canvas, size);
    }
  }

  void _paintDragHighlights(Canvas canvas, Size size) {
    // Draw highlights for valid drop positions
    for (int row = 0; row < gameState.grid.rows; row++) {
      for (int col = 0; col < gameState.grid.cols; col++) {
        final screenX = col * gridConfig.cellSize * gridConfig.scale + gridConfig.panOffset.dx;
        final screenY = row * gridConfig.cellSize * gridConfig.scale + gridConfig.panOffset.dy;

        // Check if this position is valid for dropping
        final isValid = _isValidDropPosition(row, col);

        StructuredLogger.trace('DropZoneHighlightPainter: Cell validation result', context: {
          'row': row,
          'col': col,
          'screenX': screenX,
          'screenY': screenY,
          'isValidPosition': isValid,
        });

        if (isValid) {
          StructuredLogger.debug('DropZoneHighlightPainter: Highlighting valid drop cell', context: {
            'row': row,
            'col': col,
            'will_draw_highlight': true,
          });
          // Draw valid drop highlight with more prominent styling
          final validPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.4)
            ..style = PaintingStyle.fill;

          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, gridConfig.cellSize * gridConfig.scale, gridConfig.cellSize * gridConfig.scale),
            validPaint,
          );

          // Draw inner highlight
          final innerPaint = Paint()
            ..color = circuitColors.primary.withValues(alpha: 0.2)
            ..style = PaintingStyle.fill;

          final innerRect = Rect.fromLTWH(
            screenX + 4, screenY + 4,
            (gridConfig.cellSize * gridConfig.scale) - 8, (gridConfig.cellSize * gridConfig.scale) - 8
          );
          canvas.drawRect(innerRect, innerPaint);

          // Draw border with glow effect
          final borderPaint = Paint()
            ..color = circuitColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;

          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, gridConfig.cellSize * gridConfig.scale, gridConfig.cellSize * gridConfig.scale),
            borderPaint,
          );

          // Draw corner markers for better visibility (reduced size to avoid artifacts)
          final cornerPaint = Paint()
            ..color = circuitColors.primary
            ..style = PaintingStyle.fill;

          const cornerSize = 3.0; // Reduced from 6.0 to minimize artifacts
          // Top-left corner
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY, cornerSize, cornerSize),
            cornerPaint,
          );
          // Top-right corner
          canvas.drawRect(
            Rect.fromLTWH(screenX + (gridConfig.cellSize * gridConfig.scale) - cornerSize, screenY, cornerSize, cornerSize),
            cornerPaint,
          );
          // Bottom-left corner
          canvas.drawRect(
            Rect.fromLTWH(screenX, screenY + (gridConfig.cellSize * gridConfig.scale) - cornerSize, cornerSize, cornerSize),
            cornerPaint,
          );
          // Bottom-right corner
          canvas.drawRect(
            Rect.fromLTWH(screenX + (gridConfig.cellSize * gridConfig.scale) - cornerSize, screenY + (gridConfig.cellSize * gridConfig.scale) - cornerSize, cornerSize, cornerSize),
            cornerPaint,
          );
        }
      }
    }
  }

  void _paintHoverFeedback(Canvas canvas, Size size) {
    if (hoveredCellIndex == null) return;

    final row = hoveredCellIndex! ~/ gameState.grid.cols;
    final col = hoveredCellIndex! % gameState.grid.cols;

    final screenX = col * gridConfig.cellSize * gridConfig.scale + gridConfig.panOffset.dx;
    final screenY = row * gridConfig.cellSize * gridConfig.scale + gridConfig.panOffset.dy;

    StructuredLogger.debug('DropZoneHighlightPainter: Painting hover feedback', context: {
      'hoveredCellIndex': hoveredCellIndex,
      'row': row,
      'col': col,
      'screenX': screenX,
      'screenY': screenY,
    });

    // Draw hover highlight
    final hoverPaint = Paint()
      ..color = circuitColors.secondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(screenX, screenY, gridConfig.cellSize * gridConfig.scale, gridConfig.cellSize * gridConfig.scale),
      hoverPaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = circuitColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromLTWH(screenX, screenY, gridConfig.cellSize * gridConfig.scale, gridConfig.cellSize * gridConfig.scale),
      borderPaint,
    );
  }

  bool _isValidDropPosition(int row, int col) {
    StructuredLogger.trace('DropZoneHighlightPainter: Validating drop position', context: {
      'row': row,
      'col': col,
      'grid_bounds': '${gameState.grid.rows}x${gameState.grid.cols}',
    });

    // Check if position is within bounds
    if (row < 0 || row >= gameState.grid.rows || col < 0 || col >= gameState.grid.cols) {
      StructuredLogger.trace('DropZoneHighlightPainter: Position out of bounds', context: {
        'row_valid': row >= 0 && row < gameState.grid.rows,
        'col_valid': col >= 0 && col < gameState.grid.cols,
        'validation_result': false,
      });
      return false;
    }

    // Check if position is occupied
    final existingComponent = gameState.grid.components.values
        .where((component) => component.row == row && component.col == col)
        .isNotEmpty;

    if (existingComponent) {
      StructuredLogger.debug('DropZoneHighlightPainter: Position occupied', context: {
        'row': row,
        'col': col,
        'existing_component_found': true,
        'validation_result': false,
      });
      return false;
    }

    // Check if component is available in inventory (simplified check)
    // In a real implementation, this would check the palette state
    StructuredLogger.debug('DropZoneHighlightPainter: Position valid for drop', context: {
      'row': row,
      'col': col,
      'validation_result': true,
      'reason': 'within_bounds_and_unoccupied',
    });
    return true;
  }

  @override
  bool shouldRepaint(DropZoneHighlightPainter oldDelegate) {
    return oldDelegate.dragData != dragData ||
            oldDelegate.gameState != gameState ||
            oldDelegate.gridConfig != gridConfig ||
            oldDelegate.hoveredCellIndex != hoveredCellIndex;
  }
}