import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/logger.dart';

/// Represents the current user interaction state
class InteractionState {
  final bool isDragging;
  final bool isPanning;
  final bool isZooming;
  final bool isSelecting;
  final bool isPlacingComponent;
  final double zoomLevel;
  final Offset? panOffset;
  final Offset? dragStartPosition;
  final String? interactionMode; // 'normal', 'wire', 'component', 'erase'

  const InteractionState({
    this.isDragging = false,
    this.isPanning = false,
    this.isZooming = false,
    this.isSelecting = false,
    this.isPlacingComponent = false,
    this.zoomLevel = 1.0,
    this.panOffset,
    this.dragStartPosition,
    this.interactionMode = 'normal',
  });

  InteractionState copyWith({
    bool? isDragging,
    bool? isPanning,
    bool? isZooming,
    bool? isSelecting,
    bool? isPlacingComponent,
    double? zoomLevel,
    Offset? panOffset,
    Offset? dragStartPosition,
    String? interactionMode,
  }) {
    return InteractionState(
      isDragging: isDragging ?? this.isDragging,
      isPanning: isPanning ?? this.isPanning,
      isZooming: isZooming ?? this.isZooming,
      isSelecting: isSelecting ?? this.isSelecting,
      isPlacingComponent: isPlacingComponent ?? this.isPlacingComponent,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      panOffset: panOffset ?? this.panOffset,
      dragStartPosition: dragStartPosition ?? this.dragStartPosition,
      interactionMode: interactionMode ?? this.interactionMode,
    );
  }

  bool get isInteracting =>
      isDragging || isPanning || isZooming || isSelecting || isPlacingComponent;

  bool get isIdle => !isInteracting;
}

/// Notifier for managing user interaction state
class InteractionStateNotifier extends StateNotifier<InteractionState> {
  InteractionStateNotifier() : super(const InteractionState());

  /// Start dragging operation
  void startDragging(Offset startPosition) {
    state = state.copyWith(
      isDragging: true,
      dragStartPosition: startPosition,
    );
    Logger.log('Interaction: Started dragging at $startPosition');
  }

  /// Stop dragging operation
  void stopDragging() {
    state = state.copyWith(
      isDragging: false,
      dragStartPosition: null,
    );
    Logger.log('Interaction: Stopped dragging');
  }

  /// Start panning operation
  void startPanning(Offset offset) {
    state = state.copyWith(
      isPanning: true,
      panOffset: offset,
    );
    Logger.log('Interaction: Started panning at $offset');
  }

  /// Update pan offset
  void updatePan(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  /// Stop panning operation
  void stopPanning() {
    state = state.copyWith(
      isPanning: false,
      panOffset: null,
    );
    Logger.log('Interaction: Stopped panning');
  }

  /// Start zooming operation
  void startZooming() {
    state = state.copyWith(isZooming: true);
    Logger.log('Interaction: Started zooming');
  }

  /// Update zoom level
  void updateZoom(double zoomLevel) {
    state = state.copyWith(zoomLevel: zoomLevel);
  }

  /// Stop zooming operation
  void stopZooming() {
    state = state.copyWith(isZooming: false);
    Logger.log('Interaction: Stopped zooming');
  }

  /// Start selection operation
  void startSelecting() {
    state = state.copyWith(isSelecting: true);
    Logger.log('Interaction: Started selecting');
  }

  /// Stop selection operation
  void stopSelecting() {
    state = state.copyWith(isSelecting: false);
    Logger.log('Interaction: Stopped selecting');
  }

  /// Start component placement
  void startPlacingComponent() {
    state = state.copyWith(isPlacingComponent: true);
    Logger.log('Interaction: Started placing component');
  }

  /// Stop component placement
  void stopPlacingComponent() {
    state = state.copyWith(isPlacingComponent: false);
    Logger.log('Interaction: Stopped placing component');
  }

  /// Set interaction mode
  void setInteractionMode(String mode) {
    state = state.copyWith(interactionMode: mode);
    Logger.log('Interaction: Changed mode to $mode');
  }

  /// Reset to idle state
  void resetToIdle() {
    state = const InteractionState();
    Logger.log('Interaction: Reset to idle state');
  }

  /// Check current interaction status
  bool get isDragging => state.isDragging;
  bool get isPanning => state.isPanning;
  bool get isZooming => state.isZooming;
  bool get isSelecting => state.isSelecting;
  bool get isPlacingComponent => state.isPlacingComponent;
  bool get isInteracting => state.isInteracting;
  bool get isIdle => state.isIdle;
  double get zoomLevel => state.zoomLevel;
  Offset? get panOffset => state.panOffset;
  Offset? get dragStartPosition => state.dragStartPosition;
  String? get interactionMode => state.interactionMode;

  /// Get current state (for V2 API compatibility)
  InteractionState get current => state;

  /// Set state directly (for V2 API compatibility)
  void setState(InteractionState newState) {
    state = newState;
    Logger.log('Interaction: State set directly - mode: ${newState.interactionMode}');
  }

  /// Start drag operation (for V2 API compatibility)
  void startDrag(String componentId, Offset position) {
    startDragging(position);
  }

  /// End drag operation (for V2 API compatibility)
  void endDrag() {
    stopDragging();
  }
}

// Provider for InteractionStateNotifier
final interactionStateNotifierProvider = StateNotifierProvider<InteractionStateNotifier, InteractionState>((ref) {
  return InteractionStateNotifier();
});