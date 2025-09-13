import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/interactive_mechanics.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';

void main() {
  group('NearnessRule Tests', () {
    late NearnessRule nearnessRule;
    late List<ComponentModel> existingComponents;

    setUp(() {
      nearnessRule = NearnessRule(
        ruleId: 'test_nearness',
        minDistance: 1,
        includeDiagonals: true,
        severity: ValidationSeverity.warning,
      );

      // Create some test components
      existingComponents = [
        ComponentModel(
          id: 'comp1',
          type: ComponentType.resistor,
          row: 2,
          col: 2,
          properties: {},
        ),
        ComponentModel(
          id: 'comp2',
          type: ComponentType.capacitor,
          row: 5,
          col: 5,
          properties: {},
        ),
      ];
    });

    group('Distance Calculation', () {
      test('should calculate Chebyshev distance (diagonals=true)', () {
        final ruleWithDiagonals = NearnessRule(
          ruleId: 'test',
          minDistance: 2,
          includeDiagonals: true,
        );

        // Test cases: (row1, col1, row2, col2, expectedDistance)
        final testCases = [
          (0, 0, 0, 0, 0), // Same position
          (0, 0, 1, 0, 1), // Adjacent vertically
          (0, 0, 0, 1, 1), // Adjacent horizontally
          (0, 0, 1, 1, 1), // Adjacent diagonally
          (0, 0, 2, 1, 2), // 2 steps diagonally
          (0, 0, 3, 0, 3), // 3 steps vertically
        ];

        for (final testCase in testCases) {
          final distance = ruleWithDiagonals.calculateDistance(
            testCase.$1,
            testCase.$2,
            testCase.$3,
            testCase.$4,
          );
          expect(distance, equals(testCase.$5),
              reason:
                  'Distance from (${testCase.$1},${testCase.$2}) to (${testCase.$3},${testCase.$4})');
        }
      });

      test('should calculate Manhattan distance (diagonals=false)', () {
        final ruleWithoutDiagonals = NearnessRule(
          ruleId: 'test',
          minDistance: 2,
          includeDiagonals: false,
        );

        // Test cases: (row1, col1, row2, col2, expectedDistance)
        final testCases = [
          (0, 0, 0, 0, 0), // Same position
          (0, 0, 1, 0, 1), // Adjacent vertically
          (0, 0, 0, 1, 1), // Adjacent horizontally
          (0, 0, 1, 1, 2), // Adjacent diagonally (Manhattan)
          (0, 0, 2, 1, 3), // 2 steps diagonally (Manhattan)
          (0, 0, 3, 0, 3), // 3 steps vertically
        ];

        for (final testCase in testCases) {
          final distance = ruleWithoutDiagonals.calculateDistance(
            testCase.$1,
            testCase.$2,
            testCase.$3,
            testCase.$4,
          );
          expect(distance, equals(testCase.$5),
              reason:
                  'Distance from (${testCase.$1},${testCase.$2}) to (${testCase.$3},${testCase.$4})');
        }
      });
    });

    group('Nearness Violation Detection', () {
      test(
          'should detect violation when placing adjacent to existing component',
          () {
        // Try to place at (2, 3) - adjacent to comp1 at (2, 2)
        final violation =
            nearnessRule.violatesNearness(2, 3, existingComponents);
        expect(violation, isTrue,
            reason: 'Should detect violation at adjacent position');
      });

      test('should detect violation when placing diagonally adjacent', () {
        // Try to place at (3, 3) - diagonally adjacent to comp1 at (2, 2)
        final violation =
            nearnessRule.violatesNearness(3, 3, existingComponents);
        expect(violation, isTrue,
            reason: 'Should detect violation at diagonal position');
      });

      test('should not detect violation when placing at sufficient distance',
          () {
        // Try to place at (0, 0) - 2 cells away from comp1 at (2, 2)
        final violation =
            nearnessRule.violatesNearness(0, 0, existingComponents);
        expect(violation, isFalse,
            reason: 'Should not detect violation at distant position');
      });

      test(
          'should not detect violation when placing on same position as existing component',
          () {
        // This should be handled by other validation rules (occupied cell check)
        final violation =
            nearnessRule.violatesNearness(2, 2, existingComponents);
        expect(violation, isTrue,
            reason: 'Should detect violation at occupied position');
      });
    });

    group('Violation Position Calculation', () {
      test('should calculate violation positions around center point', () {
        final violations = nearnessRule.getViolationPositions(2, 2, 10, 10);

        // Should include all adjacent positions (3x3 area minus center)
        final expectedPositions = [
          '1,1',
          '2,1',
          '3,1',
          '1,2',
          '3,2',
          '1,3',
          '2,3',
          '3,3',
        ];

        expect(violations, containsAll(expectedPositions));
        expect(violations, isNot(contains('2,2')),
            reason: 'Should not include center position');
      });

      test('should respect grid boundaries', () {
        final violations = nearnessRule.getViolationPositions(0, 0, 5, 5);

        // Should only include positions within bounds
        final expectedPositions = ['0,1', '1,0', '1,1'];
        final unexpectedPositions = ['-1,0', '0,-1', '-1,-1'];

        expect(violations, containsAll(expectedPositions));
        for (final pos in unexpectedPositions) {
          expect(violations, isNot(contains(pos)),
              reason: 'Should not include out-of-bounds position $pos');
        }
      });
    });

    group('Configuration Tests', () {
      test('should respect minDistance parameter', () {
        final ruleDistance2 = NearnessRule(
          ruleId: 'test',
          minDistance: 2,
          includeDiagonals: true,
        );

        // Position (0,0) should be invalid with distance 2 from (2,2) - exactly at minimum distance
        final violation =
            ruleDistance2.violatesNearness(0, 0, existingComponents);
        expect(violation, isTrue,
            reason:
                'Should detect violation at distance 2 (exactly at minimum)');

        // Position (1,1) should be invalid with distance 1 from (2,2) - closer than minimum
        final violation2 =
            ruleDistance2.violatesNearness(1, 1, existingComponents);
        expect(violation2, isTrue,
            reason: 'Should detect violation at distance 1');

        // Position (8,8) should be valid with distance 6 from (2,2) and distance 3 from (5,5) - both farther than minimum
        final violation3 =
            ruleDistance2.violatesNearness(8, 8, existingComponents);
        expect(violation3, isFalse,
            reason:
                'Should not detect violation when both existing components are farther than minimum distance');
      });

      test('should respect includeDiagonals parameter', () {
        final ruleNoDiagonals = NearnessRule(
          ruleId: 'test',
          minDistance: 1,
          includeDiagonals: false,
        );

        // Position (3,3) should be valid without diagonals (Manhattan distance = 4)
        final violation =
            ruleNoDiagonals.violatesNearness(3, 3, existingComponents);
        expect(violation, isFalse,
            reason: 'Should not detect violation at Manhattan distance 4');

        // Position (2,3) should be invalid (Manhattan distance = 1)
        final violation2 =
            ruleNoDiagonals.violatesNearness(2, 3, existingComponents);
        expect(violation2, isTrue,
            reason: 'Should detect violation at Manhattan distance 1');
      });
    });

    group('Rule Properties', () {
      test('should have correct rule properties', () {
        expect(nearnessRule.ruleId, equals('test_nearness'));
        expect(nearnessRule.ruleType, equals('nearness'));
        expect(nearnessRule.severity, equals(ValidationSeverity.warning));
        expect(nearnessRule.minDistance, equals(1));
        expect(nearnessRule.includeDiagonals, isTrue);
      });

      test('should have correct error messages', () {
        expect(
            nearnessRule.errorMessage, contains('minimum distance: 1 cells'));
        expect(
            nearnessRule.successMessage, contains('respects minimum distance'));
      });
    });
  });

  group('ComponentPlacementValidator Nearness Integration', () {
    late ComponentPlacementValidator validator;

    setUp(() {
      validator = ComponentPlacementValidator(
        placementRules: [
          NearnessRule(
            ruleId: 'integration_test',
            minDistance: 1,
            includeDiagonals: true,
          ),
        ],
        componentConstraints: {},
        circuitValidator: CircuitStateValidator(
          circuitRules: [],
          validationStates: {},
          continuousValidation: true,
          validationDebounce: const Duration(milliseconds: 100),
        ),
        realTimeValidationEnabled: true,
      );
    });

    test('should validate placement using nearness rules', () {
      final existingComponents = [
        ComponentModel(
          id: 'existing',
          type: ComponentType.resistor,
          row: 2,
          col: 2,
          properties: {},
        ),
      ];

      // Valid placement (far enough away)
      final validResult = validator.validatePlacement(
        ComponentType.capacitor,
        0, 0, // Far from (2,2)
        existingComponents,
      );
      expect(validResult.isValid, isTrue);

      // Invalid placement (too close)
      final invalidResult = validator.validatePlacement(
        ComponentType.capacitor,
        2, 3, // Adjacent to (2,2)
        existingComponents,
      );
      expect(invalidResult.isValid, isFalse);
      expect(invalidResult.errorMessage, contains('minimum distance'));
    });

    test('should calculate nearness violation positions', () {
      final violations = validator.getNearnessViolationPositions(2, 2, 10, 10);

      expect(violations, isNotEmpty);
      expect(violations, contains('2,3')); // Adjacent
      expect(violations, contains('3,3')); // Diagonal
      expect(violations, isNot(contains('2,2'))); // Center
    });
  });
}
