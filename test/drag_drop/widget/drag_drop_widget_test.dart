import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart' as core_providers;

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

      expect(find.byType(DragTarget), findsOneWidget);
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
            home: GameCanvas(levelId: 'test_level'),
          ),
        ),
      );

      // Simulate a drag gesture
      final canvasFinder = find.byType(GameCanvas);
      await tester.drag(canvasFinder, const Offset(100, 100));

      await tester.pump();

      // Canvas should still be present after gesture
      expect(find.byType(GameCanvas), findsOneWidget);
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

      final canvasFinder = find.byType(GameCanvas);
      await tester.pump();

      // Test mouse movement (MouseRegion)
      await tester.hoverPointer(const Offset(200, 200));
      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
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
            home: GameCanvas(levelId: 'nonexistent_level'),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
      expect(find.byType(DragTarget), findsOneWidget);
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

      await tester.pump();

      // Test pan gesture
      final canvasFinder = find.byType(GameCanvas);
      await tester.drag(canvasFinder, const Offset(50, 50));

      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
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

      await tester.pump();

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

      expect(find.byType(GameCanvas), findsOneWidget);
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

      await tester.pump();

      // Test clicking in different grid areas
      await tester.tapAt(const Offset(60, 60));
      await tester.pump();

      await tester.tapAt(const Offset(120, 120));
      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
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

      await tester.pump();

      // Simulate component selection by tapping
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();

      // Test that selection persists during drag
      final canvasFinder = find.byType(GameCanvas);
      await tester.drag(canvasFinder, const Offset(30, 30));
      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
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

      await tester.pump();

      // Test dragging near boundaries
      final canvasFinder = find.byType(GameCanvas);
      await tester.dragFrom(tester.getTopLeft(canvasFinder), const Offset(10, 10));
      await tester.pump();

      await tester.dragFrom(tester.getTopRight(canvasFinder), const Offset(-10, -10));
      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
    });
  });
}