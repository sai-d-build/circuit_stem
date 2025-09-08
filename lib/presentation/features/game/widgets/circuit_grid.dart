import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart' as coord;

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
  Timer? _hoverThrottleTimer;

  @override
  void dispose() {
    _hoverThrottleTimer?.cancel();
    super.dispose();
  }

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
            RepaintBoundary(
              child: CustomPaint(
                painter: GridPainter(
                  canvasState: canvasState,
                  circuitColors: Theme.of(context).extension<CircuitColorScheme>() ?? _getDefaultCircuitColors(),
                  hoveredCellIndex: hoveredCellIndex,
                  gridConfig: gridConfig,
                ),
                child: Container(),
              ),
            ),
            // Layer 2: The interactive DragTarget grid (transformed to match viewport)
            Transform.scale(
              scale: canvasState.viewportState.scale,
              child: Transform.translate(
                offset: canvasState.viewportState.panOffset,
                child: MouseRegion(
                  onHover: (event) {
                    // Throttle hover updates to prevent excessive repaints (60fps max)
                    _hoverThrottleTimer?.cancel();
                    _hoverThrottleTimer = Timer(const Duration(milliseconds: 16), () {
                      // Handle non-drag hover for preview feedback
                      final localPos = event.localPosition;
                      // Calculate which cell is being hovered
                      final cellRow = (localPos.dy / gridConfig.cellSize).floor();
                      final cellCol = (localPos.dx / gridConfig.cellSize).floor();
                      final cellIndex = cellRow * gridConfig.cols + cellCol;

                      // Only update if within bounds and different from current hover
                      if (cellRow >= 0 && cellRow < gridConfig.rows &&
                          cellCol >= 0 && cellCol < gridConfig.cols &&
                          hoveredCellIndex != cellIndex) {
                        ref.read(hoveredCellProvider.notifier).state = cellIndex;
                        StructuredLogger.debug('Non-drag hover at cell', context: {
                          'row': cellRow,
                          'col': cellCol,
                          'index': cellIndex,
                          'levelId': widget.levelId,
                        });
                      }
                    });
                  },
                  onExit: (event) {
                    // Clear hover when mouse leaves the grid area
                    ref.read(hoveredCellProvider.notifier).state = null;
                  },
                  child: GridView.builder(
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

                    StructuredLogger.debug('Builder called for cell', context: {
                      'index': index,
                      'row': row,
                      'col': col,
                      'levelId': widget.levelId,
                    });
                    return DragTarget<ComponentDragData>(
                    onWillAccept: (data) {
                      if (isOccupied) {
                        ref.read(hoveredCellProvider.notifier).state = null;
                        return false;
                      }
                      ref.read(hoveredCellProvider.notifier).state = index;
                      StructuredLogger.debug('Hovering at cell', context: {
                        'index': index,
                        'row': row,
                        'col': col,
                        'levelId': widget.levelId,
                      });
                      return true;
                    },
                    onLeave: (data) {
                      ref.read(hoveredCellProvider.notifier).state = null;
                    },
                    onAccept: (data) async {
                      StructuredLogger.info('Placing component at cell', context: {
                        'row': row,
                        'col': col,
                        'levelId': widget.levelId,
                      });
                      ref.read(hoveredCellProvider.notifier).state = null;
                      // Defensive clear after placement
                      Future.delayed(const Duration(milliseconds: 100), () {
                        ref.read(hoveredCellProvider.notifier).state = null;
                      });
                      final paletteNotifier = ref.read(paletteStateProvider(widget.levelId).notifier);

                      // Convert ComponentType enum to String
                      final componentTypeString = data.componentType.toString().split('.').last;

                      // Check if component can be used before attempting
                      if (!paletteNotifier.canUseComponent(componentTypeString)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No items left in inventory!'), backgroundColor: Colors.red,));
                        return;
                      }

                      // 🔧 FIX: Use centralized CoordinateService for accurate placement
                      final coordinateService = coord.CoordinateSystemService();
                      final coordContext = coord.CoordinateContext(
                        gridDimensions: Size(gridConfig.cols.toDouble(), gridConfig.rows.toDouble()),
                        cellSize: gridConfig.cellSize,
                        scale: canvasState.viewportState.scale,
                        panOffset: canvasState.viewportState.panOffset,
                        canvasSize: constraints.biggest,
                        devicePixelRatio: MediaQuery.of(this.context).devicePixelRatio,
                      );

                      // Get occupied positions for validation
                      final occupiedPositions = components.values
                          .map((c) => coord.GridPosition(row: c.row, col: c.col))
                          .toSet();

                      // Calculate drop position from screen coordinates
                      final renderBox = this.context.findRenderObject() as RenderBox?;
                      if (renderBox == null) {
                        StructuredLogger.error('RenderBox not available for coordinate conversion', context: {'levelId': widget.levelId});
                        return;
                      }

                      // Get global position of the drop (approximate from grid cell center)
                      final cellCenter = Offset(
                        col * gridConfig.cellSize + gridConfig.cellSize / 2,
                        row * gridConfig.cellSize + gridConfig.cellSize / 2,
                      );
                      final globalPosition = renderBox.localToGlobal(cellCenter);

                      final validPosition = coordinateService.getSnappedValidPosition(
                        globalPosition,
                        coordContext,
                        renderBox,
                        occupiedPositions: occupiedPositions,
                      );

                      if (validPosition == null) {
                        StructuredLogger.warning('Invalid drop position', context: {
                          'row': row,
                          'col': col,
                          'levelId': widget.levelId,
                        });
                        return;
                      }

                      final correctedRow = validPosition.row;
                      final correctedCol = validPosition.col;

                      StructuredLogger.debug('CircuitGrid: Coordinate validation successful', context: {
                        'originalRow': row,
                        'originalCol': col,
                        'correctedRow': correctedRow,
                        'correctedCol': correctedCol,
                        'scale': coordContext.scale,
                        'panOffset': coordContext.panOffset.toString(),
                        'levelId': widget.levelId,
                      });

                      // 1. Update inventory (useComponent returns void)
                      paletteNotifier.useComponent(componentTypeString);

                      // 2. Commit placement to game state using corrected coordinates
                      final gameStateNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);
                      final newComponent = gameStateNotifier.placeComponent(data.componentType, correctedRow, correctedCol);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data.componentName} placed at (${correctedRow}, ${correctedCol})!'), backgroundColor: Colors.green,));

                      // 3. TODO: Send backend request and handle rollback
                      // final backendOk = await _sendPlacementToServer(index, data);
                      // if (!backendOk) {
                      //   paletteNotifier.returnComponent(data.componentType);
                      //   gameStateNotifier.removeComponent(newComponent.id);
                      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placement failed — rolled back')));
                      // }
                    },
                      builder: (context, candidateData, rejectedData) {
                        // Only show hover feedback if there's active drag data
                        final hasCandidateData = candidateData.isNotEmpty;
                        final showHover = hasCandidateData && isHovered;
                        if (showHover) {
                          StructuredLogger.debug('Showing hover preview', context: {
                            'index': index,
                            'row': row,
                            'col': col,
                            'occupied': isOccupied,
                            'levelId': widget.levelId,
                          });
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: showHover ? (isOccupied ? Colors.red.withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.4)) : Colors.transparent,
                            border: Border.all(
                              color: showHover ? (isOccupied ? Colors.red : Colors.green) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: showHover ? Center(
                            child: Icon(
                              candidateData.first?.icon ?? Icons.help_outline, // Use the icon from drag data
                              size: 24,
                              color: isOccupied ? Colors.red : Colors.green,
                            ),
                          ) : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
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
  final int? hoveredCellIndex;
  final dynamic gridConfig;

  GridPainter({
    required this.canvasState,
    required this.circuitColors,
    this.hoveredCellIndex,
    this.gridConfig,
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
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false; // Disable anti-aliasing to reduce shimmer artifacts

    final majorGridPaint = Paint()
      ..color = circuitColors.gridLine.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false; // Disable anti-aliasing to reduce shimmer artifacts

    final config = canvasState.viewportState.gridConfiguration;
    final cellSize = config.cellSize * canvasState.viewportState.scale;
    final panOffset = canvasState.viewportState.panOffset;

    // Calculate visible grid bounds with buffer for smooth scrolling
    final startX = (-panOffset.dx / cellSize).floor() - 1;
    final endX = ((size.width - panOffset.dx) / cellSize).ceil() + 1;
    final startY = (-panOffset.dy / cellSize).floor() - 1;
    final endY = ((size.height - panOffset.dy) / cellSize).ceil() + 1;

    // Clip to canvas bounds to prevent overdraw
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw vertical lines (pixel-snapped to reduce artifacts, limited to visible area)
    for (int i = startX; i <= endX; i++) {
      final x = (i * cellSize + panOffset.dx).roundToDouble();
      if (x >= -2 && x <= size.width + 2) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(
          Offset(x, -2),
          Offset(x, size.height + 2),
          paint,
        );
      }
    }

    // Draw horizontal lines (pixel-snapped to reduce artifacts, limited to visible area)
    for (int i = startY; i <= endY; i++) {
      final y = (i * cellSize + panOffset.dy).roundToDouble();
      if (y >= -2 && y <= size.height + 2) {
        final paint = (i % 5 == 0) ? majorGridPaint : gridPaint;
        canvas.drawLine(
          Offset(-2, y),
          Offset(size.width + 2, y),
          paint,
        );
      }
    }

    // Draw hover feedback for the hovered cell - only corners to reduce artifacts
    if (hoveredCellIndex != null && gridConfig != null) {
      final hoveredRow = hoveredCellIndex! ~/ gridConfig.cols;
      final hoveredCol = hoveredCellIndex! % gridConfig.cols;

      // Only draw if within bounds
      if (hoveredRow >= 0 && hoveredRow < gridConfig.rows &&
          hoveredCol >= 0 && hoveredCol < gridConfig.cols) {

        final hoverX = hoveredCol * cellSize + panOffset.dx;
        final hoverY = hoveredRow * cellSize + panOffset.dy;

        // Draw subtle hover highlight (reduced opacity to minimize artifacts)
        final hoverPaint = Paint()
          ..color = circuitColors.primary.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill;

        final hoverRect = Rect.fromLTWH(hoverX, hoverY, cellSize, cellSize);
        canvas.drawRect(hoverRect, hoverPaint);

        // Draw corner markers instead of full border to reduce artifacts
        final cornerPaint = Paint()
          ..color = circuitColors.primary.withValues(alpha: 0.7)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final cornerSize = cellSize * 0.2; // Corner markers are 20% of cell size

        // Top-left corner
        canvas.drawLine(
          Offset(hoverX, hoverY),
          Offset(hoverX + cornerSize, hoverY),
          cornerPaint,
        );
        canvas.drawLine(
          Offset(hoverX, hoverY),
          Offset(hoverX, hoverY + cornerSize),
          cornerPaint,
        );

        // Top-right corner
        canvas.drawLine(
          Offset(hoverX + cellSize - cornerSize, hoverY),
          Offset(hoverX + cellSize, hoverY),
          cornerPaint,
        );
        canvas.drawLine(
          Offset(hoverX + cellSize, hoverY),
          Offset(hoverX + cellSize, hoverY + cornerSize),
          cornerPaint,
        );

        // Bottom-left corner
        canvas.drawLine(
          Offset(hoverX, hoverY + cellSize - cornerSize),
          Offset(hoverX, hoverY + cellSize),
          cornerPaint,
        );
        canvas.drawLine(
          Offset(hoverX, hoverY + cellSize),
          Offset(hoverX + cornerSize, hoverY + cellSize),
          cornerPaint,
        );

        // Bottom-right corner
        canvas.drawLine(
          Offset(hoverX + cellSize - cornerSize, hoverY + cellSize),
          Offset(hoverX + cellSize, hoverY + cellSize),
          cornerPaint,
        );
        canvas.drawLine(
          Offset(hoverX + cellSize, hoverY + cellSize - cornerSize),
          Offset(hoverX + cellSize, hoverY + cellSize),
          cornerPaint,
        );

        StructuredLogger.debug('Drawing hover corner feedback', context: {
          'hoveredRow': hoveredRow,
          'hoveredCol': hoveredCol,
          'cornerSize': cornerSize,
        });
      }
    }

    // Draw origin marker if visible (disabled to reduce artifacts during drag)
    // final originX = panOffset.dx;
    // final originY = panOffset.dy;
    // if (originX >= -10 && originX <= size.width + 10 &&
    //     originY >= -10 && originY <= size.height + 10) {
    //   _drawOriginMarker(canvas, Offset(originX, originY));
    // }
  }


  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    // 🔧 RCA: More selective repaint conditions to reduce excessive re-renders
    final shouldRepaint = oldDelegate.canvasState.viewportState != canvasState.viewportState ||
                          oldDelegate.circuitColors != circuitColors ||
                          oldDelegate.hoveredCellIndex != hoveredCellIndex;

    if (shouldRepaint) {
      StructuredLogger.trace('CircuitGrid repainting due to state change', context: {
        'viewportChanged': oldDelegate.canvasState.viewportState != canvasState.viewportState,
        'colorsChanged': oldDelegate.circuitColors != circuitColors,
        'hoveredCellChanged': oldDelegate.hoveredCellIndex != hoveredCellIndex,
        'hoveredCellIndex': hoveredCellIndex,
      });
    }

    return shouldRepaint;
  }
}