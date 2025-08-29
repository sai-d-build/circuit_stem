import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_engine_state.dart';
import 'use_cases/base_use_case.dart';
import 'use_cases/component_action.dart';
import 'game_engine_orchestrator.dart';
import 'providers.dart';
import 'core/result.dart';

// Export legacy use cases (for compatibility)
export 'use_cases/check_win_condition_use_case.dart';
export 'use_cases/create_component_use_case.dart';
export 'use_cases/load_level_use_case.dart';
export 'use_cases/restart_level_use_case.dart';
export 'use_cases/simulate_power_flow_use_case.dart';
export 'use_cases/undo_use_case.dart';
export 'use_cases/update_component_use_case.dart';

// Export optimized notifier-integrated use cases (v2) - these replace legacy versions
export 'use_cases/tap_component_use_case_v2.dart';
export 'use_cases/move_component_use_case_v2.dart';
export 'use_cases/toggle_pause_use_case_v2.dart';
export 'use_cases/select_palette_component_use_case_v2.dart';
export 'use_cases/rotate_component_use_case_v2.dart';
export 'use_cases/simulate_power_flow_use_case_v2.dart';
export 'use_cases/update_component_use_case_v2.dart';
export 'use_cases/create_component_use_case_v2.dart';
export 'use_cases/load_level_use_case_v2.dart';
export 'use_cases/notifier_integrated_use_case.dart';

/// Adapter that allows existing use cases to work with the hybrid notifier system
/// by executing them against the current composite state and applying diffs
class UseCaseAdapter {
  final GameEngineOrchestrator _orchestrator;
  
  const UseCaseAdapter(this._orchestrator);
  
  /// Execute a use case and apply its changes to granular notifiers
  Future<Result<GameEngineState>> executeUseCase<TAction extends ComponentAction>(
    UseCase<TAction> useCase,
    TAction action
  ) async {
    return await _orchestrator.executeUseCase(useCase, action);
  }
  
  /// Execute a use case directly against a provided state (for testing)
  Future<Result<GameEngineState>> executeUseCaseWithState<TAction extends ComponentAction>(
    UseCase<TAction> useCase,
    TAction action,
    GameEngineState currentState,
  ) async {
    // Execute the use case against the provided state
    return await useCase.execute(currentState, action);
  }
}

/// Provider for the use case adapter
final useCaseAdapterProvider = Provider<UseCaseAdapter>((ref) {
  final orchestrator = ref.watch(gameEngineOrchestratorProvider.notifier);
  return UseCaseAdapter(orchestrator);
});