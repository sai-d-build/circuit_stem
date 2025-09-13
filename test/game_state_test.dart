import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/application/game_engine/v3/game_engine_notifier_v3.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';

void main() {
  group('GameEngineNotifierV3 Tests', () {
    late ProviderContainer container;
    late GameEngineNotifierV3 gameStateNotifier;

    setUp(() async {
      final storageService = SharedPreferencesStorageService();
      await storageService.init();

      container = ProviderContainer(overrides: [
        commandStackProvider.overrideWithValue(InMemoryCommandStack()),
        simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
        netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
        storageServiceProvider.overrideWithValue(storageService),
        componentFactoryProvider.overrideWithValue(ComponentFactory()),
      ]);
      gameStateNotifier =
          container.read(enhancedGameStateNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should have no components', () {
      expect(gameStateNotifier.state.grid.getAllComponents(), isEmpty);
      expect(gameStateNotifier.state.grid.connections, isEmpty);
      expect(gameStateNotifier.state.isPaused, isFalse);
      expect(gameStateNotifier.state.isWin, isFalse);
    });

    test('placeComponent should add the component to the grid', () {
      gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      expect(gameStateNotifier.state.grid.getComponentCount(), 1);
      expect(gameStateNotifier.state.grid.getComponentAt(0, 0)?.type,
          ComponentType.battery);
    });

    test('addConnection should add a connection between components', () {
      gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      gameStateNotifier.placeComponent(ComponentType.wire, 0, 1);

      final components = gameStateNotifier.state.grid.getAllComponents();
      final battery = components[0];
      final wire = components[1];

      gameStateNotifier.addConnection(battery.id, wire.id);
      expect(gameStateNotifier.state.grid.getConnections(battery.id),
          contains(wire.id));
      expect(gameStateNotifier.state.grid.getConnections(wire.id),
          contains(battery.id));
    });

    test('togglePause should change the pause state', () {
      expect(gameStateNotifier.state.isPaused, isFalse);
      gameStateNotifier.togglePause();
      expect(gameStateNotifier.state.isPaused, isTrue);
      gameStateNotifier.togglePause();
      expect(gameStateNotifier.state.isPaused, isFalse);
    });

    test('selectComponent should update the selected component ID', () {
      expect(
          gameStateNotifier.state.interactionState.selectedComponentId, isNull);
      gameStateNotifier.selectComponent('test_id');
      expect(gameStateNotifier.state.interactionState.selectedComponentId,
          'test_id');
      gameStateNotifier.selectComponent(null);
      expect(
          gameStateNotifier.state.interactionState.selectedComponentId, isNull);
    });

    test('resetLevel should clear the state', () {
      gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      expect(gameStateNotifier.state.grid.getComponentCount(), 1);

      gameStateNotifier.resetLevel();
      expect(gameStateNotifier.state.grid.getComponentCount(), 0);
      expect(gameStateNotifier.state.grid.connections, isEmpty);
    });
  });
}
