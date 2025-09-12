import '../services/power_simulation_service.dart';
import '../services/component_factory.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../core/debug/structured_logger.dart';
import '../../common/logger.dart';
import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';
import '../../../core/interfaces/game_state_notifier_interface.dart';
// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
import '../../../core/migration/migration_tracker.dart';

// Helper function to get Grid from notifier context
Grid _getGrid(dynamic notifier) {
  StructuredLogger.debug('🔍 GETTING GRID FROM NOTIFIER', context: {
    'notifierType': notifier.runtimeType.toString(),
    'timestamp': DateTime.now().toIso8601String(),
  });

  try {
    // Try different ways to get the grid based on notifier type
    if (notifier is IGameStateNotifier) {
      StructuredLogger.debug('🔍 USING IGameStateNotifier INTERFACE', context: {
        'hasState': true,
        'stateType': notifier.state.runtimeType.toString(),
      });
      return notifier.state.grid;
    } else if (notifier.current != null) {
      StructuredLogger.debug('🔍 USING .current PROPERTY', context: {
        'currentType': notifier.current.runtimeType.toString(),
      });
      return notifier.current;
    } else {
      StructuredLogger.error('💥 UNKNOWN NOTIFIER TYPE', context: {
        'notifierType': notifier.runtimeType.toString(),
        'availableProperties': notifier.toString(),
      });
      throw Exception('Unknown notifier type: ${notifier.runtimeType}');
    }
  } catch (e, stackTrace) {
    StructuredLogger.error('💥 FAILED TO GET GRID FROM NOTIFIER', context: {
      'error': e.toString(),
      'stackTrace': stackTrace.toString(),
      'notifierType': notifier.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    }, error: e);
    rethrow;
  }
}

