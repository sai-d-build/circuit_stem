import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart'
    as orchestrator;
import 'package:sparkcircuit/presentation/state/palette_state.dart';

// ✅ CLEAN ARCHITECTURE: Canvas Gesture Service
class CanvasGestureService {
  final dynamic _orchestrator;

  CanvasGestureService(this._orchestrator);

  void handleTap(Offset position) {
    final gestureEvent = orchestrator.GestureInputEvent.tap(position);
    _orchestrator.handleGestureInput(gestureEvent);
  }

  void handleLongPress(Offset position) {
    final gestureEvent = orchestrator.GestureInputEvent(
      type: orchestrator.GestureEventType.longPress,
      position: position,
    );
    _orchestrator.handleGestureInput(gestureEvent);
  }

  void handleScaleStart(Offset focalPoint, int pointerCount) {
    final gestureEvent = orchestrator.GestureInputEvent.scaleStart(
      focalPoint,
      pointerCount,
    );
    _orchestrator.handleGestureInput(gestureEvent);
  }

  void handleScaleUpdate(Offset focalPoint, double scale, int pointerCount) {
    final gestureEvent = orchestrator.GestureInputEvent.scaleUpdate(
      focalPoint,
      scale,
      pointerCount,
    );
    _orchestrator.handleGestureInput(gestureEvent);
  }

  void handleDragUpdate(Offset focalPoint, Offset delta) {
    final gestureEvent = orchestrator.GestureInputEvent.dragUpdate(
      focalPoint,
      delta,
    );
    _orchestrator.handleGestureInput(gestureEvent);
  }

  void handleScaleEnd(int pointerCount) {
    final gestureEvent = orchestrator.GestureInputEvent.scaleEnd(
      Offset.zero,
      pointerCount,
    );
    _orchestrator.handleGestureInput(gestureEvent);
  }
}

final canvasGestureServiceProvider =
    Provider.family<CanvasGestureService, String>((ref, levelId) {
  final orchestrator =
      ref.watch(gameCanvasOrchestratorProvider(levelId).notifier);
  return CanvasGestureService(orchestrator);
});

/// A dedicated widget for handling all canvas gesture interactions
/// This abstracts gesture logic from the main GameCanvas widget for better separation of concerns
class CanvasGestureLayer extends ConsumerWidget {
  final Widget child;
  final String levelId;

  const CanvasGestureLayer({
    super.key,
    required this.child,
    required this.levelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(unifiedGameStateProvider);
    final paletteState = ref.watch(paletteStateProvider(levelId));
    final gestureService = ref.watch(canvasGestureServiceProvider(levelId));

    // Mark file as migrated to unified provider
    MigrationTracker.markFileMigrated(
        'lib/presentation/features/game/widgets/canvas_gesture_layer.dart',
        DateTime.now().toIso8601String());

    return GestureDetector(
      onTapDown: (details) =>
          _handleTapDown(details, gameState, gestureService),
      onLongPressStart: (details) =>
          _handleLongPressStart(details, gameState, gestureService),
      onScaleStart: (details) => _handleScaleStart(details, gestureService),
      onScaleUpdate: (details) =>
          _handleScaleUpdate(details, gameState, paletteState, gestureService),
      onScaleEnd: (details) =>
          _handleScaleEnd(details, gameState, paletteState, gestureService),
      child: child,
    );
  }

  void _handleTapDown(TapDownDetails details, dynamic gameState,
      CanvasGestureService gestureService) {
    // Delegate to service
    gestureService.handleTap(details.localPosition);
  }

  void _handleLongPressStart(LongPressStartDetails details, dynamic gameState,
      CanvasGestureService gestureService) {
    // Delegate to service
    gestureService.handleLongPress(details.localPosition);
  }

  void _handleScaleStart(
      ScaleStartDetails details, CanvasGestureService gestureService) {
    // Delegate to service
    gestureService.handleScaleStart(
        details.localFocalPoint, details.pointerCount);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, dynamic gameState,
      dynamic paletteState, CanvasGestureService gestureService) {
    if (details.pointerCount > 1) {
      // Multi-touch: handle scaling
      gestureService.handleScaleUpdate(
          details.localFocalPoint, details.scale, details.pointerCount);
    } else {
      // Single-touch: handle panning/dragging
      gestureService.handleDragUpdate(
          details.localFocalPoint, details.focalPointDelta);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details, dynamic gameState,
      dynamic paletteState, CanvasGestureService gestureService) {
    // Delegate to service
    gestureService.handleScaleEnd(details.pointerCount);
  }
}
