import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/canvas_interaction_controller.dart' as canvas_controller;
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/helpers/central_interaction_helper.dart';

// Import interactionStateProvider
import 'package:sparkcircuit/application/providers/core_providers.dart';

class CanvasInteractionWidget extends ConsumerStatefulWidget {
  final String levelId;

  const CanvasInteractionWidget({
    super.key,
    required this.levelId,
  });

  @override
  ConsumerState<CanvasInteractionWidget> createState() => _CanvasInteractionWidgetState();
}

class _CanvasInteractionWidgetState extends ConsumerState<CanvasInteractionWidget> {
  canvas_controller.CanvasInteractionController? _controller;
  RenderBox? _renderBox;
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
    StructuredLogger.info('CanvasInteractionController initialized successfully', context: {
      'levelId': widget.levelId,
    });
  }

  @override
  void dispose() {
    StructuredLogger.debug('CanvasInteractionWidget: Disposing resources', context: {
      'levelId': widget.levelId,
    });
    _throttleTimer?.cancel();
    _controller?.dispose();
    StructuredLogger.debug('CanvasInteractionWidget: Resources disposed', context: {
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
      StructuredLogger.error('Failed to watch interactionStateProvider', context: {
        'levelId': widget.levelId,
        'error': e.toString(),
      });
      interactionState = const canvas_controller.InteractionState(currentMode: canvas_controller.InteractionMode.idle, isValid: false);
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
                  if (interactionState.currentMode == canvas_controller.InteractionMode.drawWire)
                    _buildWirePreview(interactionState),

                  // Component preview layer - DISABLED to prevent ghost duplication
                  // The Draggable feedback from palette already provides the preview
                  // This overlay is intentionally disabled to avoid visual confusion with the
                  // active drag feedback from HorizontalComponentPalette Draggable.feedback
                  // if (interactionState.currentMode == canvas_controller.InteractionMode.placeComponent &&
                  //     interactionState.componentData != null)
                  //   _buildComponentPreview(interactionState),

                  // Validation feedback
                  if (!interactionState.isValid && interactionState.errorMessage != null)
                    _buildErrorFeedback(interactionState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _handlePanUpdate(DragUpdateDetails details) {
    // Handle pan gestures for viewport movement
    final delta = details.delta;
    _controller?.handlePanUpdate(delta);
  }

  void _handlePanEnd(DragEndDetails details) {
    // Pan gesture ended - no specific action needed
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

  canvas_controller.DragOrigin _determineDragOrigin(Offset position) {
    // Check if the drag started from a component port or palette
    // For now, default to palette - this would be enhanced to detect actual drag origin
    return canvas_controller.DragOrigin.palette;
  }

  void _handleDragStartFromTarget(DragTargetDetails<ComponentDragData> details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _renderBox = renderBox;
      _controller?.initialize(renderBox);
    }

    // Determine drag origin based on the drag data and position
    final dragOrigin = _determineDragOrigin(details.offset);
    if (_controller != null) {
      _handleDragStart(details, dragOrigin);
    }
  }

  bool _onWillAcceptDrag(DragTargetDetails<ComponentDragData> details) {
    // ✅ ENHANCED: Debug drag events at canvas level
    StructuredLogger.debug('🎯 CANVAS LEVEL: Drag Accept Check Received', context: {
      'canvasWidth': _renderBox?.size.width ?? 0,
      'canvasHeight': _renderBox?.size.height ?? 0,
      'dragOffset': details.offset.toString(),
      'componentType': details.data.componentType.toString(),
      'componentName': details.data.componentName,
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    bool result;
    try {
      result = _originalOnWillAcceptDrag(details);
    } catch (e) {
      StructuredLogger.error('🎯 CANVAS LEVEL: Drag Accept Check Failed', context: {
        'error': e.toString(),
        'levelId': widget.levelId,
      });
      return false;
    }

    StructuredLogger.info('🎯 CANVAS LEVEL: Drag Accept Result', context: {
      'result': result,
      'levelId': widget.levelId,
    });

    return result;
  }

  bool _originalOnWillAcceptDrag(DragTargetDetails<ComponentDragData> details) {
   // Safely get the RenderBox. If it's not available, reject the drag for this frame.
   final renderBox = context.findRenderObject() as RenderBox?;
   if (renderBox == null) {
     StructuredLogger.warning(
       'RenderBox not available in onWillAcceptDrag. Rejecting drag for this frame.',
       context: {'levelId': widget.levelId},
     );
     return false;
   }
   // Assign the valid renderBox if it's not already set or has changed.
   if (_renderBox != renderBox) {
     _renderBox = renderBox;
   }

   // ✅ FIXED: Standardize coordinate conversion - always convert from global to local
   final correctLocalPosition = renderBox.globalToLocal(details.offset);
   final newDetails = DragTargetDetails<ComponentDragData>(
     data: details.data,
     offset: correctLocalPosition,
   );

   StructuredLogger.info(
     '🎯 DRAG EVENT RECEIVED - CanvasInteractionWidget is active!',
     context: {
       'operation': 'drag_acceptance_check_received',
       'componentName': newDetails.data.componentName,
       'globalPosition': details.offset.toString(),
       'localPosition': correctLocalPosition.toString(),
       'levelId': widget.levelId,
     },
   );

   // newDetails.data is always non-null in this context, no need for null check
   StructuredLogger.info('✅ Invalid drag data handling in onWillAccept', context: {
     'levelId': widget.levelId,
   });
   // Continue with validation...

   // Initialize the controller with the renderBox if it hasn't been already.
   _controller?.initialize(renderBox);

   // Start the drag operation if not already started
   final currentState = CentralInteractionHelper.getInteractionState(ref, widget.levelId);
   if (currentState.currentMode == canvas_controller.InteractionMode.idle) {
     StructuredLogger.info('🔄 Starting drag operation from onWillAccept', context: {
       'componentType': newDetails.data.componentType.toString(),
       'levelId': widget.levelId,
     });
     _handleDragStart(newDetails, canvas_controller.DragOrigin.palette);
   }

   // Accept if data is valid - the controller will perform detailed validation on move.
   final isValidData = newDetails.data.componentName.isNotEmpty;

   StructuredLogger.info(
     '✅ Drag acceptance preliminary check completed.',
     context: {
       'isValidData': isValidData,
       'willAccept': isValidData,
       'levelId': widget.levelId,
     },
   );

   return isValidData;
 }

  void _onAcceptDrag(DragTargetDetails<ComponentDragData> details) {
    // ✅ FIX: Standardize coordinate conversion - always convert from global to local
    final localPosition = _renderBox!.globalToLocal(details.offset);
    final newDetails = DragTargetDetails<ComponentDragData>(
      data: details.data,
      offset: localPosition,
    );

    // Explicit logging for successful drop acceptance
    StructuredLogger.debug('🎉 DRAG ACCEPTED - Component: ${newDetails.data.componentName} at (${newDetails.offset.dx.toStringAsFixed(1)}, ${newDetails.offset.dy.toStringAsFixed(1)})', context: {
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    StructuredLogger.info('🎯 ===== CANVAS DRAG ACCEPTED =====', context: {
      'componentType': newDetails.data.componentType.toString(),
      'componentName': newDetails.data.componentName,
      'screenPosition': newDetails.offset.toString(),
      'levelId': widget.levelId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Log state before placement
    final gameStateBefore = CentralInteractionHelper.getGameState(ref);
    StructuredLogger.info('🎯 CANVAS DRAG ACCEPT - STATE BEFORE PLACEMENT', context: {
      'componentsBefore': gameStateBefore.grid.components.length,
      'levelId': widget.levelId,
    });

    _controller?.handleDragEnd(newDetails);

    // Log state after placement attempt
    final gameStateAfter = CentralInteractionHelper.getGameState(ref);
    StructuredLogger.info('🎯 CANVAS DRAG ACCEPT - STATE AFTER PLACEMENT', context: {
      'componentsAfter': gameStateAfter.grid.components.length,
      'placementSuccessful': gameStateAfter.grid.components.length > gameStateBefore.grid.components.length,
      'levelId': widget.levelId,
    });

    if (gameStateAfter.grid.components.length > gameStateBefore.grid.components.length) {
      StructuredLogger.info('🎯 ===== COMPONENT PLACEMENT SUCCESS =====', context: {
        'componentType': newDetails.data.componentType.toString(),
        'componentName': newDetails.data.componentName,
        'levelId': widget.levelId,
      });
    } else {
      StructuredLogger.warning('🎯 ===== COMPONENT PLACEMENT FAILED =====', context: {
        'componentType': newDetails.data.componentType.toString(),
        'componentName': newDetails.data.componentName,
        'levelId': widget.levelId,
      });
    }
  }

  void _onDragLeave(ComponentDragData? data) {
    // Handle drag leave if needed
  }

  void _handleDragStart(DragTargetDetails<ComponentDragData> details, canvas_controller.DragOrigin origin) {
   StructuredLogger.info('🎯 ===== CANVAS DRAG START =====', context: {
     'componentType': details.data.componentType.toString(),
     'componentName': details.data.componentName,
     'screenPosition': details.offset.toString(),
     'origin': origin.toString(),
     'levelId': widget.levelId,
     'timestamp': DateTime.now().millisecondsSinceEpoch,
   });

    final renderBox = context.findRenderObject() as RenderBox?;
    StructuredLogger.debug('Canvas drag start - RenderBox check', context: {
      'renderBoxFound': renderBox != null,
      'renderBoxAttached': renderBox?.attached ?? false,
      'renderBoxSize': renderBox?.size.toString(),
      'levelId': widget.levelId,
    });

    if (renderBox != null) {
      _renderBox = renderBox;
      _controller?.initialize(renderBox);
      StructuredLogger.info('Canvas RenderBox initialized for drag operation', context: {
        'renderBoxSize': renderBox.size.toString(),
        'levelId': widget.levelId,
      });
    } else {
      StructuredLogger.error('Canvas RenderBox not found during drag start', context: {
        'levelId': widget.levelId,
      });
    }

    if (_controller != null) {
      // Log current game state before drag
      final gameState = CentralInteractionHelper.getGameState(ref);
      StructuredLogger.info('🎯 CANVAS DRAG START - CURRENT GAME STATE', context: {
        'gridComponentsCount': gameState.grid.components.length,
        'gridWidth': gameState.grid.cols,
        'gridHeight': gameState.grid.rows,
        'placedComponents': gameState.grid.components.values.map((c) => {
          'id': c.id,
          'type': c.type.toString(),
          'position': '${c.row},${c.col}',
        }).toList(),
        'levelId': widget.levelId,
      });

      _controller!.handleDragStart(details, origin);
    }

    StructuredLogger.info('🎯 CANVAS DRAG START COMPLETED', context: {
      'componentType': details.data.componentType.toString(),
      'levelId': widget.levelId,
    });
  }

  void _handleDragUpdate(DragTargetDetails<ComponentDragData> details) {
    StructuredLogger.debug('CanvasInteractionWidget drag update received', context: {
      'screenPosition': details.offset.toString(),
      'localPosition': details.offset.toString(), // This is actually global in DragTargetDetails
      'levelId': widget.levelId,
    });
    _controller?.handleDragUpdate(details);
  }

  void _handleDragEnd(DragTargetDetails<ComponentDragData> details) {
    _controller?.handleDragEnd(details);
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

  Widget _buildComponentPreview(canvas_controller.InteractionState state) {
    if (state.componentData == null || state.targetPosition == null || _controller == null) {
      return const SizedBox.shrink();
    }

    final context = _buildCoordinateContext();
    final localPosition = _controller!.coordinateService.gridToLocal(
      state.targetPosition!,
      context,
    );

    return Positioned(
      left: localPosition.dx - 25, // Center the preview
      top: localPosition.dy - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: state.isValid ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
          border: Border.all(
            color: state.isValid ? Colors.green : Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getComponentIcon(state.componentData!.componentType),
          color: state.isValid ? Colors.green : Colors.red,
        ),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  CoordinateContext _buildCoordinateContext() {
    final viewportState = CentralInteractionHelper.getViewportState(ref, widget.levelId);
    final gameState = CentralInteractionHelper.getGameState(ref);

    return CoordinateContext(
      gridDimensions: Size(gameState.grid.cols.toDouble(), gameState.grid.rows.toDouble()),
      cellSize: viewportState.cellSize,
      scale: viewportState.scale,
      panOffset: viewportState.panOffset,
      canvasSize: viewportState.canvasSize,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
  }

  IconData _getComponentIcon(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return Icons.battery_full;
      case ComponentType.resistor:
        return Icons.linear_scale;
      case ComponentType.bulb:
        return Icons.lightbulb;
      case ComponentType.wire:
        return Icons.horizontal_rule;
      case ComponentType.switch_:
        return Icons.power;
      case ComponentType.capacitor:
        return Icons.battery_charging_full;
      case ComponentType.inductor:
        return Icons.settings_ethernet;
      case ComponentType.buzzer:
        return Icons.volume_up;
      default:
        return Icons.help;
    }
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

    final pathPoints = path.map((pos) => coordinateService.gridToLocal(pos, context)).toList();

    if (pathPoints.length >= 2) {
      final path = Path();
      path.moveTo(pathPoints[0].dx, pathPoints[0].dy);

      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WirePreviewPainter oldDelegate) {
    // 🔧 RCA: Add debugging for wire preview repaints
    final shouldRepaint = path != oldDelegate.path;
    if (shouldRepaint) {
      StructuredLogger.trace('WirePreviewPainter repainting due to path change', context: {
        'newPathLength': path.length,
        'oldPathLength': oldDelegate.path.length,
      });
    }
    return shouldRepaint;
  }
}