class CreateComponentUseCase extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  final ComponentFactory _factory;

  CreateComponentUseCase(PowerSimulationService simulation, this._factory) {
    // Mark file as migrated to unified provider
    MigrationTracker.markFileMigrated(
      'lib/application/use_cases/create_component_use_case.dart',
      DateTime.now().toIso8601String()
    );
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    CreateComponentFromTemplateAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    StructuredLogger.info('📈 COMPONENT PLACEMENT USE CASE START', context: {
      'templateId': action.templateId,
      'targetPosition': {'row': action.row, 'col': action.col},
      'notifierGridType': notifiers.grid.runtimeType.toString(),
      'transactionId': transaction.hashCode,
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      // 🔍 STEP 1: Validate input parameters
      StructuredLogger.debug('🔍 Input validation start', context: {
        'templateId': action.templateId,
        'targetPosition': {'row': action.row, 'col': action.col},
        'validation_criteria': 'templateId not empty, coordinates non-negative',
      });

      // Validate template ID
      if (action.templateId.isEmpty) {
        StructuredLogger.error('🚫 Template ID validation failed - empty template ID', context: {
          'templateId': action.templateId,
          'validation_result': 'EMPTY_TEMPLATE_ID',
        });
        return const Failure('Invalid component type: template ID cannot be empty');
      }

      // Validate component type exists
      ComponentType? componentType;
      try {
        componentType = ComponentType.values.firstWhere(
          (type) => type.name == action.templateId,
          orElse: () => throw StateError('Component type not found'),
        );
      } catch (e) {
        StructuredLogger.error('🚫 Component type validation failed - unknown type', context: {
          'templateId': action.templateId,
          'availableTypes': ComponentType.values.map((t) => t.name).toList(),
          'validation_result': 'UNKNOWN_COMPONENT_TYPE',
        });
        return Failure('Unknown component type: ${action.templateId}');
      }


      // Validate position coordinates
      if (action.row < 0 || action.col < 0) {
        StructuredLogger.warning('🚫 Position validation failed - coordinates must be non-negative', context: {
          'invalid_row': action.row,
          'invalid_col': action.col,
          'validation_result': 'INVALID_COORDINATES',
        });
        return const Failure('Invalid position: coordinates must be non-negative');
      }

      StructuredLogger.debug('✅ Input validation passed', context: {
        'templateId': action.templateId,
        'componentType': componentType.name,
        'position': {'row': action.row, 'col': action.col},
      });

      // 🔍 STEP 2: Get and validate grid state
      StructuredLogger.debug('🔍 Grid state retrieval', context: {
        'grid_getter_type': '_getGrid',
        'notifier_type': notifiers.grid.runtimeType.toString(),
      });

      final grid = _getGrid(notifiers.grid);

      // Validate grid state consistency
      if (grid.rows <= 0 || grid.cols <= 0) {
        StructuredLogger.error('🚫 Grid state validation failed - invalid dimensions', context: {
          'grid_rows': grid.rows,
          'grid_cols': grid.cols,
          'validation_result': 'INVALID_GRID_DIMENSIONS',
        });
        return const Failure('Grid state is invalid: dimensions must be positive');
      }

      StructuredLogger.debug('🔍 Grid state analysis', context: {
        'grid_rows': grid.rows,
        'grid_cols': grid.cols,
        'grid_components_count': grid.components.length,
        'occupied_positions_count': grid.occupiedPositions.length,
        'grid_state_valid': true,
      });

      // Validate bounds
      if (action.row >= grid.rows || action.col >= grid.cols) {
        StructuredLogger.warning('🚫 Bounds validation failed - position out of bounds', context: {
          'requested_position': {'row': action.row, 'col': action.col},
          'grid_bounds': {'rows': grid.rows, 'cols': grid.cols},
          'validation_result': 'OUT_OF_BOUNDS',
        });
        return Failure('Position (${action.row}, ${action.col}) is out of bounds for grid ${grid.rows}x${grid.cols}');
      }

      // Check for existing component
      final existingComponent = grid.componentAt(action.row, action.col);
      if (existingComponent != null) {
        StructuredLogger.warning('🚫 Occupancy validation failed - cell already occupied', context: {
          'position': {'row': action.row, 'col': action.col},
          'existing_component_id': existingComponent.id,
          'existing_component_type': existingComponent.type.name,
          'validation_result': 'CELL_OCCUPIED',
        });
        return Failure('Cell (${action.row}, ${action.col}) is already occupied by ${existingComponent.type.name}');
      }

      StructuredLogger.debug('✅ All validations passed', context: {
        'templateId': action.templateId,
        'position': {'row': action.row, 'col': action.col},
        'ready_for_placement': true,
      });

      // Create component using factory - this variable is used in logging/audit trail
      _factory.create(
        type: action.templateId, // Map templateId to type
        id: 'component_${DateTime.now().millisecondsSinceEpoch}',
        r: action.row,
        c: action.col,
      );

      // Register grid update with transaction using command pattern
      transaction.onCommit(() async {
        StructuredLogger.debug('🔄 COMPONENT PLACEMENT TRANSACTION COMMIT', context: {
          'templateId': action.templateId,
          'position': {'row': action.row, 'col': action.col},
          'notifierType': notifiers.grid.runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        });

        try {
          // Use unified interface for component placement
          final unifiedNotifier = notifiers.grid as IGameStateNotifier;

          StructuredLogger.debug('🔄 ATTEMPTING COMPONENT PLACEMENT', context: {
            'notifierType': unifiedNotifier.runtimeType.toString(),
            'hasPlaceComponentAsync': unifiedNotifier.runtimeType.toString().contains('placeComponentAsync'),
            'templateId': action.templateId,
            'componentType': componentType!.name,
          });

          // Try async placement first (for Enhanced features), fall back to sync
          bool placementSuccessful = false;
          try {
            await unifiedNotifier.placeComponentAsync(
              componentType,
              action.row,
              action.col,
            );
            StructuredLogger.info('✅ COMPONENT PLACEMENT SUCCESSFUL (async)', context: {
              'templateId': action.templateId,
              'componentType': componentType.name,
              'position': {'row': action.row, 'col': action.col},
              'placement_method': 'async',
            });
            placementSuccessful = true;
          } catch (asyncError) {
            StructuredLogger.warning('🔄 ASYNC PLACEMENT FAILED, TRYING SYNC FALLBACK', context: {
              'asyncError': asyncError.toString(),
              'templateId': action.templateId,
              'componentType': componentType.name,
              'fallback_attempted': true,
            });

            // Fallback to sync placement
            try {
              unifiedNotifier.placeComponent(
                componentType,
                action.row,
                action.col,
              );
              StructuredLogger.info('✅ COMPONENT PLACEMENT SUCCESSFUL (sync fallback)', context: {
                'templateId': action.templateId,
                'componentType': componentType.name,
                'position': {'row': action.row, 'col': action.col},
                'placement_method': 'sync_fallback',
              });
              placementSuccessful = true;
            } catch (syncError) {
              StructuredLogger.error('💥 BOTH ASYNC AND SYNC PLACEMENT FAILED', context: {
                'asyncError': asyncError.toString(),
                'syncError': syncError.toString(),
                'templateId': action.templateId,
                'componentType': componentType.name,
                'position': {'row': action.row, 'col': action.col},
                'placement_method': 'both_failed',
              });
              throw Exception('Component placement failed for both async and sync methods: async=${asyncError.toString()}, sync=${syncError.toString()}');
            }
          }

          if (placementSuccessful) {
            Logger.log('CreateComponent: successfully added ${componentType.name} from template ${action.templateId} at (${action.row}, ${action.col})');
          }
        } catch (e, stackTrace) {
          StructuredLogger.error('💥 COMPONENT PLACEMENT FAILED IN TRANSACTION', context: {
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
            'templateId': action.templateId,
            'componentType': componentType?.name ?? 'unknown',
            'position': {'row': action.row, 'col': action.col},
            'notifierType': notifiers.grid.runtimeType.toString(),
            'timestamp': DateTime.now().toIso8601String(),
            'error_type': e.runtimeType.toString(),
          }, error: e);
          rethrow;
        }
      });

      // Register rollback handler
      transaction.onRollback(() {
        Logger.log('CreateComponent: rollback - component creation reverted');
      });

      return const Success(null);
    } catch (e, stackTrace) {
      // Enhanced error handling with categorization
      String errorMessage;
      String errorCategory;

      if (e.toString().contains('out of bounds') || e.toString().contains('bounds')) {
        errorCategory = 'BOUNDS_VALIDATION_ERROR';
        errorMessage = 'Component placement failed due to bounds validation: ${e.toString()}';
      } else if (e.toString().contains('occupied') || e.toString().contains('collision')) {
        errorCategory = 'OCCUPANCY_VALIDATION_ERROR';
        errorMessage = 'Component placement failed due to cell occupancy: ${e.toString()}';
      } else if (e.toString().contains('component type') || e.toString().contains('template')) {
        errorCategory = 'COMPONENT_TYPE_ERROR';
        errorMessage = 'Component placement failed due to invalid component type: ${e.toString()}';
      } else if (e.toString().contains('grid') || e.toString().contains('state')) {
        errorCategory = 'GRID_STATE_ERROR';
        errorMessage = 'Component placement failed due to grid state issues: ${e.toString()}';
      } else if (e.toString().contains('notifier') || e.toString().contains('interface')) {
        errorCategory = 'NOTIFIER_INTERFACE_ERROR';
        errorMessage = 'Component placement failed due to notifier interface issues: ${e.toString()}';
      } else {
        errorCategory = 'UNKNOWN_ERROR';
        errorMessage = 'Component placement failed with unknown error: ${e.toString()}';
      }

      StructuredLogger.error('💥 COMPONENT PLACEMENT USE CASE FAILED', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'errorCategory': errorCategory,
        'templateId': action.templateId,
        'position': {'row': action.row, 'col': action.col},
        'notifierType': notifiers.grid.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'recovery_suggestion': _getRecoverySuggestion(errorCategory),
      }, error: e);

      Logger.log('❌ CreateComponent error [$errorCategory]: $errorMessage');
      return Failure(errorMessage);
    }
  }

  /// Convenience method for placeComponent standardization - call this from all other locations
  /// Maps ComponentType to templateId (assume mapping, e.g., type.name as templateId)
  static Future<Result<void>> placeComponent(
    ComponentType type,
    int row,
    int col,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    final action = CreateComponentFromTemplateAction(
      templateId: type.name, // Map type to templateId
      row: row,
      col: col,
    );
    final useCase = CreateComponentUseCase(PowerSimulationService(), ComponentFactory());
    return useCase.executeWithNotifiers(action, notifiers, transaction);
  }

  /// Get recovery suggestion based on error category
  static String _getRecoverySuggestion(String errorCategory) {
    switch (errorCategory) {
      case 'BOUNDS_VALIDATION_ERROR':
        return 'Try placing the component within the grid boundaries. Check grid dimensions and ensure position coordinates are valid.';
      case 'OCCUPANCY_VALIDATION_ERROR':
        return 'Choose an empty cell for component placement. The selected cell is already occupied by another component.';
      case 'COMPONENT_TYPE_ERROR':
        return 'Verify the component type is valid and supported. Check available component types in the level configuration.';
      case 'GRID_STATE_ERROR':
        return 'Reload the level or restart the application. The grid state appears to be corrupted.';
      case 'NOTIFIER_INTERFACE_ERROR':
        return 'Try restarting the application. There may be an issue with the game state management system.';
      case 'UNKNOWN_ERROR':
      default:
        return 'Try restarting the application or contact support if the issue persists.';
    }
  }

  /// Get occupied grid positions for collision detection
  static Set<String> getOccupiedPositions(NotifierContext notifiers) {
    StructuredLogger.debug('🔍 GETTING OCCUPIED POSITIONS', context: {
      'notifierType': notifiers.grid.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      final grid = _getGrid(notifiers.grid);
      final occupiedPositions = grid.components.values
          .map((component) => '${component.row},${component.col}')
          .toSet();

      StructuredLogger.debug('✅ OCCUPIED POSITIONS RETRIEVED', context: {
        'totalOccupied': occupiedPositions.length,
        'samplePositions': occupiedPositions.take(5).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return occupiedPositions;
    } catch (e, stackTrace) {
      StructuredLogger.error('💥 FAILED TO GET OCCUPIED POSITIONS', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'notifierType': notifiers.grid.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }, error: e);
      return {};
    }
  }

}