import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/core/persistence/storage_service.dart';

void main() {
  group('EnhancedGameStateNotifier Tests', () {
    late ProviderContainer container;
    late EnhancedGameStateNotifier gameStateNotifier;

    setUp(() {
      container = ProviderContainer(overrides: [
        commandStackProvider.overrideWithValue(InMemoryCommandStack()),
        simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
        netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
        storageServiceProvider.overrideWithValue(StorageService()),
        componentFactoryProvider.overrideWithValue(ComponentFactory()),
      ]);
      gameStateNotifier = container.read(enhancedGameStateNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should have no components', () {
      expect(gameStateNotifier.state.grid.getAllComponents(), isEmpty);
      expect(gameStateNotifier.state.grid.connections, isEmpty);
      expect(gameStateNotifier.state.isSimulating, isFalse);
      expect(gameStateNotifier.state.isComplete, isFalse);
    });

    test('placeComponent should add the component to the grid', () async {
      await gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      expect(gameStateNotifier.state.grid.getComponentCount(), 1);
      expect(gameStateNotifier.state.grid.getComponentAt(0, 0)?.type, ComponentType.battery);
    });

    test('addConnection should add a connection between components', () async {
      await gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      await gameStateNotifier.placeComponent(ComponentType.wire, 0, 1);

      final components = gameStateNotifier.state.grid.getAllComponents();
      final battery = components[0];
      final wire = components[1];

      await gameStateNotifier.addConnection(battery.id, wire.id);
      expect(gameStateNotifier.state.grid.getConnections(battery.id), contains(wire.id));
      expect(gameStateNotifier.state.grid.getConnections(wire.id), contains(battery.id));
    });

    test('toggleSimulation should change the simulation state', () {
      expect(gameStateNotifier.state.isSimulating, isFalse);
      gameStateNotifier.toggleSimulation();
      expect(gameStateNotifier.state.isSimulating, isTrue);
      gameStateNotifier.toggleSimulation();
      expect(gameStateNotifier.state.isSimulating, isFalse);
    });

    test('selectComponent should update the selected component ID', () async {
      expect(gameStateNotifier.state.interactionState.selectedComponentId, isNull);
      await gameStateNotifier.selectComponent('test_id');
      expect(gameStateNotifier.state.interactionState.selectedComponentId, 'test_id');
      await gameStateNotifier.selectComponent(null);
      expect(gameStateNotifier.state.interactionState.selectedComponentId, isNull);
    });

    test('resetLevel should clear the state', () async {
      await gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      gameStateNotifier.toggleSimulation();
      expect(gameStateNotifier.state.grid.getComponentCount(), 1);
      expect(gameStateNotifier.state.isSimulating, isTrue);

      gameStateNotifier.resetLevel();
      expect(gameStateNotifier.state.grid.getComponentCount(), 0);
      expect(gameStateNotifier.state.grid.connections, isEmpty);
      expect(gameStateNotifier.state.isSimulating, isFalse);
    });
  });
}
