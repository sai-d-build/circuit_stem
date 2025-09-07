import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

/// StateNotifier version of PaletteController for consistent state management
class PaletteStateNotifier extends StateNotifier<PaletteState> {
  PaletteStateNotifier(PaletteState initialState) : super(initialState);

  /// Update the entire state
  void updateState(PaletteState newState) {
    if (state != newState) {
      state = newState;
    }
  }

  /// Select a component type
  void selectComponent(String? componentType) {
    state = state.copyWith(selectedComponentType: componentType);
  }

  /// Update search query
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Toggle a filter
  void toggleFilter(String filter) {
    final filters = List<String>.from(state.activeFilters);
    if (filters.contains(filter)) {
      filters.remove(filter);
    } else {
      filters.add(filter);
    }
    state = state.copyWith(activeFilters: filters);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(activeFilters: []);
  }

  /// Check if a component can be used
  bool canUseComponent(String componentType) {
    final inventory = state.inventory[componentType];
    return inventory?.canUse ?? false;
  }

  /// Use a component (decrement available count)
  void useComponent(String componentType) {
    final inventory = state.inventory[componentType];
    if (inventory != null && inventory.canUse) {
      final updatedInventory = inventory.copyWith(
        available: inventory.available - 1,
        used: inventory.used + 1,
      );

      final newInventoryMap = Map<String, ComponentInventory>.from(state.inventory);
      newInventoryMap[componentType] = updatedInventory;

      state = state.copyWith(inventory: newInventoryMap);
    }
  }

  /// Return a component (increment available count)
  void returnComponent(String componentType) {
    final inventory = state.inventory[componentType];
    if (inventory != null && inventory.used > 0) {
      final updatedInventory = inventory.copyWith(
        available: inventory.available + 1,
        used: inventory.used - 1,
      );

      final newInventoryMap = Map<String, ComponentInventory>.from(state.inventory);
      newInventoryMap[componentType] = updatedInventory;

      state = state.copyWith(inventory: newInventoryMap);
    }
  }

  /// Reset to initial state
  void reset() {
    // This would need the initial state passed in during construction
    // For now, we'll keep it simple
  }
}

/// Provider for PaletteStateNotifier
final paletteStateNotifierProvider = StateNotifierProvider.family<PaletteStateNotifier, PaletteState, String>(
  (ref, levelId) {
    // Get the current palette state from the existing provider
    final currentState = ref.watch(paletteStateProvider(levelId));
    return PaletteStateNotifier(currentState);
  },
);