// lib/engine/render_state.dart
import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/component.dart';


class DebugOverlayData {
  final DebugInfo? debugInfo;
  DebugOverlayData({this.debugInfo});
}

class RenderState {
  final Grid grid;
  final List<ComponentModel> components;
  final EvaluationResult evaluationResult;
  final String? draggedComponentId;
  final Offset? dragPosition;
  final double bulbIntensity;
  final double wireOffset;
  final DebugOverlayData? debugOverlay;

  RenderState({
    required this.grid,
    required this.components,
    required this.evaluationResult,
    this.draggedComponentId,
    this.dragPosition,
    required this.bulbIntensity,
    required this.wireOffset,
    this.debugOverlay,
  });

  factory RenderState.fromEvaluation({
    required Grid grid,
    required EvaluationResult eval,
    required double bulbIntensity,
    required double wireOffset,
    String? draggedComponentId,
    Offset? dragPosition,
  }) {
    return RenderState(
      grid: grid,
      components: grid.componentsById.values.toList(),
      evaluationResult: eval,
      draggedComponentId: draggedComponentId,
      dragPosition: dragPosition,
      bulbIntensity: bulbIntensity,
      wireOffset: wireOffset,
      debugOverlay: DebugOverlayData(debugInfo: eval.debugInfo),
    );
  }
}