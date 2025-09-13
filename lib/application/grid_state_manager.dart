import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/interaction_engine.dart' as ie;
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/application/use_cases/interaction_use_case.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/core/services/feature_flag_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/canvas_interaction_controller.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';

/// GridStateManager provides centralized state management for grid operations
/// with atomic transactions to prevent race conditions and "ghost" components
class GridStateManager {
  final Ref ref;
  final String levelId;

  GridStateManager({required this.ref, required this.levelId});

  /// Atomic placement transaction that ensures component placement and drag state
  /// clearing happen in the same frame to prevent "ghost" components
  Future<bool> applyPlacementTransaction({
    required GridPosition position,
    required ComponentType componentType,
    String? componentId,
  }) async {
    final correlationId =
        'placement_${DateTime.now().millisecondsSinceEpoch}_${position.row}_${position.col}';

    StructuredLogger.info('🎯 ===== ATOMIC PLACEMENT TRANSACTION START =====',
        context: {
          'correlationId': correlationId,
          'position': '${position.row},${position.col}',
          'componentType': componentType.toString(),
          'componentId': componentId,
          'levelId': levelId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

    try {
      // Phase 1: Validate placement before transaction
      final validationResult =
          await _validatePlacement(position, componentType);
      if (!validationResult.isValid) {
        StructuredLogger.warning('🎯 ===== PLACEMENT VALIDATION FAILED =====',
            context: {
              'correlationId': correlationId,
              'position': '${position.row},${position.col}',
              'componentType': componentType.toString(),
              'error': validationResult.errorMessage,
              'levelId': levelId,
            });
        return false;
      }

      // Phase 2: Execute placement via InteractionEngine
      final interactionEngine =
          ref.read(ie.interactionEngineProvider(levelId).notifier);

      // Create a simple drag data object for the engine
      final dragData = _createDragData(componentType);

      // Convert GridPosition to screen coordinates for the engine
      final screenPosition = _gridToScreenPosition(position);

      await interactionEngine.handlePaletteDragEnd(
        dragData,
        screenPosition,
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
      );

      // Clear interaction state to prevent ghost components
      final interactionStateNotifier =
          ref.read(interactionStateProvider(levelId).notifier);
      interactionStateNotifier.transitionToMode(InteractionMode.idle);

      StructuredLogger.info(
          '🎯 ===== ATOMIC PLACEMENT TRANSACTION SUCCESS =====',
          context: {
            'correlationId': correlationId,
            'position': '${position.row},${position.col}',
            'componentType': componentType.toString(),
            'componentId': componentId,
            'levelId': levelId,
            'transactionTimeMs': DateTime.now().millisecondsSinceEpoch,
          });

      return true;
    } catch (e) {
      StructuredLogger.error(
          '🎯 ===== ATOMIC PLACEMENT TRANSACTION FAILED =====',
          context: {
            'correlationId': correlationId,
            'position': '${position.row},${position.col}',
            'componentType': componentType.toString(),
            'error': e.toString(),
            'levelId': levelId,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          error: e);

      return false;
    }
  }

  /// Validate placement before executing transaction
  Future<ValidationResult> _validatePlacement(
      GridPosition position, ComponentType componentType) async {
    // Get current game state
    final gameState = ref.read(interactionEngineProvider(levelId));

    // Check if position is within grid bounds
    if (position.row < 0 ||
        position.row >= gameState.grid.rows ||
        position.col < 0 ||
        position.col >= gameState.grid.cols) {
      return ValidationResult.invalid(DragDropErrorType.invalidPosition,
          details:
              'Position (${position.row},${position.col}) is outside grid bounds (${gameState.grid.rows}x${gameState.grid.cols})');
    }

    // Check if position is already occupied
    final existingComponent = gameState.grid.components.values.firstWhere(
      (component) =>
          component.row == position.row && component.col == position.col,
      orElse: () =>
          ComponentModel(id: '', type: ComponentType.wire, row: -1, col: -1),
    );

    if (existingComponent.id.isNotEmpty) {
      return ValidationResult.invalid(DragDropErrorType.positionOccupied,
          details:
              'Position (${position.row},${position.col}) is already occupied by ${existingComponent.type}');
    }

    // Check nearness rule if enabled
    if (FeatureFlagService.instance.nearnessRule) {
      final nearbyComponents = _getNearbyComponents(position, gameState);
      if (nearbyComponents.isNotEmpty) {
        return ValidationResult.invalid(
            DragDropErrorType.boundaryValidationFailed,
            details:
                'Component too close to existing components: ${nearbyComponents.map((c) => c.type.toString()).join(", ")}');
      }
    }

    return ValidationResult.valid();
  }

  /// Create drag data for component placement
  ComponentDragData _createDragData(ComponentType componentType) {
    return ComponentDragData(
      componentType: componentType,
      componentName: componentType.toString().split('.').last,
      cost: 1,
      description: 'Component for placement',
      defaultProperties: {},
      icon: Icons.circle, // Default icon
    );
  }

  /// Convert grid position to screen coordinates
  Offset _gridToScreenPosition(GridPosition position) {
    // Simple conversion using default grid settings
    return Offset(
      position.col * 60.0 + 30.0, // Center of cell
      position.row * 60.0 + 30.0,
    );
  }

  /// Get nearby components for nearness validation
  List<ComponentModel> _getNearbyComponents(
      GridPosition position, GameState gameState) {
    final nearby = <ComponentModel>[];

    // Check adjacent positions (Chebyshev distance = 1)
    for (var row = position.row - 1; row <= position.row + 1; row++) {
      for (var col = position.col - 1; col <= position.col + 1; col++) {
        if (row == position.row && col == position.col) continue; // Skip center

        final component = gameState.grid.components.values.firstWhere(
          (c) => c.row == row && c.col == col,
          orElse: () => ComponentModel(
              id: '', type: ComponentType.wire, row: -1, col: -1),
        );

        if (component.id.isNotEmpty) {
          nearby.add(component);
        }
      }
    }

    return nearby;
  }

  /// Check if atomic placement is enabled
  bool get isAtomicPlacementEnabled =>
      FeatureFlagService.instance.atomicPlacement;

  /// Get current grid state for debugging
  Map<String, dynamic> getDebugInfo() {
    final gameState = ref.read(interactionEngineProvider(levelId));
    final interactionState = ref.read(interactionStateProvider(levelId));

    return {
      'levelId': levelId,
      'gridSize': '${gameState.grid.rows}x${gameState.grid.cols}',
      'componentCount': gameState.grid.components.length,
      'interactionMode': interactionState.currentMode.toString(),
      'hasTargetPosition': interactionState.targetPosition != null,
      'atomicPlacementEnabled': isAtomicPlacementEnabled,
      'nearnessRuleEnabled': FeatureFlagService.instance.nearnessRule,
    };
  }
}

/// Validation result for placement operations
class ValidationResult {
  final bool isValid;
  final DragDropErrorType? error;
  final String? errorMessage;

  const ValidationResult(this.isValid, {this.error, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult(true);
  factory ValidationResult.invalid(DragDropErrorType error,
          {String? details}) =>
      ValidationResult(false, error: error, errorMessage: details);
}

/// Transaction class for atomic operations
class GameTransaction {
  Future<void> Function()? _commitHandler;
  Future<void> Function()? _rollbackHandler;
  bool _committed = false;
  bool _rolledBack = false;

  void onCommit(Future<void> Function() handler) {
    _commitHandler = handler;
  }

  void onRollback(Future<void> Function() handler) {
    _rollbackHandler = handler;
  }

  Future<void> commit() async {
    if (_committed || _rolledBack) {
      throw Exception('Transaction already finalized');
    }

    try {
      if (_commitHandler != null) {
        await _commitHandler!();
      }
      _committed = true;
    } catch (e) {
      await rollback();
      rethrow;
    }
  }

  Future<void> rollback() async {
    if (_committed || _rolledBack) {
      return; // Already finalized
    }

    try {
      if (_rollbackHandler != null) {
        await _rollbackHandler!();
      }
    } finally {
      _rolledBack = true;
    }
  }
}
