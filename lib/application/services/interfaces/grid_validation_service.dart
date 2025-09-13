// lib/application/services/interfaces/grid_validation_service.dart
// Interface for grid position validation

import 'package:sparkcircuit/application/states/game_state.dart';

/// Result of grid position validation
class GridValidationResult {
  final bool isValid;
  final String? reason;
  final int? suggestedRow;
  final int? suggestedCol;

  const GridValidationResult._(
      this.isValid, this.reason, this.suggestedRow, this.suggestedCol);

  factory GridValidationResult.valid() =>
      const GridValidationResult._(true, null, null, null);

  factory GridValidationResult.invalid(String reason) =>
      GridValidationResult._(false, reason, null, null);

  factory GridValidationResult.suggestion(
          String reason, int suggestedRow, int suggestedCol) =>
      GridValidationResult._(false, reason, suggestedRow, suggestedCol);
}

/// Abstract interface for grid validation service
abstract class GridValidationService {
  /// Validates if a position is within grid bounds
  GridValidationResult validateBounds(int row, int col, GameState gameState);

  /// Validates if a position is available (not occupied)
  GridValidationResult validateAvailability(
      int row, int col, GameState gameState);

  /// Comprehensive validation combining bounds and availability
  GridValidationResult validatePosition(int row, int col, GameState gameState);

  /// Finds nearest available position to given coordinates
  GridValidationResult findNearestAvailablePosition(
      int row, int col, GameState gameState);

  /// Gets all available positions in the grid
  List<(int, int)> getAvailablePositions(GameState gameState);
}
