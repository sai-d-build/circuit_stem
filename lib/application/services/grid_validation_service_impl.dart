import 'package:sparkcircuit/application/services/interfaces/grid_validation_service.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Default implementation of GridValidationService
class DefaultGridValidationService implements GridValidationService {
  @override
  GridValidationResult validateBounds(int row, int col, GameState gameState) {
    final isValid = row >= 0 &&
        row < gameState.grid.rows &&
        col >= 0 &&
        col < gameState.grid.cols;

    StructuredLogger.debug('Grid bounds validation', context: {
      'position': '($row, $col)',
      'gridSize': '${gameState.grid.rows}x${gameState.grid.cols}',
      'isValid': isValid,
    });

    if (isValid) {
      return GridValidationResult.valid();
    } else {
      return GridValidationResult.invalid(
          'Position ($row, $col) is outside grid bounds');
    }
  }

  @override
  GridValidationResult validateAvailability(
      int row, int col, GameState gameState) {
    // Check if position is occupied by an existing component
    final isOccupied = gameState.grid.components.values
        .any((component) => component.row == row && component.col == col);

    StructuredLogger.debug('Grid availability validation', context: {
      'position': '($row, $col)',
      'isOccupied': isOccupied,
      'totalComponents': gameState.grid.components.length,
    });

    if (!isOccupied) {
      return GridValidationResult.valid();
    } else {
      return GridValidationResult.invalid(
          'Position ($row, $col) is already occupied');
    }
  }

  @override
  GridValidationResult validatePosition(int row, int col, GameState gameState) {
    StructuredLogger.debug('Comprehensive grid position validation', context: {
      'position': '($row, $col)',
      'gridSize': '${gameState.grid.rows}x${gameState.grid.cols}',
    });

    // First check bounds
    final boundsResult = validateBounds(row, col, gameState);
    if (!boundsResult.isValid) {
      return boundsResult;
    }

    // Then check availability
    final availabilityResult = validateAvailability(row, col, gameState);
    if (!availabilityResult.isValid) {
      return availabilityResult;
    }

    StructuredLogger.debug('Position validation successful', context: {
      'position': '($row, $col)',
    });

    return GridValidationResult.valid();
  }

  @override
  GridValidationResult findNearestAvailablePosition(
      int row, int col, GameState gameState) {
    StructuredLogger.debug('Finding nearest available position', context: {
      'targetPosition': '($row, $col)',
      'gridSize': '${gameState.grid.rows}x${gameState.grid.cols}',
    });

    // Check the target position first
    final targetValidation = validatePosition(row, col, gameState);
    if (targetValidation.isValid) {
      return targetValidation;
    }

    // Search in expanding squares around the target position
    const maxSearchRadius = 5; // Limit search to avoid performance issues

    for (var radius = 1; radius <= maxSearchRadius; radius++) {
      // Check all positions at this radius
      for (var dr = -radius; dr <= radius; dr++) {
        for (var dc = -radius; dc <= radius; dc++) {
          // Only check perimeter positions to avoid re-checking center
          if (dr.abs() == radius || dc.abs() == radius) {
            final checkRow = row + dr;
            final checkCol = col + dc;

            final result = validatePosition(checkRow, checkCol, gameState);
            if (result.isValid) {
              StructuredLogger.debug('Found available position', context: {
                'originalPosition': '($row, $col)',
                'foundPosition': '($checkRow, $checkCol)',
                'searchRadius': radius,
              });

              return GridValidationResult.suggestion(
                  'Position ($row, $col) occupied, suggested ($checkRow, $checkCol)',
                  checkRow,
                  checkCol);
            }
          }
        }
      }
    }

    StructuredLogger.warning('No available position found within search radius',
        context: {
          'targetPosition': '($row, $col)',
          'maxSearchRadius': maxSearchRadius,
          'totalOccupied': gameState.grid.components.length,
        });

    return GridValidationResult.invalid('No available positions found nearby');
  }

  @override
  List<(int, int)> getAvailablePositions(GameState gameState) {
    final availablePositions = <(int, int)>[];

    for (var row = 0; row < gameState.grid.rows; row++) {
      for (var col = 0; col < gameState.grid.cols; col++) {
        final validation = validatePosition(row, col, gameState);
        if (validation.isValid) {
          availablePositions.add((row, col));
        }
      }
    }

    StructuredLogger.debug('Retrieved all available positions', context: {
      'totalPositions': gameState.grid.rows * gameState.grid.cols,
      'availablePositions': availablePositions.length,
      'occupiedPositions': gameState.grid.components.length,
    });

    return availablePositions;
  }

  /// Check if a position is valid for component placement (bounds + availability)
  bool isValidPlacementPosition(int row, int col, GameState gameState) {
    final result = validatePosition(row, col, gameState);
    return result.isValid;
  }

  /// Get occupancy percentage of the grid
  double getGridOccupancyPercentage(GameState gameState) {
    final totalCells = gameState.grid.rows * gameState.grid.cols;
    final occupiedCells = gameState.grid.components.length;

    if (totalCells == 0) return 0;

    return (occupiedCells / totalCells) * 100.0;
  }

  /// Check if the grid has any available positions
  bool hasAvailablePositions(GameState gameState) {
    return getAvailablePositions(gameState).isNotEmpty;
  }
}
