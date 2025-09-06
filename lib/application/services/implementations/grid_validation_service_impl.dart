// lib/application/services/implementations/grid_validation_service_impl.dart
// Implementation of GridValidationService for position validation

import 'package:sparkcircuit/application/states/game_state.dart';
import '../interfaces/grid_validation_service.dart';

/// Default implementation of GridValidationService
class DefaultGridValidationService implements GridValidationService {
  @override
  GridValidationResult validateBounds(int row, int col, GameState gameState) {
    if (row < 0 || row >= gameState.grid.rows) {
      return GridValidationResult.invalid('Row $row is out of bounds (0-${gameState.grid.rows - 1})');
    }

    if (col < 0 || col >= gameState.grid.cols) {
      return GridValidationResult.invalid('Column $col is out of bounds (0-${gameState.grid.cols - 1})');
    }

    return GridValidationResult.valid();
  }

  @override
  GridValidationResult validateAvailability(int row, int col, GameState gameState) {
    // Check if any component exists at this position
    try {
      final existingComponent = gameState.grid.components.values.firstWhere(
        (component) => component.row == row && component.col == col,
      );

      return GridValidationResult.invalid(
        'Position ($row, $col) is occupied by ${existingComponent.type}'
      );
    } catch (e) {
      // No component found at this position
      return GridValidationResult.valid();
    }
  }

  @override
  GridValidationResult validatePosition(int row, int col, GameState gameState) {
    // Check bounds first
    final boundsResult = validateBounds(row, col, gameState);
    if (!boundsResult.isValid) {
      return boundsResult;
    }

    // Check availability
    final availabilityResult = validateAvailability(row, col, gameState);
    if (!availabilityResult.isValid) {
      return availabilityResult;
    }

    return GridValidationResult.valid();
  }

  @override
  GridValidationResult findNearestAvailablePosition(int row, int col, GameState gameState) {
    // Search in expanding squares around the target position
    for (int radius = 0; radius < gameState.grid.rows + gameState.grid.cols; radius++) {
      for (int dr = -radius; dr <= radius; dr++) {
        for (int dc = -radius; dc <= radius; dc++) {
          // Only check perimeter of current radius
          if (dr.abs() != radius && dc.abs() != radius) continue;

          final checkRow = row + dr;
          final checkCol = col + dc;

          final result = validatePosition(checkRow, checkCol, gameState);
          if (result.isValid) {
            return GridValidationResult.suggestion(
              'Nearest available position found',
              checkRow,
              checkCol,
            );
          }
        }
      }
    }

    return GridValidationResult.invalid('No available positions found in grid');
  }

  @override
  List<(int, int)> getAvailablePositions(GameState gameState) {
    final availablePositions = <(int, int)>[];

    for (int row = 0; row < gameState.grid.rows; row++) {
      for (int col = 0; col < gameState.grid.cols; col++) {
        final result = validatePosition(row, col, gameState);
        if (result.isValid) {
          availablePositions.add((row, col));
        }
      }
    }

    return availablePositions;
  }
}