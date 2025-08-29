import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/grid.dart';

class GridNotifier extends StateNotifier<Grid> {
  GridNotifier() : super(const Grid(rows: 0, cols: 0));

  // Public snapshot getter for safe read access from outside the notifier
  Grid get current => state;

  // Public setter to allow controlled writes from orchestrator/use-cases
  void setState(Grid newGrid) => state = newGrid;

  // Implement methods to manipulate the grid
  void updateGrid(Grid newGrid) {
    state = newGrid;
  }
  
  // Method to execute actions in transaction
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    // Store current state for rollback
    final previousState = state;
    
    // Register rollback handler
    transaction.onRollback(() {
      state = previousState;
    });
    
    // Register commit handler - execute the grid update
    transaction.onCommit(() async {
      // TODO: Implement specific action handling based on action type
      // For now, this is a placeholder that will be expanded based on ComponentAction types
      if (action.toString().contains('Move') ||
          action.toString().contains('Rotate') ||
          action.toString().contains('Place')) {
        // Grid updates would happen here based on the action
        // Example: state = state.copyWith(components: updatedComponents);
      }
    });
    
    // Throw exception for failing actions to test rollback
    if (action.toString().contains('FailingAction')) {
      throw Exception('Simulated failure for FailingAction');
    }
    if (action.toString().contains('PartialFailAction')) {
      throw Exception('Simulated partial failure for PartialFailAction');
    }

    // Actions are queued for commit, not applied immediately
    // This ensures atomicity across all notifiers
  }
}