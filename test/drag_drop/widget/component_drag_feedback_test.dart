import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';

void main() {
  group('ComponentDragFeedback Widget Tests', () {
    late ComponentDragData testDragData;

    setUp(() {
      testDragData = const ComponentDragData(
        componentType: ComponentType.battery,
        componentName: 'Battery',
        description: 'Power source component',
        defaultProperties: {'voltage': 9.0},
        cost: 1,
        icon: Icons.battery_full,
      );
    });

    testWidgets('ComponentDragFeedback renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ComponentDragFeedback(dragData: testDragData),
        ),
      );

      // Verify the widget is rendered
      expect(find.byType(ComponentDragFeedback), findsOneWidget);

      // Verify the icon is displayed
      expect(find.byIcon(Icons.battery_full), findsOneWidget);

      // Verify the component name is displayed
      expect(find.text('Battery'), findsOneWidget);
    });

    testWidgets(
        'ComponentDragFeedback shows correct icon for different component types',
        (WidgetTester tester) async {
      final testCases = [
        (ComponentType.resistor, Icons.linear_scale),
        (ComponentType.bulb, Icons.lightbulb),
        (ComponentType.wire, Icons.horizontal_rule),
        (ComponentType.switch_, Icons.power),
        (ComponentType.capacitor, Icons.battery_charging_full),
      ];

      for (final (componentType, expectedIcon) in testCases) {
        final dragData = ComponentDragData(
          componentType: componentType,
          componentName: componentType.name,
          description: 'Test component',
          defaultProperties: {},
          cost: 1,
          icon: expectedIcon,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ComponentDragFeedback(dragData: dragData),
          ),
        );

        expect(find.byIcon(expectedIcon), findsOneWidget);
        await tester.pumpAndSettle(); // Clean up for next test
      }
    });

    testWidgets('ComponentDragFeedback has correct size and styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ComponentDragFeedback(dragData: testDragData),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ComponentDragFeedback),
              matching: find.byType(Container),
            )
            .first,
      );

      // Verify container has correct dimensions
      expect(container.constraints?.maxWidth, equals(80));
      expect(container.constraints?.maxHeight, equals(80));

      // Verify it has border radius
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.borderRadius, isNotNull);
    });

    testWidgets('ComponentDragFeedback handles long component names',
        (WidgetTester tester) async {
      const longNameDragData = ComponentDragData(
        componentType: ComponentType.battery,
        componentName: 'Very Long Component Name That Should Be Truncated',
        description: 'Test component with long name',
        defaultProperties: {},
        cost: 1,
        icon: Icons.battery_full,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 100,
            height: 100,
            child: ComponentDragFeedback(dragData: longNameDragData),
          ),
        ),
      );

      // The text should still be findable even if truncated
      expect(find.text('Very Long Component Name That Should Be Truncated'),
          findsOneWidget);
    });
  });
}
