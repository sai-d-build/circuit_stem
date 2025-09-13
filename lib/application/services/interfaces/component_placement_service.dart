// lib/application/services/interfaces/component_placement_service.dart
// Interface for component placement business logic

import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

/// Result of placement validation
class PlacementValidationResult {
  final bool isValid;
  final String? reason;

  const PlacementValidationResult._(this.isValid, this.reason);

  factory PlacementValidationResult.valid() =>
      const PlacementValidationResult._(true, null);

  factory PlacementValidationResult.invalid(String reason) =>
      PlacementValidationResult._(false, reason);
}

/// Result of placement execution
class PlacementExecutionResult {
  final bool isSuccess;
  final String? errorMessage;

  const PlacementExecutionResult._(this.isSuccess, this.errorMessage);

  factory PlacementExecutionResult.success() =>
      const PlacementExecutionResult._(true, null);

  factory PlacementExecutionResult.failed(String errorMessage) =>
      PlacementExecutionResult._(false, errorMessage);
}

/// Request for component placement
class ComponentPlacementRequest {
  final ComponentType componentType;
  final int row;
  final int col;
  final GameState currentGameState;
  final String levelId;

  const ComponentPlacementRequest({
    required this.componentType,
    required this.row,
    required this.col,
    required this.currentGameState,
    required this.levelId,
  });
}

/// Abstract interface for component placement service
abstract class ComponentPlacementService {
  /// Validates if a component can be placed at the given position
  PlacementValidationResult validatePlacement(
    ComponentType type,
    int row,
    int col,
    GameState gameState,
  );

  /// Executes component placement with all business logic
  Future<PlacementExecutionResult> executeComponentPlacement(
      ComponentPlacementRequest request);
}
