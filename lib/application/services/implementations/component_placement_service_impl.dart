// lib/application/services/implementations/component_placement_service_impl.dart
// Implementation of ComponentPlacementService extracted from GameCanvas

import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/application/game_engine/v3/game_engine_notifier_v3.dart';
import '../interfaces/component_placement_service.dart';
import '../interfaces/component_inventory_service.dart';
import '../interfaces/grid_validation_service.dart';

/// Default implementation of ComponentPlacementService
class DefaultComponentPlacementService implements ComponentPlacementService {
  final ComponentInventoryService _inventoryService;
  final GridValidationService _gridValidationService;
  final GameEngineNotifierV3 _gameEngine;

  DefaultComponentPlacementService({
    required ComponentInventoryService inventoryService,
    required GridValidationService gridValidationService,
    required GameEngineNotifierV3 gameEngine,
  }) : _inventoryService = inventoryService,
       _gridValidationService = gridValidationService,
       _gameEngine = gameEngine;

  @override
  PlacementValidationResult validatePlacement(
    ComponentType type,
    int row,
    int col,
    GameState gameState,
  ) {
    // Check inventory availability
    final inventoryCheck = _inventoryService.checkAvailability(type);
    if (!inventoryCheck.isAvailable) {
      return PlacementValidationResult.invalid('Component not available in inventory');
    }

    // Check grid bounds
    final boundsCheck = _gridValidationService.validateBounds(row, col, gameState);
    if (!boundsCheck.isValid) {
      return PlacementValidationResult.invalid(boundsCheck.reason ?? 'Position out of bounds');
    }

    // Check position availability
    final availabilityCheck = _gridValidationService.validateAvailability(row, col, gameState);
    if (!availabilityCheck.isValid) {
      return PlacementValidationResult.invalid(availabilityCheck.reason ?? 'Position occupied');
    }

    return PlacementValidationResult.valid();
  }

  @override
  Future<PlacementExecutionResult> executeComponentPlacement(
    ComponentPlacementRequest request
  ) async {
    try {
      // Validate placement first
      final validation = validatePlacement(
        request.componentType,
        request.row,
        request.col,
        request.currentGameState,
      );

      if (!validation.isValid) {
        return PlacementExecutionResult.failed(validation.reason ?? 'Validation failed');
      }

      // Consume component from inventory
      final consumptionResult = await _inventoryService.consumeComponent(request.componentType);
      if (!consumptionResult.isSuccess) {
        return PlacementExecutionResult.failed(
          consumptionResult.errorMessage ?? 'Failed to consume component from inventory'
        );
      }

      // Place component in game state
      _gameEngine.placeComponent(
        request.componentType,
        request.row,
        request.col,
      );

      // Return success - caller should refetch state from Riverpod provider
      return PlacementExecutionResult.success();

    } catch (e) {
      // If anything fails, attempt to return component to inventory
      try {
        await _inventoryService.returnComponent(request.componentType);
      } catch (rollbackError) {
        // Log rollback error but don't override original error
      }

      return PlacementExecutionResult.failed('Component placement failed: $e');
    }
  }
}