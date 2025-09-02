import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/logger.dart';

/// Represents the current component selection state
class ComponentSelectionState {
  final String? selectedComponentId;
  final bool isDragging;
  final bool isPaletteSelection;

  const ComponentSelectionState({
    this.selectedComponentId,
    this.isDragging = false,
    this.isPaletteSelection = false,
  });

  ComponentSelectionState copyWith({
    String? selectedComponentId,
    bool? isDragging,
    bool? isPaletteSelection,
  }) {
    return ComponentSelectionState(
      selectedComponentId: selectedComponentId ?? this.selectedComponentId,
      isDragging: isDragging ?? this.isDragging,
      isPaletteSelection: isPaletteSelection ?? this.isPaletteSelection,
    );
  }

  bool get hasSelection => selectedComponentId != null;
  bool get isEmpty => selectedComponentId == null;
}

/// Notifier for managing component selection state
class ComponentSelectionNotifier extends StateNotifier<ComponentSelectionState> {
  ComponentSelectionNotifier() : super(const ComponentSelectionState());

  /// Select a component from the grid
  void selectGridComponent(String componentId) {
    state = ComponentSelectionState(
      selectedComponentId: componentId,
      isDragging: false,
      isPaletteSelection: false,
    );
    Logger.log('ComponentSelection: Selected grid component $componentId');
  }

  /// Select a component from the palette
  void selectPaletteComponent(String componentId) {
    state = ComponentSelectionState(
      selectedComponentId: componentId,
      isDragging: false,
      isPaletteSelection: true,
    );
    Logger.log('ComponentSelection: Selected palette component $componentId');
  }

  /// Start dragging the selected component
  void startDragging() {
    if (state.hasSelection) {
      state = state.copyWith(isDragging: true);
      Logger.log('ComponentSelection: Started dragging ${state.selectedComponentId}');
    }
  }

  /// Stop dragging
  void stopDragging() {
    state = state.copyWith(isDragging: false);
    Logger.log('ComponentSelection: Stopped dragging');
  }

  /// Clear the current selection
  void clearSelection() {
    final previousId = state.selectedComponentId;
    state = const ComponentSelectionState();
    Logger.log('ComponentSelection: Cleared selection (was $previousId)');
  }

  /// Check if a specific component is selected
  bool isComponentSelected(String componentId) {
    return state.selectedComponentId == componentId;
  }

  /// Get the currently selected component ID
  String? get selectedComponentId => state.selectedComponentId;

  /// Check if currently dragging
  bool get isDragging => state.isDragging;

  /// Check if selection is from palette
  bool get isPaletteSelection => state.isPaletteSelection;

  /// Check if selection is from grid
  bool get isGridSelection => state.hasSelection && !state.isPaletteSelection;

  /// Get current state (for V2 API compatibility)
  ComponentSelectionState get current => state;

  /// Set state directly (for V2 API compatibility)
  void setState(ComponentSelectionState? newState) {
    state = newState ?? const ComponentSelectionState();
    Logger.log('ComponentSelection: State set directly');
  }

  /// Select component (for V2 API compatibility)
  void selectComponent(String componentId) {
    selectGridComponent(componentId);
  }
}

// Provider for ComponentSelectionNotifier
final componentSelectionNotifierProvider = StateNotifierProvider<ComponentSelectionNotifier, ComponentSelectionState>((ref) {
  return ComponentSelectionNotifier();
});