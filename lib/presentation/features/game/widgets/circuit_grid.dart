import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

// Provider to track the currently hovered cell index
final hoveredCellProvider = StateProvider<int?>((ref) => null);

class CircuitGrid extends ConsumerStatefulWidget {
  final String levelId;

  const CircuitGrid({
    super.key,
    required this.levelId,
  });

  @override
  ConsumerState<CircuitGrid> createState() => _CircuitGridState();
}

class _CircuitGridState extends ConsumerState<CircuitGrid> {
  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(gameCanvasOrchestratorProvider(widget.levelId));
    final gridConfig = canvasState.viewportState.gridConfiguration;
    final hoveredCellIndex = ref.watch(hoveredCellProvider);
    final components = ref.watch(providers_v3.enhancedGameStateNotifierProvider.select((state) => state.grid.components));

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Layer 1: The visual grid painter
            CustomPaint(
              painter: GridPainter(
                canvasState: canvasState,
                circuitColors: Theme.of(context).extension<CircuitColorScheme>() ?? _getDefaultCircuitColors(),
              ),
              child: Container(),
            ),
            // Layer 2: The interactive DragTarget grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridConfig.cols,
              ),
              itemCount: gridConfig.rows * gridConfig.cols,
              itemBuilder: (context, index) {
                final row = index ~/ gridConfig.cols;
                final col = index % gridConfig.cols;
                final isHovered = hoveredCellIndex == index;
                final isOccupied = components.values.any((c) => c.row == row && c.col == col);

                return DragTarget<ComponentDragData>(
                  onWillAccept: (data) {
                    if (isOccupied) {
                      ref.read(hoveredCellProvider.notifier).state = null;
                      return false;
                    }
                    ref.read(hoveredCellProvider.notifier).state = index;
                    return true;
                  },
                  onLeave: (data) {
                    ref.read(hoveredCellProvider.notifier).state = null;
                  },
                  onAccept: (data) async {
                    ref.read(hoveredCellProvider.notifier).state = null;
                    final paletteNotifier = ref.read(paletteStateProvider(widget.levelId).notifier);

                    // Convert ComponentType enum to String
                    final componentTypeString = data.componentType.toString().split('.').last;

                    // Check if component can be used before attempting
                    if (!paletteNotifier.canUseComponent(componentTypeString)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No items left in inventory!'), backgroundColor: Colors.red,));
                      return;
                    }

                    // 1. Update inventory (useComponent returns void)
                    paletteNotifier.useComponent(componentTypeString);

                    // 2. Commit placement to game state
                    final gameStateNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);
                    final newComponent = gameStateNotifier.placeComponent(data.componentType, row, col);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data.componentName} placed!'), backgroundColor: Colors.green,));

                    // 3. TODO: Send backend request and handle rollback
                    // final backendOk = await _sendPlacementToServer(index, data);
                    // if (!backendOk) {
                    //   paletteNotifier.returnComponent(data.componentType);
                    //   gameStateNotifier.removeComponent(newComponent.id);
                    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placement failed — rolled back')));
                    // }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      decoration: BoxDecoration(
                        color: isHovered ? (isOccupied ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.4)) : Colors.transparent,
                        border: Border.all(
                          color: isHovered ? (isOccupied ? Colors.red : Colors.green) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
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
      neonPrimary: Color(0xFF00FFFF),
      neonAccent: Color(0xFFFF00FF),
      errorGlow: Color(0xFFFF0040),
      energyPulse: Color(0xFF39FF14),
      highlightAccent: Color(0xFFFFFF00),
    );
  }
}

class GridPainter extends CustomPainter {
  final GameCanvasState canvasState;
  final CircuitColorScheme circuitColors;

  GridPainter({
    required this.canvasState,
    required this.circuitColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 🔧 RCA: Add structured logging for re-render analysis
    StructuredLogger.trace('CircuitGrid painting initiated', context: {
      'canvasSize': '${size.width}x${size.height}',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Log actual grid rendering
    final loggingConfig = canvasState.viewportState.gridConfiguration;
    final loggingCellSize = loggingConfig.cellSize * canvasState.viewportState.scale;
    final loggingPanOffset = canvasState.viewportState.panOffset;

    // Log grid bounds and canvas size
    StructuredLogger.info('CircuitGrid: Painting grid', context: {
      'canvas_size': size.toString(),
      'gridConfig_rows': loggingConfig.rows,
      'gridConfig_cols': loggingConfig.cols,
      'gridConfig_cellSize': loggingConfig.cellSize,
      'viewport_scale': canvasState.viewportState.scale,
      'calculated_cellSize': loggingCellSize,
      'viewport_panOffset': loggingPanOffset.toString(),
      'grid_width_pixels': loggingConfig.cols * loggingCellSize,
      'grid_height_pixels': loggingConfig.rows * loggingCellSize,
      'hasLevel': canvasState.currentLevel != null,
      'levelId': canvasState.currentLevel?.levelId ?? 'null',
    });

    final gridPaint = Paint()
      ..color = circuitColors.gridLine
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final majorGridPaint = Paint()
      ..color = circuitColors.gridLine.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final config = canvasState.viewportState.gridConfiguration;
    final cellSize = config.cellSize * canvasState.viewportState.scale;
    final panOffset = canvasState.viewportState.panOffset;

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
    // 🔧 RCA: More selective repaint conditions to reduce excessive re-renders
    final shouldRepaint = oldDelegate.canvasState.viewportState != canvasState.viewportState ||
                         oldDelegate.circuitColors != circuitColors;

    if (shouldRepaint) {
      StructuredLogger.trace('CircuitGrid repainting due to state change', context: {
        'viewportChanged': oldDelegate.canvasState.viewportState != canvasState.viewportState,
        'colorsChanged': oldDelegate.circuitColors != circuitColors,
      });
    }

    return shouldRepaint;
  }
}