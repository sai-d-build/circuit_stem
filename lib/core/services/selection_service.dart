import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';

class SelectionState {
  final ComponentModel? selectedComponent;
  final GridPosition? selectedPosition;
  final List<ComponentModel> multiSelection;
  final bool isDragging;
  final bool isMultiSelectMode;

  const SelectionState({
    this.selectedComponent,
    this.selectedPosition,
    this.multiSelection = const [],
    this.isDragging = false,
    this.isMultiSelectMode = false,
  });

  SelectionState copyWith({
    ComponentModel? selectedComponent,
    GridPosition? selectedPosition,
    List<ComponentModel>? multiSelection,
    bool? isDragging,
    bool? isMultiSelectMode,
  }) {
    return SelectionState(
      selectedComponent: selectedComponent ?? this.selectedComponent,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      multiSelection: multiSelection ?? this.multiSelection,
      isDragging: isDragging ?? this.isDragging,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
    );
  }
}
final selectionServiceProvider = StateNotifierProvider.family<SelectionService, SelectionState, String>(
  (ref, levelId) {
    MigrationTracker.markFileMigrated('selection_service.dart', DateTime.now().toIso8601String());
    return SelectionService(levelId: levelId);
  },
);


class SelectionService extends StateNotifier<SelectionState> {
  final String levelId;

  SelectionService({required this.levelId})
      : super(const SelectionState());

  void selectComponent(ComponentModel component) {
    state = state.copyWith(
      selectedComponent: component,
      selectedPosition: GridPosition(row: component.row, col: component.col),
      multiSelection: state.isMultiSelectMode ? [...state.multiSelection, component] : [component],
    );
  }

  void selectPosition(GridPosition position) {
    state = state.copyWith(
      selectedPosition: position,
      selectedComponent: null,
    );
  }

  void clearSelection() {
    state = const SelectionState();
  }

  void toggleMultiSelectMode() {
    state = state.copyWith(isMultiSelectMode: !state.isMultiSelectMode);
  }

  void setDragging(bool isDragging) {
    state = state.copyWith(isDragging: isDragging);
  }

  bool isComponentSelected(String componentId) {
    if (state.selectedComponent?.id == componentId) return true;
    return state.multiSelection.any((component) => component.id == componentId);
  }

  bool isPositionSelected(GridPosition position) {
    return state.selectedPosition == position;
  }

  List<ComponentModel> getSelectedComponents() {
    if (state.selectedComponent != null) {
      return [state.selectedComponent!];
    }
    return state.multiSelection;
  }
}