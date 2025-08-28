import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Define the interaction state class
class InteractionState {
  final String? draggedComponentId;
  final Offset? dragPosition;
  final bool isDragging;

  const InteractionState({
    this.draggedComponentId,
    this.dragPosition,
    this.isDragging = false,
  });

  static InteractionState initial() {
    return const InteractionState();
  }

  InteractionState copyWith({
    String? draggedComponentId,
    Offset? dragPosition,
    bool? isDragging,
  }) {
    return InteractionState(
      draggedComponentId: draggedComponentId ?? this.draggedComponentId,
      dragPosition: dragPosition ?? this.dragPosition,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  // Clear all interaction state
  InteractionState clear() {
    return const InteractionState();
  }
}

class InteractionStateNotifier extends StateNotifier<InteractionState> {
  InteractionStateNotifier() : super(InteractionState.initial());

  // Start dragging a component
  void startDrag(String componentId, Offset position) {
    state = state.copyWith(
      draggedComponentId: componentId,
      dragPosition: position,
      isDragging: true,
    );
  }

  // Update drag position
  void updateDragPosition(Offset position) {
    if (state.isDragging) {
      state = state.copyWith(dragPosition: position);
    }
  }

  // End dragging
  void endDrag() {
    state = state.clear();
  }

  // Cancel dragging
  void cancelDrag() {
    state = state.clear();
  }

  // Method to execute actions in transaction
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    // Implementation for transaction-based interaction updates
    // This will be expanded based on the specific action types
  }
}