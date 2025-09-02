import 'package:flutter_riverpod/flutter_riverpod.dart';

import './check_win_condition_use_case.dart';
import './create_component_use_case.dart';
import './load_level_use_case_v2.dart';
import './move_component_use_case_v2.dart';
import './restart_level_use_case_v2.dart';
import './rotate_component_use_case_v2.dart';
import './select_palette_component_use_case_v2.dart';
import './simulate_power_flow_use_case_v2.dart';
import './tap_component_use_case_v2.dart';
import './toggle_pause_use_case_v2.dart';
import './undo_use_case_v2.dart';
import './update_component_use_case_v2.dart';
import '../services/power_simulation_service.dart';
import '../services/goal_checking_service.dart';
import '../services/component_palette_manager.dart';
import '../services/component_factory.dart';
import '../../core/simulation/mna_solver.dart';
import '../../core/commands/command_stack.dart';
import '../../core/commands/in_memory_command_stack.dart';
import '../../infrastructure/persistence/shared_preferences_storage_service.dart';
import '../../core/simulation/simulation_engine.dart';
import '../../core/simulation/basic_simulation_engine.dart';
import '../../core/simulation/netlist_builder.dart';

final mnaSolverProvider = Provider((ref) => BasicMNASolver());

final powerSimulationServiceProvider = Provider((ref) {
  final solver = ref.watch(mnaSolverProvider);
  return PowerSimulationService(); // Fix: Remove solver parameter if not needed
});

final goalCheckingServiceProvider = Provider((ref) => GoalCheckingService());

final componentPaletteManagerProvider = Provider((ref) {
  return const ComponentPaletteManager(availableTemplates: []);
});

final checkWinConditionUseCaseProvider = Provider((ref) {
  final goalCheckingService = ref.watch(goalCheckingServiceProvider);
  return CheckWinConditionUseCase(goalCheckingService);
});

final createComponentUseCaseProvider = Provider((ref) {
  final factory = ref.watch(componentFactoryProvider);
  final simulation = ref.watch(powerSimulationServiceProvider);
  return CreateComponentUseCase(factory, simulation);
});

final createComponentUseCaseV2Provider = Provider((ref) {
  final factory = ref.watch(componentFactoryProvider);
  final simulation = ref.watch(powerSimulationServiceProvider);
  return CreateComponentUseCaseV2(factory, simulation);
});

final loadLevelUseCaseV2Provider = Provider((ref) {
  final powerSimulationService = ref.watch(powerSimulationServiceProvider);
  final goalCheckingService = ref.watch(goalCheckingServiceProvider);
  return LoadLevelUseCaseV2(powerSimulationService, goalCheckingService);
});

final moveComponentUseCaseV2Provider = Provider((ref) {
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return MoveComponentUseCaseV2(simulationService);
});

final restartLevelUseCaseV2Provider = Provider((ref) {
  final powerSimulationService = ref.watch(powerSimulationServiceProvider);
  return RestartLevelUseCaseV2(powerSimulationService);
});

final rotateComponentUseCaseV2Provider = Provider((ref) {
  return const RotateComponentUseCaseV2();
});

final selectPaletteComponentUseCaseV2Provider = Provider((ref) {
  return const SelectPaletteComponentUseCaseV2();
});

final simulatePowerFlowUseCaseV2Provider = Provider((ref) {
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return SimulatePowerFlowUseCaseV2(simulationService);
});

final tapComponentUseCaseV2Provider = Provider((ref) {
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return TapComponentUseCaseV2(simulationService);
});

final togglePauseUseCaseV2Provider = Provider((ref) {
  return const TogglePauseUseCaseV2();
});

final undoUseCaseV2Provider = Provider((ref) {
  return UndoUseCaseV2();
});

final updateComponentUseCaseV2Provider = Provider((ref) {
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return UpdateComponentUseCaseV2(simulationService);
});

// Missing service providers
final componentFactoryProvider = Provider((ref) => ComponentFactory());

final simulationEngineProvider = Provider((ref) => BasicSimulationEngine());

final netlistBuilderProvider = Provider((ref) => NetlistBuilder());

final commandStackProvider = Provider((ref) => InMemoryCommandStack());

final storageServiceProvider = Provider((ref) => SharedPreferencesStorageService());
