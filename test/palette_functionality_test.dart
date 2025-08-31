import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers.dart'; // Import the main providers file
import 'package:sparkcircuit/application/enhanced_game_state_notifier.dart'; // For EnhancedGameStateNotifier
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/persistence/storage_service.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart'; // Keep this for PaletteStateNotifier

void main() {
  group('Palette Functionality Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Setup a ProviderContainer with necessary overrides for testing
      container = ProviderContainer(overrides: [
        commandStackProvider.overrideWithValue(InMemoryCommandStack()),
        simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
        netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
        storageServiceProvider.overrideWithValue(StorageService()),
        componentFactoryProvider.overrideWithValue(ComponentFactory()),
        // Override enhancedGameStateNotifierProvider to ensure it's initialized
        enhancedGameStateNotifierProvider.overrideWith(
          (ref) => EnhancedGameStateNotifier(
            storageService: ref.read(storageServiceProvider),
            commandStack: ref.read(commandStackProvider),
            simulationEngine: ref.read(simulationEngineProvider),
            netlistBuilder: ref.read(netlistBuilderProvider),
            componentFactory: ref.read(componentFactoryProvider),
          ),
        ),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    group('Palette State Management', () {
      test('should initialize with correct components for level 1', () {
        final paletteState = container.read(paletteStateProvider('1'));
        expect(paletteState.inventory.length, 5);
        expect(paletteState.inventory.containsKey('battery'), true);
        expect(paletteState.inventory.containsKey('resistor'), true);
        expect(paletteState.inventory.containsKey('led'), true);
        expect(paletteState.inventory.containsKey('wire'), true);
        expect(paletteState.inventory.containsKey('switch'), true);
      });

      test('should initialize with correct components for level 2', () {
        final paletteState = container.read(paletteStateProvider('2'));
        expect(paletteState.inventory.length, 5);
        expect(paletteState.inventory['resistor']?.total, 3);
        expect(paletteState.inventory['led']?.total, 2);
        expect(paletteState.inventory['wire']?.total, 8);
      });

      test('should initialize with correct components for level 3', () {
        final paletteState = container.read(paletteStateProvider('3'));
        expect(paletteState.inventory.length, 5);
        expect(paletteState.inventory.containsKey('switch'), true);
        expect(paletteState.inventory['switch']?.total, 1);
        expect(paletteState.inventory['wire']?.total, 10);
      });

      test('should have correct inventory counts for each level', () {
        final level1State = container.read(paletteStateProvider('1'));
        expect(level1State.inventory['battery']?.total, 1);
        expect(level1State.inventory['resistor']?.total, 2);
        expect(level1State.inventory['led']?.total, 1);
        expect(level1State.inventory['wire']?.total, 5);
        expect(level1State.inventory['switch']?.total, 1);

        final level2State = container.read(paletteStateProvider('2'));
        expect(level2State.inventory['battery']?.total, 1);
        expect(level2State.inventory['resistor']?.total, 3);
        expect(level2State.inventory['led']?.total, 2);
        expect(level2State.inventory['wire']?.total, 8);
        expect(level2State.inventory['switch']?.total, 1);

        final level3State = container.read(paletteStateProvider('3'));
        expect(level3State.inventory['battery']?.total, 1);
        expect(level3State.inventory['resistor']?.total, 2);
        expect(level3State.inventory['led']?.total, 2);
        expect(level3State.inventory['wire']?.total, 10);
        expect(level3State.inventory['switch']?.total, 1);
      });
    });

    group('Component Inventory Logic', () {
      test('should correctly determine if component can be used', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        expect(paletteNotifier.canUseComponent('battery'), true);
        expect(paletteNotifier.canUseComponent('resistor'), true);
        expect(paletteNotifier.canUseComponent('nonexistent'), false);
      });

      test('should decrement inventory when component is used', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        final initialBatteryCount = paletteNotifier.state.inventory['battery']?.available;
        expect(initialBatteryCount, 1);
        paletteNotifier.useComponent('battery');
        final updatedBatteryCount = paletteNotifier.state.inventory['battery']?.available;
        expect(updatedBatteryCount, 0);
      });

      test('should not allow using component when inventory is exhausted', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        paletteNotifier.useComponent('battery');
        expect(paletteNotifier.canUseComponent('battery'), false);
        paletteNotifier.useComponent('battery');
        final batteryCount = paletteNotifier.state.inventory['battery']?.available;
        expect(batteryCount, 0);
      });

      test('should return component to inventory correctly', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        paletteNotifier.useComponent('resistor');
        expect(paletteNotifier.state.inventory['resistor']?.available, 1);
        paletteNotifier.returnComponent('resistor');
        expect(paletteNotifier.state.inventory['resistor']?.available, 2);
      });
    });

    group('Component Selection', () {
      test('should select component correctly', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        paletteNotifier.selectComponent(null);
        paletteNotifier.stopPlacingComponent();
        expect(paletteNotifier.state.selectedComponentType, null);
        expect(paletteNotifier.state.isPlacingComponent, false);

        paletteNotifier.selectComponent('battery');
        expect(paletteNotifier.state.selectedComponentType, 'battery');

        paletteNotifier.selectComponent('resistor');
        expect(paletteNotifier.state.selectedComponentType, 'resistor');

        paletteNotifier.selectComponent(null);
        expect(paletteNotifier.state.selectedComponentType, null);
      });

      test('should start and stop placing component correctly', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        paletteNotifier.selectComponent(null);
        paletteNotifier.stopPlacingComponent();

        paletteNotifier.startPlacingComponent('battery');
        expect(paletteNotifier.state.isPlacingComponent, true);
        expect(paletteNotifier.state.placingComponentType, 'battery');

        paletteNotifier.stopPlacingComponent();
        expect(paletteNotifier.state.isPlacingComponent, false);
        expect(paletteNotifier.state.placingComponentType, null);
      });
    });

    group('Component Filtering', () {
      test('should filter components by search query', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        paletteNotifier.updateSearchQuery('battery');
        expect(paletteNotifier.state.filteredComponents.length, 1);
        expect(paletteNotifier.state.filteredComponents[0].type, 'battery');

        paletteNotifier.updateSearchQuery('resistor');
        expect(paletteNotifier.state.filteredComponents.length, 1);
        expect(paletteNotifier.state.filteredComponents[0].type, 'resistor');

        paletteNotifier.clearSearch();
        expect(paletteNotifier.state.filteredComponents.length, 5);
      });

      test('should filter components by category', () {
        final paletteNotifier = container.read(paletteStateProvider('1').notifier);
        paletteNotifier.addFilter('basic');
        expect(paletteNotifier.state.filteredComponents.length, 3);

        paletteNotifier.addFilter('active');
        expect(paletteNotifier.state.filteredComponents.length, 5);

        paletteNotifier.clearFilters();
        expect(paletteNotifier.state.filteredComponents.length, 5);
      });
    });
  });
}
