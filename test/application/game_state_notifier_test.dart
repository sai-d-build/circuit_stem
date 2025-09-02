import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/application/enhanced_game_state_notifier.dart';
import 'package:sparkcircuit/core/commands/command_stack.dart';
import 'package:sparkcircuit/core/commands/create_component_command.dart';
import 'package:sparkcircuit/core/commands/game_command.dart';
import 'package:sparkcircuit/core/persistence/storage_service.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/core/simulation/simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/simulation_result.dart';
import 'package:sparkcircuit/domain/entities/component.dart';

import 'package:sparkcircuit/domain/entities/level_definition.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/simulation/circuit_netlist.dart'; // Import CircuitNetlist

// Mocks
class MockSimulationEngine extends Mock implements SimulationEngine {}
class MockNetlistBuilder extends Mock implements NetlistBuilder {}
class MockStorageService extends Mock implements StorageService {}
class MockCommandStack extends Mock implements CommandStack {}
class MockGameCommand extends Mock implements GameCommand {}
class MockComponentFactory extends Mock implements ComponentFactory {} // Mock ComponentFactory

void main() {
  group('EnhancedGameStateNotifier', () {
    late EnhancedGameStateNotifier notifier;
    late MockSimulationEngine mockSimulationEngine;
    late MockNetlistBuilder mockNetlistBuilder;
    late MockStorageService mockStorageService;
    late MockCommandStack mockCommandStack;
    late MockComponentFactory mockComponentFactory; // Declare mock
    late GameState initialState;

    setUp(() {
      mockSimulationEngine = MockSimulationEngine();
      mockNetlistBuilder = MockNetlistBuilder();
      mockStorageService = MockStorageService();
      mockCommandStack = MockCommandStack();
      mockComponentFactory = MockComponentFactory(); // Initialize mock

            final level = LevelDefinition(
        levelId: 'test_level',
        version: '1.0.0',
        metadata: const LevelMetadata(
          id: 'test_level',
          title: 'Test Level',
          description: 'A test level',
          difficulty: 'easy',
        ),
        grid: const GridConfig(
          width: 10,
          height: 10,
        ),
        components: const ComponentConfig(
          available: [],
          preplaced: [],
        ),
        goals: const [],
        validation: const ValidationRules(
          circuitRules: [],
          successConditions: [],
        ),
      );
      initialState = GameState.initial(level);

      notifier = EnhancedGameStateNotifier(
        simulationEngine: mockSimulationEngine,
        netlistBuilder: mockNetlistBuilder,
        storageService: mockStorageService,
        commandStack: mockCommandStack,
        componentFactory: mockComponentFactory, // Pass mock
      )..state = initialState; // Set initial state for tests

      // Mock default behaviors
            when(mockNetlistBuilder.buildNetlist(any)).thenReturn(CircuitNetlist(components: const [], connections: const [], nodes: const {}, timestamp: DateTime.now()));
            when(mockSimulationEngine.solveDC(any)).thenAnswer((_) async => SimulationResult(nodeVoltages: {}, branchCurrents: {}, componentStates: {}, diagnostics: [], timestamp: DateTime.now(), isValid: true));
      when(mockStorageService.saveState(any)).thenAnswer((_) async {});
    });

    test('placeComponent creates and executes a command', () async {
      // Mock the componentFactory.create method
      when(mockComponentFactory.create(
        type: anyNamed('type'),
        id: anyNamed('id'),
        r: anyNamed('r'),
        c: anyNamed('c'),
      )).thenReturn(ComponentModel(id: 'new_comp', type: ComponentType.battery, row: 0, col: 0));

      await notifier.placeComponent(ComponentType.battery, 2, 3);

      // Verify that a command was pushed to the stack
      final captured = verify(mockCommandStack.push(captureAny)).captured;
      expect(captured.first, isA<CreateComponentCommand>());

      // Verify simulation and save were called
      verify(mockSimulationEngine.solveDC(any)).called(1);
            verify(mockStorageService.saveState(any, any)).called(1);
    });

    test('undo executes the undo method of a command from the stack', () async {
      final mockCommand = MockGameCommand();
      final stateAfterUndo = initialState.copyWith(isPaused: true); // Some distinct state

      when(mockCommandStack.undo()).thenReturn(mockCommand);
            when(mockCommand.undo(any as GameState)).thenReturn(stateAfterUndo);

      await notifier.undo();

      // Verify that the notifier's state is updated to the result of the command's undo
      expect(notifier.state, stateAfterUndo);

      // Verify simulation and save were called
      verify(mockSimulationEngine.solveDC(any)).called(1);
            verify(mockStorageService.saveState(any, any)).called(1);
    });

    test('redo executes the execute method of a command from the stack', () async {
      final mockCommand = MockGameCommand();
      final stateAfterRedo = initialState.copyWith(isPaused: true); // Some distinct state

      when(mockCommandStack.redo()).thenReturn(mockCommand);
            when(mockCommand.execute(any as GameState)).thenReturn(stateAfterRedo);

      await notifier.redo();

      // Verify that the notifier's state is updated to the result of the command's execute
      expect(notifier.state, stateAfterRedo);

      // Verify simulation and save were called
      verify(mockSimulationEngine.solveDC(any)).called(1);
            verify(mockStorageService.saveState(any, any)).called(1);
    });
  });
}