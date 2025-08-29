import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../../domain/entities/grid.dart';

@immutable
class RenderState {
  final Grid grid;
  final Set<String> poweredComponentIds;
  final String? draggedComponentId;
  final Offset? dragPosition;

  const RenderState({
    required this.grid,
    this.poweredComponentIds = const {},
    this.draggedComponentId,
    this.dragPosition,
  });

  RenderState copyWith({
    Grid? grid,
    Set<String>? poweredComponentIds,
    String? draggedComponentId,
    Offset? dragPosition,
  }) {
    return RenderState(
      grid: grid ?? this.grid,
      poweredComponentIds: poweredComponentIds ?? this.poweredComponentIds,
      draggedComponentId: draggedComponentId ?? this.draggedComponentId,
      dragPosition: dragPosition ?? this.dragPosition,
    );
  }
}
