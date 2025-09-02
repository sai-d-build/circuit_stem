import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/in_memory_command_stack.dart';
import 'package:sparkcircuit/core/simulation/basic_simulation_engine.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/core/persistence/storage_service.dart';
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';

void main() {
  group('GameCanvas Tests', () {
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

    testWidgets('GameCanvas should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: Scaffold(
              body: GameCanvas(levelId: '1'),
            ),
          ),
        ),
      );

      expect(find.byType(GameCanvas), findsOneWidget);
    });

    testWidgets('GameCanvas should handle tap gestures', (WidgetTester tester) async {
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

      await tester.tapAt(const Offset(200, 200));
      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
    });

    testWidgets('GameCanvas should handle long press gestures', (WidgetTester tester) async {
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

      await tester.longPressAt(const Offset(200, 200));
      await tester.pump();

      expect(find.byType(GameCanvas), findsOneWidget);
    });
  });

  group('Component Model Tests', () {
    test('ComponentModel should store properties correctly', () {
      final component = ComponentModel(
        id: 'test_component',
        type: ComponentType.resistor,
        row: 10,
        col: 20,
        properties: {'resistance': 1000.0, 'tolerance': 0.05},
      );

      expect(component.id, 'test_component');
      expect(component.type, ComponentType.resistor);
      expect(component.row, 10);
      expect(component.col, 20);
      expect(component.properties['resistance'], 1000.0);
      expect(component.properties['tolerance'], 0.05);
    });

    test('ComponentModel copyWith should work', () {
      final original = ComponentModel(
        id: 'original',
        type: ComponentType.battery,
        row: 0,
        col: 0,
        properties: {'voltage': 9.0},
      );

      final updated = original.copyWith(
        row: 50,
        properties: {'voltage': 12.0},
      );

      expect(updated.id, 'original');
      expect(updated.type, ComponentType.battery);
      expect(updated.row, 50);
      expect(updated.col, 0);
      expect(updated.properties['voltage'], 12.0);
    });
  });
}
