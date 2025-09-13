import 'package:flutter/material.dart';

// part 'interaction_state.freezed.dart';
// part 'interaction_state.g.dart';

class InteractionState {
  final String? selectedComponentId;
  final String? draggedComponentId;
  final Offset? dragStartLocalPosition;
  final Offset? dragUpdateLocalPosition;
  final bool isDragging;

  const InteractionState({
    this.selectedComponentId,
    this.draggedComponentId,
    this.dragStartLocalPosition,
    this.dragUpdateLocalPosition,
    this.isDragging = false,
  });

  factory InteractionState.initial() => const InteractionState();

  InteractionState copyWith({
    String? selectedComponentId,
    String? draggedComponentId,
    Offset? dragStartLocalPosition,
    Offset? dragUpdateLocalPosition,
    bool? isDragging,
  }) {
    return InteractionState(
      selectedComponentId: selectedComponentId ?? this.selectedComponentId,
      draggedComponentId: draggedComponentId ?? this.draggedComponentId,
      dragStartLocalPosition:
          dragStartLocalPosition ?? this.dragStartLocalPosition,
      dragUpdateLocalPosition:
          dragUpdateLocalPosition ?? this.dragUpdateLocalPosition,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}
