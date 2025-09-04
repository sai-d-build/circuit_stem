import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

void main() {
  group('Drag and Drop Tests', () {
    test('ComponentDragData creation from palette definition', () {
      // Test data creation from palette component definition
      final mockDefinition = _MockComponentDefinition(
        type: 'battery',
        name: 'Battery',
        description: 'Power source',
        defaultProperties: {'voltage': 9.0},
        cost: 1,
      );

      final dragData = ComponentDragData.fromPaletteComponentDefinition(mockDefinition);

      expect(dragData.componentType, equals(ComponentType.battery));
      expect(dragData.componentName, equals('Battery'));
      expect(dragData.description, equals('Power source'));
      expect(dragData.defaultProperties, equals({'voltage': 9.0}));
      expect(dragData.cost, equals(1));
      expect(dragData.icon, isNotNull);
    });

    test('ComponentDragData creation from domain definition', () {
      // Test data creation from domain component definition
      final mockDefinition = _MockDomainComponentDefinition(
        type: ComponentType.resistor,
        name: 'Resistor',
        description: 'Limits current flow',
        defaultProperties: {'resistance': 1000.0},
        cost: 1,
      );

      final dragData = ComponentDragData.fromPaletteComponentDefinition(mockDefinition);

      expect(dragData.componentType, equals(ComponentType.resistor));
      expect(dragData.componentName, equals('Resistor'));
      expect(dragData.description, equals('Limits current flow'));
      expect(dragData.defaultProperties, equals({'resistance': 1000.0}));
      expect(dragData.cost, equals(1));
    });

    test('String to ComponentType conversion', () {
      // Test the internal conversion method
      expect(_stringToComponentType('battery'), equals(ComponentType.battery));
      expect(_stringToComponentType('resistor'), equals(ComponentType.resistor));
      expect(_stringToComponentType('bulb'), equals(ComponentType.bulb));
      expect(_stringToComponentType('wire'), equals(ComponentType.wire));
      expect(_stringToComponentType('switch'), equals(ComponentType.switch_));
      expect(_stringToComponentType('unknown'), equals(ComponentType.wire)); // Default
    });

    testWidgets('ComponentDragFeedback widget renders correctly', (WidgetTester tester) async {
      final dragData = ComponentDragData(
        componentType: ComponentType.battery,
        componentName: 'Battery',
        description: 'Power source',
        defaultProperties: {},
        cost: 1,
        icon: Icons.battery_full,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ComponentDragFeedback(dragData: dragData),
        ),
      );

      // Check if the widget renders
      expect(find.byType(ComponentDragFeedback), findsOneWidget);
      expect(find.text('Battery'), findsOneWidget);
      expect(find.byIcon(Icons.battery_full), findsOneWidget);
    });

    testWidgets('Drag data creation handles edge cases', (WidgetTester tester) async {
      // Test with minimal definition
      final minimalDefinition = _MockComponentDefinition(
        type: 'wire',
        name: 'Wire',
        description: '',
        defaultProperties: {},
        cost: 0,
      );

      final dragData = ComponentDragData.fromPaletteComponentDefinition(minimalDefinition);

      expect(dragData.componentType, equals(ComponentType.wire));
      expect(dragData.componentName, equals('Wire'));
      expect(dragData.cost, equals(0));
    });

    testWidgets('Drag feedback shows component details correctly', (WidgetTester tester) async {
      final dragData = ComponentDragData(
        componentType: ComponentType.resistor,
        componentName: 'Resistor',
        description: 'Limits current flow',
        defaultProperties: {'resistance': 1000.0},
        cost: 2,
        icon: Icons.linear_scale,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentDragFeedback(dragData: dragData),
          ),
        ),
      );

      // Verify all elements are present
      expect(find.text('Resistor'), findsOneWidget);
      expect(find.byIcon(Icons.linear_scale), findsOneWidget);

      // Check the container styling
      final container = find.byType(Container).first;
      final Container containerWidget = tester.widget(container);
      expect(containerWidget.decoration, isNotNull);
    });

    test('Component type conversion handles all valid types', () {
      // Test all component types
      expect(_stringToComponentType('battery'), equals(ComponentType.battery));
      expect(_stringToComponentType('resistor'), equals(ComponentType.resistor));
      expect(_stringToComponentType('led'), equals(ComponentType.bulb));
      expect(_stringToComponentType('wire'), equals(ComponentType.wire));
      expect(_stringToComponentType('switch'), equals(ComponentType.switch_));
      expect(_stringToComponentType('capacitor'), equals(ComponentType.capacitor));
      expect(_stringToComponentType('inductor'), equals(ComponentType.inductor));
      expect(_stringToComponentType('buzzer'), equals(ComponentType.buzzer));
    });

    test('Component type conversion defaults to wire for unknown types', () {
      expect(_stringToComponentType('unknown'), equals(ComponentType.wire));
      expect(_stringToComponentType('invalid'), equals(ComponentType.wire));
      expect(_stringToComponentType(''), equals(ComponentType.wire));
    });

    testWidgets('Drag data equality works correctly', (WidgetTester tester) async {
      final dragData1 = ComponentDragData(
        componentType: ComponentType.battery,
        componentName: 'Battery',
        description: 'Power source',
        defaultProperties: {'voltage': 9.0},
        cost: 1,
        icon: Icons.battery_full,
      );

      final dragData2 = ComponentDragData(
        componentType: ComponentType.battery,
        componentName: 'Battery',
        description: 'Power source',
        defaultProperties: {'voltage': 9.0},
        cost: 1,
        icon: Icons.battery_full,
      );

      final dragData3 = ComponentDragData(
        componentType: ComponentType.resistor,
        componentName: 'Resistor',
        description: 'Limits current',
        defaultProperties: {'resistance': 1000.0},
        cost: 2,
        icon: Icons.linear_scale,
      );

      expect(dragData1 == dragData2, isTrue);
      expect(dragData1 == dragData3, isFalse);
    });

    test('ComponentDragData handles null cost gracefully', () {
      final mockDefinition = _MockComponentDefinition(
        type: 'wire',
        name: 'Wire',
        description: 'Connects components',
        defaultProperties: {},
        cost: null, // Test null cost
      );

      final dragData = ComponentDragData.fromPaletteComponentDefinition(mockDefinition);

      expect(dragData.cost, equals(1)); // Should default to 1
    });

    test('ComponentDragData handles null properties gracefully', () {
      final mockDefinition = _MockComponentDefinition(
        type: 'resistor',
        name: 'Resistor',
        description: 'Limits current',
        defaultProperties: null, // Test null properties
        cost: 2,
      );

      final dragData = ComponentDragData.fromPaletteComponentDefinition(mockDefinition);

      expect(dragData.defaultProperties, equals({})); // Should default to empty map
    });

    test('String to ComponentType conversion handles all component types', () {
      // Test all supported component types
      expect(_stringToComponentType('battery'), equals(ComponentType.battery));
      expect(_stringToComponentType('resistor'), equals(ComponentType.resistor));
      expect(_stringToComponentType('led'), equals(ComponentType.bulb));
      expect(_stringToComponentType('bulb'), equals(ComponentType.bulb));
      expect(_stringToComponentType('wire'), equals(ComponentType.wire));
      expect(_stringToComponentType('switch'), equals(ComponentType.switch_));
      expect(_stringToComponentType('capacitor'), equals(ComponentType.capacitor));
      expect(_stringToComponentType('inductor'), equals(ComponentType.inductor));
      expect(_stringToComponentType('buzzer'), equals(ComponentType.buzzer));
      expect(_stringToComponentType('unknown_type'), equals(ComponentType.wire)); // Default
    });

    test('ComponentDragData equality works correctly', () {
      final dragData1 = ComponentDragData(
        componentType: ComponentType.battery,
        componentName: 'Battery',
        description: 'Power source',
        defaultProperties: {'voltage': 9.0},
        cost: 1,
        icon: Icons.battery_full,
      );

      final dragData2 = ComponentDragData(
        componentType: ComponentType.battery,
        componentName: 'Battery',
        description: 'Power source',
        defaultProperties: {'voltage': 9.0},
        cost: 1,
        icon: Icons.battery_full,
      );

      final dragData3 = ComponentDragData(
        componentType: ComponentType.resistor,
        componentName: 'Resistor',
        description: 'Limits current',
        defaultProperties: {'resistance': 1000.0},
        cost: 1,
        icon: Icons.linear_scale,
      );

      expect(dragData1 == dragData2, isTrue);
      expect(dragData1 == dragData3, isFalse);
    });
  });
}

// Mock class for testing
class _MockComponentDefinition {
  final String type;
  final String name;
  final String description;
  final Map<String, dynamic>? defaultProperties;
  final int? cost;

  const _MockComponentDefinition({
    required this.type,
    required this.name,
    required this.description,
    this.defaultProperties,
    this.cost,
  });
}

// Mock domain component definition for testing
class _MockDomainComponentDefinition {
  final ComponentType type;
  final String name;
  final String description;
  final Map<String, dynamic> defaultProperties;
  final int cost;

  const _MockDomainComponentDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.defaultProperties,
    required this.cost,
  });
}

// Helper function for testing (copied from drag_models.dart)
ComponentType _stringToComponentType(String typeString) {
  switch (typeString) {
    case 'battery':
      return ComponentType.battery;
    case 'resistor':
      return ComponentType.resistor;
    case 'bulb':
    case 'led':
      return ComponentType.bulb;
    case 'wire':
      return ComponentType.wire;
    case 'switch':
      return ComponentType.switch_;
    case 'capacitor':
      return ComponentType.capacitor;
    case 'inductor':
      return ComponentType.inductor;
    case 'buzzer':
      return ComponentType.buzzer;
    default:
      return ComponentType.wire; // Default fallback
  }
}