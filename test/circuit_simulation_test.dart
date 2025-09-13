import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';

void main() {
  group('Circuit Simulation Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        commandStackProvider.overrideWithValue(InMemoryCommandStack()),
        simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
        netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
        storageServiceProvider
            .overrideWithValue(SharedPreferencesStorageService()),
        componentFactoryProvider.overrideWithValue(ComponentFactory()),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('Simulation should run correctly', () async {
      final gameStateNotifier =
          container.read(enhancedGameStateNotifierProvider.notifier);

      gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      gameStateNotifier.placeComponent(ComponentType.wire, 0, 1);

      final components = gameStateNotifier.state.grid.getAllComponents();
      final battery = components[0];
      final wire = components[1];

      gameStateNotifier.addConnection(battery.id, wire.id);

      // The simulation is automatically run after each command,
      // so we just need to check the state.
      final simulationResult = gameStateNotifier.state.simulationResult;
      expect(simulationResult, isNotNull);
    });
  });
}
