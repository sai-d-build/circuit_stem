import 'package:flutter/material.dart';
import '../../domain/entities/grid.dart';
import 'game_engine_state.dart'; // Corrected import
import 'render_state.dart'; // Corrected import


/// The pure engine core that applies updates and produces new GameEngineState.
class GameEngineCore {
  GameEngineCore(); // No longer takes SimulationManager

  GameEngineState commit(
    GameEngineState oldState,
    Grid newGrid, {
    String? selectedComponentId,
    String? draggedComponentId,
    Offset? dragPosition,
    bool? isPaused,
    bool? isWin,
  }) {
    // Step 1: let components evaluate themselves
    // TODO: Implement component behavior evaluation when behaviors are properly integrated

    // Step 2: The power simulation is now handled by SimulationManager directly updating the state.
    // So, we just use the newGrid as is, assuming it has the correct power state.

    // Step 3: return new state
    return oldState.copyWith(
      grid: newGrid, // Use newGrid directly
      renderState: RenderState(
        grid: newGrid, // Use newGrid directly
        poweredComponentIds: newGrid.components.values
            .where((c) => c.isPowered)
            .map((c) => c.id)
            .toSet(), // Get powered IDs from the grid
        draggedComponentId: draggedComponentId ?? oldState.draggedComponentId,
        dragPosition: dragPosition ?? oldState.dragPosition,
      ),
      selectedComponentId: selectedComponentId ?? oldState.selectedComponentId,
      draggedComponentId: draggedComponentId ?? oldState.draggedComponentId,
      dragPosition: dragPosition ?? oldState.dragPosition,
      isPaused: isPaused ?? oldState.isPaused,
      isWin: isWin ?? oldState.isWin,
    );
  }
}
