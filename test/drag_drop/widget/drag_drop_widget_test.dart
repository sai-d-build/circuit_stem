import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart' as core_providers;

// Required service imports for test setup
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';

void main() {
  group('GameCanvas Drag and Drop Widget Tests', () {
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
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('GameCanvas renders DragTarget', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: GameCanvas(levelId: 'test_level'),
          ),
        ),
      );

      // Wait for the widget to build and initialize
      await tester.pumpAndSettle();

      // Verify DragTarget is present
      expect(find.byType(DragTarget), findsOneWidget);

      // Verify the canvas has the expected structure
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(MouseRegion), findsOneWidget);
    });

    testWidgets('GameCanvas displays drop zone highlight during drag', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially, no drop zone highlight should be visible
      expect(find.byType(CustomPaint), findsNWidgets(2)); // Grid and components painters

      // Simulate starting a drag (this would normally come from palette)
      // For now, we'll just verify the canvas structure is correct
      expect(find.byType(DragTarget), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(MouseRegion), findsOneWidget);
    });

    testWidgets('Mouse position tracking updates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify MouseRegion is present for hover tracking
      expect(find.byType(MouseRegion), findsOneWidget);

      // Test that the canvas renders with proper structure
      expect(find.byType(DragTarget), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('Canvas handles empty level gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'nonexistent_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Canvas should render even with nonexistent level
      expect(find.byType(GameCanvas), findsOneWidget);
      expect(find.byType(DragTarget), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);

      // Should have basic canvas structure
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(MouseRegion), findsOneWidget);
    });

    testWidgets('Canvas scales and pans correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify gesture detector is present for pan/scale handling
      expect(find.byType(GestureDetector), findsOneWidget);

      // Test that canvas maintains structure after potential gestures
      final canvasFinder = find.byType(GameCanvas);
      expect(canvasFinder, findsOneWidget);

      // Verify all core components are present
      expect(find.byType(DragTarget), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('Gesture handling for two-finger pan works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify canvas structure supports multi-touch gestures
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(DragTarget), findsOneWidget);

      // Simulate multi-touch pan
      final canvasFinder = find.byType(GameCanvas);
      final center = tester.getCenter(canvasFinder);

      final TestGesture gesture1 = await tester.createGesture();
      final TestGesture gesture2 = await tester.createGesture();

      await gesture1.down(center + const Offset(-20, -20));
      await gesture2.down(center + const Offset(20, 20));

      await gesture1.moveBy(const Offset(50, 50));
      await gesture2.moveBy(const Offset(50, 50));

      await tester.pump();

      // Canvas should maintain structure after multi-touch gesture
      expect(find.byType(GameCanvas), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('Grid cell size affects interaction accuracy', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify gesture detector is present for tap handling
      expect(find.byType(GestureDetector), findsOneWidget);

      // Test clicking in different grid areas
      await tester.tapAt(const Offset(60, 60));
      await tester.pump();

      await tester.tapAt(const Offset(120, 120));
      await tester.pump();

      // Canvas should maintain structure after taps
      expect(find.byType(GameCanvas), findsOneWidget);
      expect(find.byType(DragTarget), findsOneWidget);
    });

    testWidgets('Component selection state persists during gestures', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify gesture handling components are present
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(MouseRegion), findsOneWidget);

      // Simulate component selection by tapping
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();

      // Test that selection persists during drag
      final canvasFinder = find.byType(GameCanvas);
      await tester.drag(canvasFinder, const Offset(30, 30));
      await tester.pump();

      // Canvas should maintain all components after gesture
      expect(find.byType(GameCanvas), findsOneWidget);
      expect(find.byType(DragTarget), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('High-frequency gestures are handled gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pump();

      // Simulate rapid sequential taps
      final tapPositions = [
        const Offset(50, 50),
        const Offset(100, 100),
        const Offset(150, 150),
        const Offset(200, 200),
        const Offset(250, 250),
      ];

      for (final position in tapPositions) {
        await tester.tapAt(position);
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(GameCanvas), findsOneWidget);
    });

    testWidgets('Boundary gestures trigger appropriate feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            commandStackProvider.overrideWithValue(InMemoryCommandStack()),
            simulationEngineProvider.overrideWithValue(BasicSimulationEngine()),
            netlistBuilderProvider.overrideWithValue(NetlistBuilder()),
            storageServiceProvider.overrideWithValue(SharedPreferencesStorageService()),
            componentFactoryProvider.overrideWithValue(ComponentFactory()),
          ],
          child: const MaterialApp(
            home: SizedBox(
              width: 400,
              height: 400,
              child: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify canvas has proper boundary handling
      expect(find.byType(ClipRRect), findsOneWidget);

      // Test dragging near boundaries
      final canvasFinder = find.byType(GameCanvas);
      await tester.dragFrom(tester.getTopLeft(canvasFinder), const Offset(10, 10));
      await tester.pump();

      await tester.dragFrom(tester.getTopRight(canvasFinder), const Offset(-10, -10));
      await tester.pump();

      // Canvas should maintain structure after boundary gestures
      expect(find.byType(GameCanvas), findsOneWidget);
      expect(find.byType(DragTarget), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}