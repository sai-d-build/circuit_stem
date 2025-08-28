import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/grid.dart';

class GridNotifier extends StateNotifier<Grid> {
  GridNotifier() : super(const Grid(rows: 0, cols: 0));

  // Implement methods to manipulate the grid
  void updateGrid(Grid newGrid) {
    state = newGrid;
  }
  
  // Method to execute actions in transaction
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    // Implementation for transaction-based grid updates
    // This will be expanded based on the specific action types
  }
}