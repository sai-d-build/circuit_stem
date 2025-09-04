import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../common/logger.dart';

/// Notifier for managing the game grid state
class GridNotifier extends StateNotifier<Grid> {
  GridNotifier() : super(Grid.empty());

  /// Get the current grid state
  Grid get current => state;

  /// Set the grid state
  void setState(Grid newGrid) {
    Logger.log('GridNotifier: updating grid with ${newGrid.components.length} components');
    state = newGrid;
  }

  /// Update a single component in the grid
  void updateComponent(ComponentModel component) {
    final updatedComponents = Map<String, ComponentModel>.from(state.components);
    updatedComponents[component.id] = component;
    final newGrid = state.copyWith(components: updatedComponents);
    setState(newGrid);
  }

  /// Add a component to the grid
  void addComponent(ComponentModel component) {
    final updatedComponents = Map<String, ComponentModel>.from(state.components);
    updatedComponents[component.id] = component;
    final newGrid = state.copyWith(components: updatedComponents);
    setState(newGrid);
  }

  /// Remove a component from the grid
  void removeComponent(String componentId) {
    final updatedComponents = Map<String, ComponentModel>.from(state.components);
    updatedComponents.remove(componentId);
    final newGrid = state.copyWith(components: updatedComponents);
    setState(newGrid);
  }

  /// Clear all components from the grid
  void clearComponents() {
    final newGrid = state.copyWith(components: {});
    setState(newGrid);
  }

  /// Get component by ID
  ComponentModel? getComponentById(String id) {
    return state.components[id];
  }

  /// Get all components as a list
  List<ComponentModel> get componentsList => state.components.values.toList();

  /// Get components by type
  List<ComponentModel> getComponentsByType(ComponentType type) {
    return state.components.values.where((comp) => comp.type == type).toList();
  }
}

// Provider for GridNotifier
final gridNotifierProvider = StateNotifierProvider<GridNotifier, Grid>((ref) {
  return GridNotifier();
});