import 'package:flutter/material.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

/// Service interface for canvas business logic operations
abstract class CanvasBusinessService {
  /// Place a component on the canvas
  Future<ComponentPlacementResult> placeComponent(
    String componentTypeString,
    Offset position,
    GameState gameState,
    PaletteState paletteState,
    String levelId,
  );

  /// Process a component drop operation
  Future<ComponentDropResult> processComponentDrop(
    DragTargetDetails<ComponentDragData> details,
    Offset localPosition,
    GameState gameState,
    PaletteState paletteState,
    String levelId,
  );

  /// Validate if a component drop can be accepted
  bool canAcceptComponentDrop(
    DragTargetDetails<ComponentDragData> details,
    Offset localPosition,
    GameState gameState,
    PaletteState paletteState,
    String levelId,
  );
}

/// Result of a component placement operation
class ComponentPlacementResult {
  final bool isSuccess;
  final String? errorMessage;
  final ComponentType? componentType;
  final int? row;
  final int? col;

  ComponentPlacementResult._({
    required this.isSuccess,
    this.errorMessage,
    this.componentType,
    this.row,
    this.col,
  });

  factory ComponentPlacementResult.success(
      ComponentType componentType, int row, int col) {
    return ComponentPlacementResult._(
      isSuccess: true,
      componentType: componentType,
      row: row,
      col: col,
    );
  }

  factory ComponentPlacementResult.failure(String errorMessage) {
    return ComponentPlacementResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Result of a component drop operation
class ComponentDropResult {
  final bool isSuccess;
  final String? errorMessage;
  final ComponentType? componentType;
  final int? row;
  final int? col;

  ComponentDropResult._({
    required this.isSuccess,
    this.errorMessage,
    this.componentType,
    this.row,
    this.col,
  });

  factory ComponentDropResult.success(
      ComponentType componentType, int row, int col) {
    return ComponentDropResult._(
      isSuccess: true,
      componentType: componentType,
      row: row,
      col: col,
    );
  }

  factory ComponentDropResult.failure(String errorMessage) {
    return ComponentDropResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
