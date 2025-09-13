import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

void main() {
  group('Grid Serialization', () {
    late Grid testGrid;

    setUp(() {
      // Create a test grid with components
      testGrid = Grid(rows: 5, cols: 8);

      final component1 = ComponentModel(
        id: 'comp1',
        type: ComponentType.resistor,
        row: 1,
        col: 2,
        properties: {'resistance': 1000},
      );

      final component2 = ComponentModel(
        id: 'comp2',
        type: ComponentType.battery,
        row: 3,
        col: 4,
        state: ComponentState.powered,
      );

      testGrid = testGrid.placeComponent(component1);
      testGrid = testGrid.placeComponent(component2);
    });

    test('should serialize with schema version', () {
      final json = testGrid.toJson();

      expect(json['schemaVersion'], '1.0.0');
      expect(json['rows'], 5);
      expect(json['cols'], 8);
      expect(json['components'], isA<Map<String, dynamic>>());
      expect(json['occupiedPositions'], isA<List<dynamic>>());
    });

    test('should round-trip serialization correctly', () {
      final json = testGrid.toJson();
      final deserializedGrid = Grid.fromJson(json);

      expect(deserializedGrid.rows, testGrid.rows);
      expect(deserializedGrid.cols, testGrid.cols);
      expect(deserializedGrid.components.length, testGrid.components.length);
      expect(deserializedGrid.occupiedPositions.length,
          testGrid.occupiedPositions.length);
    });

    test('should handle unknown component types gracefully', () {
      final corruptedJson = testGrid.toJson();
      // Corrupt a component type
      (corruptedJson['components'] as Map<String, dynamic>)['comp1']!['type'] =
          'ComponentType.unknown';

      final deserializedGrid = Grid.fromJson(corruptedJson);

      // Should still deserialize with fallback to wire
      expect(deserializedGrid.components.length, testGrid.components.length);
      expect(deserializedGrid.components['comp1']!.type, ComponentType.wire);
    });

    test('should handle missing fields gracefully', () {
      final minimalJson = <String, dynamic>{
        'rows': 3,
        'cols': 4,
        'components': <String, dynamic>{},
      };

      final grid = Grid.fromJson(minimalJson);

      expect(grid.rows, 3);
      expect(grid.cols, 4);
      expect(grid.components.isEmpty, true);
    });

    test('should repair occupied positions mismatch', () {
      final json = testGrid.toJson();
      // Corrupt occupied positions
      json['occupiedPositions'] = ['0,0', 'invalid'];

      final deserializedGrid = Grid.fromJson(json);

      // Should have repaired occupied positions
      expect(deserializedGrid.occupiedPositions.length,
          testGrid.occupiedPositions.length);
      expect(deserializedGrid.occupiedPositions, testGrid.occupiedPositions);
    });

    test('should handle legacy format without schema version', () {
      final legacyJson = testGrid.toJson();
      legacyJson.remove('schemaVersion');

      final deserializedGrid = Grid.fromJson(legacyJson);

      // Should still work with legacy format
      expect(deserializedGrid.rows, testGrid.rows);
      expect(deserializedGrid.components.length, testGrid.components.length);
    });

    test('should handle invalid date strings', () {
      final json = testGrid.toJson();
      // Corrupt a date
      (json['components'] as Map<String, dynamic>)['comp1']!['createdAt'] =
          'invalid-date';

      final deserializedGrid = Grid.fromJson(json);

      // Should still deserialize with fallback dates
      expect(deserializedGrid.components.length, testGrid.components.length);
    });
  });
}
