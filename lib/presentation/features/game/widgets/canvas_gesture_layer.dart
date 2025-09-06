import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/application/providers/game_canvas_providers.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_orchestrator.dart' as orchestrator;

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
    final gameState = ref.watch(providers_v3.enhancedGameStateNotifierProvider);
    final paletteState = ref.watch(paletteStateProvider(levelId));

    return GestureDetector(
      onTapDown: (details) => _handleTapDown(details, gameState, ref),
      onLongPressStart: (details) => _handleLongPressStart(details, gameState, ref),
      onScaleStart: (details) => _handleScaleStart(details, ref),
      onScaleUpdate: (details) => _handleScaleUpdate(details, gameState, paletteState, ref),
      onScaleEnd: (details) => _handleScaleEnd(details, gameState, paletteState, ref),
      child: child,
    );
  }

  void _handleTapDown(TapDownDetails details, dynamic gameState, WidgetRef ref) {
    // Delegate to orchestrator
    final gestureEvent = orchestrator.GestureInputEvent.tap(details.localPosition);
    ref.read(gameCanvasOrchestratorProvider(levelId).notifier).handleGestureInput(gestureEvent);
  }

  void _handleLongPressStart(LongPressStartDetails details, dynamic gameState, WidgetRef ref) {
    // Delegate to orchestrator
    final gestureEvent = orchestrator.GestureInputEvent(
      type: orchestrator.GestureEventType.longPress,
      position: details.localPosition,
    );
    ref.read(gameCanvasOrchestratorProvider(levelId).notifier).handleGestureInput(gestureEvent);
  }

  void _handleScaleStart(ScaleStartDetails details, WidgetRef ref) {
    // Delegate to orchestrator
    final gestureEvent = orchestrator.GestureInputEvent.scaleStart(
      details.localFocalPoint,
      details.pointerCount,
    );
    ref.read(gameCanvasOrchestratorProvider(levelId).notifier).handleGestureInput(gestureEvent);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, dynamic gameState, dynamic paletteState, WidgetRef ref) {
    if (details.pointerCount > 1) {
      // Multi-touch: handle scaling
      final gestureEvent = orchestrator.GestureInputEvent.scaleUpdate(
        details.localFocalPoint,
        details.scale,
        details.pointerCount,
      );
      ref.read(gameCanvasOrchestratorProvider(levelId).notifier).handleGestureInput(gestureEvent);
    } else {
      // Single-touch: handle panning/dragging
      final gestureEvent = orchestrator.GestureInputEvent.dragUpdate(
        details.localFocalPoint,
        details.focalPointDelta,
      );
      ref.read(gameCanvasOrchestratorProvider(levelId).notifier).handleGestureInput(gestureEvent);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details, dynamic gameState, dynamic paletteState, WidgetRef ref) {
    // Delegate to orchestrator
    final gestureEvent = orchestrator.GestureInputEvent.scaleEnd(
      Offset.zero, // ScaleEndDetails doesn't have focal point
      details.pointerCount,
    );
    ref.read(gameCanvasOrchestratorProvider(levelId).notifier).handleGestureInput(gestureEvent);
  }
}