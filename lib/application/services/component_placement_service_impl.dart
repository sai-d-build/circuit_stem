import 'package:sparkcircuit/application/services/interfaces/component_placement_service.dart';
import 'package:sparkcircuit/application/services/interfaces/component_inventory_service.dart';
import 'package:sparkcircuit/application/services/interfaces/grid_validation_service.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

/// Default implementation of ComponentPlacementService
class DefaultComponentPlacementService implements ComponentPlacementService {
  final ComponentInventoryService _inventoryService;
  final GridValidationService _gridValidationService;

  DefaultComponentPlacementService({
    required ComponentInventoryService inventoryService,
    required GridValidationService gridValidationService,
  }) : _inventoryService = inventoryService,
       _gridValidationService = gridValidationService;

  @override
  PlacementValidationResult validatePlacement(
    ComponentType type,
    int row,
    int col,
    GameState gameState,
  ) {
    StructuredLogger.debug('Validating component placement', context: {
      'componentType': type.toString(),
      'position': '($row, $col)',
      'gridSize': '${gameState.grid.rows}x${gameState.grid.cols}',
    });

    // Check inventory availability
    final inventoryCheck = _inventoryService.checkAvailability(type);
    if (!inventoryCheck.isAvailable) {
      StructuredLogger.debug('Placement validation failed - insufficient inventory', context: {
        'componentType': type.toString(),
        'reason': inventoryCheck.reason,
      });
      return PlacementValidationResult.invalid(inventoryCheck.reason ?? 'Insufficient inventory');
    }

    // Check grid position validity
    final gridCheck = _gridValidationService.validatePosition(row, col, gameState);
    if (!gridCheck.isValid) {
      StructuredLogger.debug('Placement validation failed - invalid grid position', context: {
        'position': '($row, $col)',
        'reason': gridCheck.reason,
      });
      return PlacementValidationResult.invalid(gridCheck.reason ?? 'Invalid grid position');
    }

    StructuredLogger.debug('Placement validation successful', context: {
      'componentType': type.toString(),
      'position': '($row, $col)',
    });

    return PlacementValidationResult.valid();
  }

  @override
  Future<PlacementExecutionResult> executeComponentPlacement(
    ComponentPlacementRequest request
  ) async {
    StructuredLogger.info('Executing component placement', context: {
      'componentType': request.componentType.toString(),
      'position': '(${request.row}, ${request.col})',
      'levelId': request.levelId,
    });

    try {
      // Validate placement before execution
      final validation = validatePlacement(
        request.componentType,
        request.row,
        request.col,
        request.currentGameState,
      );

      if (!validation.isValid) {
        StructuredLogger.warning('Component placement failed validation', context: {
          'componentType': request.componentType.toString(),
          'reason': validation.reason,
        });
        return PlacementExecutionResult.failed(validation.reason ?? 'Validation failed');
      }

      // Consume component from inventory
      final consumeResult = await _inventoryService.consumeComponent(request.componentType);
      if (!consumeResult.isSuccess) {
        StructuredLogger.error('Failed to consume component from inventory', context: {
          'componentType': request.componentType.toString(),
        });
        return PlacementExecutionResult.failed('Failed to consume component from inventory');
      }

      // Create new component
      final componentId = _generateComponentId(request.componentType, request.row, request.col);
      final component = ComponentModel(
        id: componentId,
        type: request.componentType,
        row: request.row,
        col: request.col,
        properties: _getDefaultProperties(request.componentType),
      );

      // Update game state
      final updatedComponents = Map<String, ComponentModel>.from(request.currentGameState.grid.components);
      updatedComponents[componentId] = component;

      final updatedGrid = request.currentGameState.grid.copyWith(components: updatedComponents);
      final updatedGameState = request.currentGameState.copyWith(grid: updatedGrid);

      StructuredLogger.info('Component placement successful', context: {
        'componentId': componentId,
        'componentType': request.componentType.toString(),
        'position': '(${request.row}, ${request.col})',
      });

      return PlacementExecutionResult.success();

    } catch (e, stackTrace) {
      StructuredLogger.error('Component placement execution failed', context: {
        'componentType': request.componentType.toString(),
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      }, error: e);

      return PlacementExecutionResult.failed('Component placement failed: $e');
    }
  }

  String _generateComponentId(ComponentType type, int row, int col) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final typeName = type.toString().split('.').last;
    return '${typeName}_${row}_${col}_$timestamp';
  }

  Map<String, dynamic> _getDefaultProperties(ComponentType type) {
    // Return default properties based on component type
    switch (type) {
      case ComponentType.battery:
        return {'voltage': 1.5, 'internal_resistance': 0.1};
      case ComponentType.resistor:
        return {'resistance': 1000.0, 'tolerance': 0.05};
      case ComponentType.bulb:
        return {'forward_voltage': 2.0, 'color': 'red'};
      case ComponentType.wire:
        return {'resistance': 0.0};
      case ComponentType.switch_:
        return {'state': 'open'};
      case ComponentType.capacitor:
        return {'capacitance': 0.001, 'voltage_rating': 25.0};
      case ComponentType.inductor:
        return {'inductance': 0.1};
      default:
        return {};
    }
  }
}