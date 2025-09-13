import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import interactionStateProvider
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/canvas_interaction_controller.dart'
    as canvas_controller;
import 'package:sparkcircuit/presentation/helpers/central_interaction_helper.dart';

class CanvasInteractionWidget extends ConsumerStatefulWidget {
  final String levelId;

  const CanvasInteractionWidget({
    super.key,
    required this.levelId,
  });

  @override
  ConsumerState<CanvasInteractionWidget> createState() =>
      _CanvasInteractionWidgetState();
}

class _CanvasInteractionWidgetState
    extends ConsumerState<CanvasInteractionWidget> {
  canvas_controller.CanvasInteractionController? _controller;
  Timer? _throttleTimer;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    StructuredLogger.info('CanvasInteractionWidget initState called', context: {
      'levelId': widget.levelId,
    });

    // Defer controller initialization to after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController();
    });
  }

  void _initializeController() {
    if (_isControllerInitialized) return;

    _controller = canvas_controller.CanvasInteractionController(
      ref: ref,
      levelId: widget.levelId,
    );
    _isControllerInitialized = true;
    StructuredLogger.info(
        'CanvasInteractionController initialized successfully',
        context: {
          'levelId': widget.levelId,
        });
  }

  @override
  void dispose() {
    StructuredLogger.debug('CanvasInteractionWidget: Disposing resources',
        context: {
          'levelId': widget.levelId,
        });
    _throttleTimer?.cancel();
    _controller?.dispose();
    StructuredLogger.debug('CanvasInteractionWidget: Resources disposed',
        context: {
          'levelId': widget.levelId,
        });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    canvas_controller.InteractionState interactionState;
    try {
      interactionState = ref.watch(interactionStateProvider(widget.levelId));
    } catch (e) {
      StructuredLogger.error('Failed to watch interactionStateProvider',
          context: {
            'levelId': widget.levelId,
            'error': e.toString(),
          });
      interactionState = const canvas_controller.InteractionState(
          currentMode: canvas_controller.InteractionMode.idle, isValid: false);
    }

    // 🔧 RCA: Add logging for canvas re-rendering analysis
    StructuredLogger.info('CanvasInteractionWidget build initiated', context: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'interactionMode': interactionState.currentMode.toString(),
      'isValid': interactionState.isValid,
      'pathLength': interactionState.path.length,
      'hasComponentData': interactionState.componentData != null,
      'levelId': widget.levelId,
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        StructuredLogger.debug(
          '🏗️ Canvas layout established and repaint boundary initialized',
          context: {
            'operation': 'canvas_initialization',
            'canvasWidth': constraints.maxWidth,
            'canvasHeight': constraints.maxHeight,
            'canvasAspectRatio': constraints.maxWidth / constraints.maxHeight,
            'devicePixelRatio': MediaQuery.of(context).devicePixelRatio,
            'levelId': widget.levelId,
            'initializationTime': DateTime.now().millisecondsSinceEpoch,
          },
        );

        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onScaleEnd: _handleScaleEnd,
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Wire preview layer
                  if (interactionState.currentMode ==
                      canvas_controller.InteractionMode.drawWire)
                    _buildWirePreview(interactionState),

                  // Component preview layer - DISABLED to prevent ghost duplication
                  // The Draggable feedback from palette already provides the preview
                  // This overlay is intentionally disabled to avoid visual confusion with the
                  // active drag feedback from HorizontalComponentPalette Draggable.feedback
                  // if (interactionState.currentMode == canvas_controller.InteractionMode.placeComponent &&
                  //     interactionState.componentData != null)
                  //   _buildComponentPreview(interactionState),

                  // Validation feedback
                  if (!interactionState.isValid &&
                      interactionState.errorMessage != null)
                    _buildErrorFeedback(interactionState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    // Handle scale gestures for pan/zoom
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller == null) return;
    if (details.scale != 1.0) {
      _controller!.handleScaleUpdate(details.scale);
    }
    if (details.focalPointDelta != Offset.zero) {
      _controller!.handlePanUpdate(details.focalPointDelta);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // Handle scale end
  }

  Widget _buildWirePreview(canvas_controller.InteractionState state) {
    if (state.path.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: WirePreviewPainter(
        path: state.path,
        coordinateService: CoordinateSystemService(),
        context: _buildCoordinateContext(),
      ),
    );
  }

  Widget _buildErrorFeedback(canvas_controller.InteractionState state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          state.errorMessage!,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  CoordinateContext _buildCoordinateContext() {
    final viewportState =
        CentralInteractionHelper.getViewportState(ref, widget.levelId);
    final gameState = CentralInteractionHelper.getGameState(ref);

    return CoordinateContext(
      gridDimensions:
          Size(gameState.grid.cols.toDouble(), gameState.grid.rows.toDouble()),
      cellSize: viewportState.cellSize,
      scale: viewportState.scale,
      panOffset: viewportState.panOffset,
      canvasSize: viewportState.canvasSize,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
  }
}

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

    final pathPoints =
        path.map((pos) => coordinateService.gridToLocal(pos, context)).toList();

    if (pathPoints.length >= 2) {
      final path = Path();
      path.moveTo(pathPoints[0].dx, pathPoints[0].dy); // ignore: cascade_invocations

      for (var i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].dx, pathPoints[i].dy); // ignore: cascade_invocations
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WirePreviewPainter oldDelegate) {
    // 🔧 RCA: Add debugging for wire preview repaints
    final shouldRepaint = path != oldDelegate.path;
    if (shouldRepaint) {
      StructuredLogger.trace('WirePreviewPainter repainting due to path change',
          context: {
            'newPathLength': path.length,
            'oldPathLength': oldDelegate.path.length,
          });
    }
    return shouldRepaint;
  }
}
