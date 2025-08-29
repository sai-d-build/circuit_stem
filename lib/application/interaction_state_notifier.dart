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

  // Public snapshot getter for safe read access
  InteractionState get current => state;

  // Public setter for controlled writes
  void setState(InteractionState newState) => state = newState;

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
    // Store current state for rollback
    final previousState = state;
    
    // Register rollback handler
    transaction.onRollback(() {
      state = previousState;
    });
    
    // Register commit handler - execute interaction updates
    transaction.onCommit(() async {
      // Handle drag and drop related actions
      if (action.toString().contains('StartDrag')) {
        // TODO: Extract componentId and position from action
        // For now this is a placeholder until we have proper action types
      } else if (action.toString().contains('EndDrag') || action.toString().contains('CancelDrag')) {
        endDrag();
      }
    });
  }
}