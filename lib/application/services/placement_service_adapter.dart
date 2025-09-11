import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart' as ucs;
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/application/states/game_canvas_state.dart';
import 'package:sparkcircuit/application/use_cases/create_component_use_case.dart';
import 'package:sparkcircuit/application/use_cases/notifier_integrated_use_case.dart';
import 'package:sparkcircuit/application/transaction.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';

class PlacementServiceAdapter {
  final dynamic gameStateNotifier;
  final dynamic paletteStateNotifier;
  final dynamic componentPlacementService;
  final String levelId;

  PlacementServiceAdapter({
    required this.gameStateNotifier,
    required this.paletteStateNotifier,
    required this.componentPlacementService,
    required this.levelId,
  });

  Future<bool> placeComponent(ComponentType componentType, int row, int col) async {
    // Mark file as migrated to unified provider
    MigrationTracker.markFileMigrated('placement_service_adapter.dart', DateTime.now().toIso8601String());

    try {
      // Get game state for validation
      final gameState = gameStateNotifier.state;

      // Create grid configuration for validation
      final config = ucs.GridConfiguration(
        rows: gameState.grid.rows,
        cols: gameState.grid.cols,
        cellSize: 60.0, // Default cell size
        scale: 1.0,
        panOffset: Offset.zero,
      );

      // Check if position is valid using UnifiedCoordinateService
      final gridPos = Offset(col.toDouble(), row.toDouble());
      final isValid = ucs.UnifiedCoordinateService().isInGridBounds(gridPos, config);

      if (!isValid) {
        return false;
      }

      // Check if position is occupied
      final isOccupied = gameState.grid.components.values.any(
        (component) => component.row == row && component.col == col
      );

      if (isOccupied) {
        return false;
      }

      // Use centralized CreateComponentUseCase instead of direct notifier call
      final transaction = GameTransaction();
      final result = await CreateComponentUseCase.placeComponent(
        componentType,
        row,
        col,
        _createMinimalNotifierContext(),
        transaction,
      );

      if (result.isSuccess) {
        await transaction.commit();

        // Update palette state
        paletteStateNotifier.stopPlacingComponent();
        return true;
      } else {
        transaction.rollback();
        return false;
      }
    } catch (e) {
      debugPrint('PlacementServiceAdapter error: $e');
      return false;
    }
  }

  Future<bool> placeWire(List<GridPosition> path) async {
    try {
      // Validate wire path
      if (path.isEmpty) return false;

      // For now, place as special wire component
      // final gameNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);

      // This would need extension in v3 to support wire paths
      // gameNotifier.placeWire(path);

      return true;
    } catch (e) {
      debugPrint('Wire placement error: $e');
      return false;
    }
  }

  /// Create minimal NotifierContext with just the grid notifier
  NotifierContext _createMinimalNotifierContext() {
    return NotifierContext(
      grid: gameStateNotifier,
      history: null,
      progress: null,
      selection: null,
      interaction: null,
      paletteManager: null,
    );
  }

}