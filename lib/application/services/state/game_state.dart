import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/grid.dart';
import '../../../domain/entities/component.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required Grid grid,
    required bool isPaused,
    required bool isWin,
    required List<ComponentModel> availableComponents,
    String? draggedComponentId,
    @Default(false) bool isShortCircuit,
    @Default({}) Map<String, bool> poweredComponents,
    @Default(0.0) double bulbIntensity,
    @Default(0.0) double wireOffset,
  }) = _GameState;

  factory GameState.initial() => const GameState(
        grid: Grid(rows: 0, cols: 0),
        isPaused: false,
        isWin: false,
        availableComponents: [],
      );
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.initial());

  void updateGrid(Grid newGrid) {
    state = state.copyWith(grid: newGrid);
  }

  void setPaused(bool isPaused) {
    state = state.copyWith(isPaused: isPaused);
  }

  void setWin(bool isWin) {
    state = state.copyWith(isWin: isWin);
  }

  void updatePoweredComponents(Map<String, bool> poweredComponents) {
    state = state.copyWith(poweredComponents: poweredComponents);
  }

  void setDraggedComponent(String? componentId) {
    state = state.copyWith(draggedComponentId: componentId);
  }

  void setShortCircuit(bool isShortCircuit) {
    state = state.copyWith(isShortCircuit: isShortCircuit);
  }

  void updateAnimationState(double bulbIntensity, double wireOffset) {
    state = state.copyWith(
      bulbIntensity: bulbIntensity,
      wireOffset: wireOffset,
    );
  }
}
