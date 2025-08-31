import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/presentation/features/game/screens/game_screen.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/core/persistence/storage_service.dart';
import 'package:sparkcircuit/application/enhanced_game_state_notifier.dart';

void main() {
  group('Game Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(overrides: [
        commandStackProvider.overrideWithValue(InMemoryCommandStack()),
        simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
        netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
        storageServiceProvider.overrideWithValue(StorageService()),
        componentFactoryProvider.overrideWithValue(ComponentFactory()),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Complete game flow should work', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: GameScreen(levelId: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(GameCanvas), findsOneWidget);
    });

    testWidgets('Component placement workflow', (WidgetTester tester) async {
      final gameStateNotifier = container.read(enhancedGameStateNotifierProvider.notifier);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(gameStateNotifier.state.grid.getComponentCount(), 0);

      await gameStateNotifier.placeComponent(ComponentType.battery, 2, 2);

      await tester.pump();

      expect(gameStateNotifier.state.grid.getComponentCount(), 1);
    });

    testWidgets('Wire drawing workflow', (WidgetTester tester) async {
      final gameStateNotifier = container.read(enhancedGameStateNotifierProvider.notifier);

      await gameStateNotifier.placeComponent(ComponentType.battery, 0, 0);
      await gameStateNotifier.placeComponent(ComponentType.wire, 0, 1);

      final components = gameStateNotifier.state.grid.getAllComponents();
      final battery = components[0];
      final wire = components[1];

      await gameStateNotifier.addConnection(battery.id, wire.id);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: '1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(gameStateNotifier.state.grid.connections.length, 2);
    });
  });
}
