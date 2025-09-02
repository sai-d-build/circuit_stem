import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sparkcircuit/app.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/application/enhanced_game_state_notifier.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/persistence/storage_service.dart';
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/presentation/features/palette/widgets/horizontal_component_palette.dart'; // Import the palette widget

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Refactoring Safety Net Tests', () {
    late ProviderContainer container;

    setUp(() async {
      final storageService = SharedPreferencesStorageService();
      await storageService.init();

      container = ProviderContainer(overrides: [
        commandStackProvider.overrideWithValue(InMemoryCommandStack()),
        simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
        netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
        storageServiceProvider.overrideWithValue(storageService),
        componentFactoryProvider.overrideWithValue(ComponentFactory()),
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

    testWidgets('should select a component from the palette and place it on the grid', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: App()),
        ),
      );
      await tester.pumpAndSettle();

      // Find the palette item for Battery and tap it
      final batteryPaletteItem = find.descendant(
        of: find.byType(HorizontalComponentPalette),
        matching: find.text('Battery'),
      );
      expect(batteryPaletteItem, findsOneWidget);
      await tester.tap(batteryPaletteItem);
      await tester.pumpAndSettle();

      // Tap on the game canvas to place the component
      final gameCanvasFinder = find.byType(GameCanvas);
      expect(gameCanvasFinder, findsOneWidget);
      await tester.tap(gameCanvasFinder);
      await tester.pumpAndSettle();

      // Verify the component is placed
      final gameStateNotifier = container.read(enhancedGameStateNotifierProvider.notifier);
      expect(gameStateNotifier.state.grid.getComponentCount(), 1);
      expect(gameStateNotifier.state.grid.getAllComponents().first.type, ComponentType.battery);
    });

    testWidgets('should move a component after placing it', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: App()),
        ),
      );
      await tester.pumpAndSettle();

      // Place a battery
      final batteryPaletteItem = find.descendant(
        of: find.byType(HorizontalComponentPalette),
        matching: find.text('Battery'),
      );
      await tester.tap(batteryPaletteItem);
      await tester.pumpAndSettle();
      final gameCanvasFinder = find.byType(GameCanvas);
      await tester.tap(gameCanvasFinder);
      await tester.pumpAndSettle();

      final gameStateNotifier = container.read(enhancedGameStateNotifierProvider.notifier);
      expect(gameStateNotifier.state.grid.getComponentCount(), 1);
      final placedComponent = gameStateNotifier.state.grid.getAllComponents().first;

      // Simulate dragging the component
      // Note: Direct UI drag simulation is complex. We'll simulate the action via notifier.
      // This test focuses on the state change, assuming UI interaction works.
      final initialRow = placedComponent.row;
      final initialCol = placedComponent.col;

      await gameStateNotifier.moveComponent(placedComponent.id, initialRow + 1, initialCol + 1);
      await tester.pumpAndSettle();

      final movedComponent = gameStateNotifier.state.grid.getComponentById(placedComponent.id);
      expect(movedComponent?.row, initialRow + 1);
      expect(movedComponent?.col, initialCol + 1);
    });

    testWidgets('should restart the level when the restart button is pressed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(home: App()),
        ),
      );
      await tester.pumpAndSettle();

      // Place a battery
      final batteryPaletteItem = find.descendant(
        of: find.byType(HorizontalComponentPalette),
        matching: find.text('Battery'),
      );
      await tester.tap(batteryPaletteItem);
      await tester.pumpAndSettle();
      final gameCanvasFinder = find.byType(GameCanvas);
      await tester.tap(gameCanvasFinder);
      await tester.pumpAndSettle();

      final gameStateNotifier = container.read(enhancedGameStateNotifierProvider.notifier);
      expect(gameStateNotifier.state.grid.getComponentCount(), 1);

      // Tap the restart button (assuming it's an IconButton with Icons.refresh)
      final restartButtonFinder = find.byIcon(Icons.refresh);
      expect(restartButtonFinder, findsOneWidget);
      await tester.tap(restartButtonFinder);
      await tester.pumpAndSettle();

      // Verify the grid is empty
      expect(gameStateNotifier.state.grid.getComponentCount(), 0);
    });
  });
}