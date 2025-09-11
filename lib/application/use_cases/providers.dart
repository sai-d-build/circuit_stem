import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/migration/migration_tracker.dart';

// ============================================================================
// LEGACY COMPATIBILITY BACKWARD EXPORTS
// ============================================================================
// These providers have been moved to organized categories in core_providers.dart
// This file maintains backward compatibility for existing imports.
// DO NOT ADD NEW PROVIDERS HERE - add them to the appropriate category file instead.

// Re-export core providers from categorized files for backward compatibility
export '../providers/core_providers.dart' show
  // Simulation providers
  mnaSolverProvider,
  powerSimulationServiceProvider,
  netlistBuilderProvider,
  simulationEngineProvider,

  // Component providers
  componentFactoryProvider,
  componentPaletteManagerProvider,

  // Storage providers
  storageServiceProvider,

  // Goal checking
  goalCheckingServiceProvider;

// Legacy file-wide exports (for tests and legacy code)
// These exports allow existing files to continue working
export '../providers/core_providers.dart';

import './check_win_condition_use_case.dart';
import './create_component_use_case.dart';
import './load_level_use_case.dart';
import './move_component_use_case.dart';
import './restart_level_use_case.dart';
import './rotate_component_use_case.dart';
import './select_palette_component_use_case.dart';
import './simulate_power_flow_use_case.dart';
import './tap_component_use_case.dart';
import './toggle_pause_use_case.dart';
import './undo_use_case.dart';
import './update_component_use_case.dart';
import '../services/power_simulation_service.dart';
import '../services/goal_checking_service.dart';
import '../services/component_palette_manager.dart';
import '../services/component_factory.dart';
import '../../core/simulation/mna_solver.dart';
import '../../core/commands/in_memory_command_stack.dart';
import '../../infrastructure/persistence/shared_preferences_storage_service.dart';
import '../../core/simulation/basic_simulation_engine.dart';
import '../../core/simulation/netlist_builder.dart';

final mnaSolverProvider = Provider((ref) => BasicMNASolver());

final powerSimulationServiceProvider = Provider((ref) {
  return PowerSimulationService();
});

final goalCheckingServiceProvider = Provider((ref) => GoalCheckingService());

final componentPaletteManagerProvider = Provider((ref) {
  return const ComponentPaletteManager(availableTemplates: []);
});

final checkWinConditionUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('check_win_condition_use_case.dart', DateTime.now().toIso8601String());
  final goalCheckingService = ref.watch(goalCheckingServiceProvider);
  return CheckWinConditionUseCase(goalCheckingService);
});

final createComponentUseCaseProvider = Provider((ref) {
  final simulation = ref.watch(powerSimulationServiceProvider);
  final factory = ref.watch(componentFactoryProvider);
  return CreateComponentUseCase(simulation, factory);
});

final loadLevelUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('load_level_use_case.dart', DateTime.now().toIso8601String());
  final powerSimulationService = ref.watch(powerSimulationServiceProvider);
  final goalCheckingService = ref.watch(goalCheckingServiceProvider);
  return LoadLevelUseCase(powerSimulationService, goalCheckingService);
});

final moveComponentUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('move_component_use_case.dart', DateTime.now().toIso8601String());
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return MoveComponentUseCase(simulationService);
});

final restartLevelUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('restart_level_use_case.dart', DateTime.now().toIso8601String());
  final powerSimulationService = ref.watch(powerSimulationServiceProvider);
  return RestartLevelUseCase(powerSimulationService);
});

final rotateComponentUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('rotate_component_use_case.dart', DateTime.now().toIso8601String());
  return const RotateComponentUseCase();
});

final selectPaletteComponentUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('select_palette_component_use_case.dart', DateTime.now().toIso8601String());
  return const SelectPaletteComponentUseCase();
});

final simulatePowerFlowUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('simulate_power_flow_use_case.dart', DateTime.now().toIso8601String());
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return SimulatePowerFlowUseCase(simulationService);
});

final tapComponentUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('tap_component_use_case.dart', DateTime.now().toIso8601String());
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return TapComponentUseCase(simulationService);
});

final togglePauseUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('toggle_pause_use_case.dart', DateTime.now().toIso8601String());
  return const TogglePauseUseCase();
});

final undoUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('undo_use_case.dart', DateTime.now().toIso8601String());
  return UndoUseCase();
});

final updateComponentUseCaseProvider = Provider((ref) {
  MigrationTracker.markFileMigrated('update_component_use_case.dart', DateTime.now().toIso8601String());
  final simulationService = ref.watch(powerSimulationServiceProvider);
  return UpdateComponentUseCase(simulationService);
});


// WARNING: If you're adding new providers, please add them to:
// - lib/application/providers/core_providers.dart (for core business logic)
// - lib/application/providers/game_providers.dart (for game engines)
// - lib/application/providers/test_providers.dart (for test mocks)
// And then add the export here for backward compatibility.

// Missing service providers
final componentFactoryProvider = Provider((ref) => ComponentFactory());

final simulationEngineProvider = Provider((ref) => BasicSimulationEngine());

final netlistBuilderProvider = Provider((ref) => NetlistBuilder());

final commandStackProvider = Provider((ref) => InMemoryCommandStack());

final storageServiceProvider = Provider<SharedPreferencesStorageService>((ref) {
  throw UnimplementedError('SharedPreferencesStorageService must be initialized in main.dart and overridden via ProviderScope');
});
