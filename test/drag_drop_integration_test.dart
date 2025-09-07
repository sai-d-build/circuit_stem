import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/core/services/input_sanitization_service.dart';
import 'package:sparkcircuit/core/services/optimized_grid_manager.dart';
import 'package:sparkcircuit/core/services/secure_coordinate_validator.dart';

void main() {
  group('Drag-and-Drop Integration Tests', () {
    late InputSanitizationService sanitizationService;
    late OptimizedGridManager gridManager;

    setUp(() {
      sanitizationService = InputSanitizationService();
      gridManager = OptimizedGridManager();
      gridManager.updateGridDimensions(10, 10);
    });

    tearDown(() {
      sanitizationService.clearCache();
    });

    group('Input Sanitization Service', () {
      test('sanitizes valid drag data', () {
        final dragData = {
          'componentType': 'resistor',
          'componentName': '10K Resistor',
          'cost': 5,
          'properties': {
            'resistance': 10000,
            'tolerance': 0.05,
          }
        };

        final result = sanitizationService.sanitizeDragData(dragData);

        expect(result.isValid, isTrue);
        expect(result.sanitizedData!['componentType'], equals('resistor'));
        expect(result.sanitizedData!['componentName'], equals('10K Resistor'));
        expect(result.sanitizedData!['cost'], equals(5));
      });

      test('rejects invalid component type', () {
        final dragData = {
          'componentType': 'invalid_component',
          'componentName': 'Test Component',
          'cost': 10,
        };

        final result = sanitizationService.sanitizeDragData(dragData);

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Invalid componentType'));
      });

      test('sanitizes dangerous strings', () {
        final dragData = {
          'componentType': 'resistor',
          'componentName': '<script>alert("xss")</script>Resistor',
          'cost': 5,
        };

        final result = sanitizationService.sanitizeDragData(dragData);

        expect(result.isValid, isTrue);
        expect(result.sanitizedData!['componentName'], equals('scriptalert("xss")/scriptResistor'));
      });

      test('handles null drag data', () {
        final result = sanitizationService.sanitizeDragData(null);

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('null'));
      });

      test('validates cost bounds', () {
        final expensiveData = {
          'componentType': 'capacitor',
          'componentName': 'Expensive Cap',
          'cost': 50000, // Too expensive
        };

        final result = sanitizationService.sanitizeDragData(expensiveData);

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Invalid cost'));
      });

      test('sanitizes properties map', () {
        final dragData = {
          'componentType': 'inductor',
          'componentName': 'Test Inductor',
          'cost': 8,
          'properties': {
            'inductance': 0.001,
            'currentRating': 1.0,
            'invalidProp': double.nan,
            'dangerousString': '<dangerous>content</dangerous>',
          }
        };

        final result = sanitizationService.sanitizeDragData(dragData);

        expect(result.isValid, isTrue);
        expect(result.sanitizedData!['properties']['inductance'], equals(0.001));
        expect(result.sanitizedData!['properties']['currentRating'], equals(1.0));
        expect(result.sanitizedData!['properties']['invalidProp'], isNull); // NaN removed
        expect(result.sanitizedData!['properties']['dangerousString'], equals('dangerouscontent/dangerous')); // Sanitized
      });
    });

    group('Optimized Grid Manager', () {
      test('initializes with correct dimensions', () {
        expect(gridManager.occupiedCount, equals(0));
        expect(gridManager.isEmpty, isTrue);
      });

      test('adds and removes occupied positions', () {
        final position = Offset(2, 3);

        gridManager.addOccupiedPosition(position);
        expect(gridManager.isPositionOccupied(position), isTrue);
        expect(gridManager.occupiedCount, equals(1));
        expect(gridManager.isEmpty, isFalse);

        gridManager.removeOccupiedPosition(position);
        expect(gridManager.isPositionOccupied(position), isFalse);
        expect(gridManager.occupiedCount, equals(0));
        expect(gridManager.isEmpty, isTrue);
      });

      test('validates component placement', () {
        final position = Offset(2, 3);

        expect(gridManager.canPlaceComponent(position), isTrue);

        gridManager.addOccupiedPosition(position);
        expect(gridManager.canPlaceComponent(position), isFalse);
        expect(gridManager.canPlaceComponent(position, width: 2, height: 1), isFalse); // Overlaps
      });

      test('places and removes components', () {
        final position = Offset(2, 3);

        gridManager.placeComponent(position, width: 2, height: 2);
        expect(gridManager.occupiedCount, equals(4)); // 2x2 = 4 positions

        // Check all positions are occupied
        expect(gridManager.isPositionOccupied(Offset(2, 3)), isTrue);
        expect(gridManager.isPositionOccupied(Offset(3, 3)), isTrue);
        expect(gridManager.isPositionOccupied(Offset(2, 4)), isTrue);
        expect(gridManager.isPositionOccupied(Offset(3, 4)), isTrue);

        gridManager.removeComponent(position, width: 2, height: 2);
        expect(gridManager.occupiedCount, equals(0));
      });

      test('respects grid bounds', () {
        // Position outside bounds
        final outOfBounds = Offset(15, 15);
        expect(gridManager.isWithinBounds(outOfBounds), isFalse);
        expect(gridManager.canPlaceComponent(outOfBounds), isFalse);

        // Position within bounds
        final inBounds = Offset(5, 5);
        expect(gridManager.isWithinBounds(inBounds), isTrue);
        expect(gridManager.canPlaceComponent(inBounds), isTrue);
      });

      test('finds nearest free position', () {
        // Occupy center position
        gridManager.addOccupiedPosition(Offset(5, 5));

        // Find nearest free position
        final nearest = gridManager.findNearestFreePosition(Offset(5, 5));

        expect(nearest, isNotNull);
        expect(nearest, isNot(equals(Offset(5, 5)))); // Should not return occupied position
        expect(gridManager.isWithinBounds(nearest!), isTrue);
        expect(gridManager.canPlaceComponent(nearest!), isTrue);
      });

      test('provides grid statistics', () {
        gridManager.addOccupiedPosition(Offset(0, 0));
        gridManager.addOccupiedPosition(Offset(1, 1));

        final stats = gridManager.getStatistics();

        expect(stats['gridWidth'], equals(10));
        expect(stats['gridHeight'], equals(10));
        expect(stats['totalCells'], equals(100));
        expect(stats['occupiedCells'], equals(2));
        expect(stats['freeCells'], equals(98));
        expect(stats['occupancyRate'], equals(0.02));
      });

      test('handles bulk operations', () {
        final positions = [
          Offset(0, 0),
          Offset(1, 1),
          Offset(2, 2),
        ];

        gridManager.bulkUpdateOccupiedPositions(positions, true);
        expect(gridManager.occupiedCount, equals(3));

        gridManager.bulkUpdateOccupiedPositions(positions, false);
        expect(gridManager.occupiedCount, equals(0));
      });

      test('validates multiple positions', () {
        gridManager.addOccupiedPosition(Offset(1, 1));

        final positions = [
          Offset(0, 0), // Free
          Offset(1, 1), // Occupied
          Offset(2, 2), // Free
        ];

        final results = gridManager.validatePositions(positions);

        expect(results[0], isTrue);  // (0,0) is free
        expect(results[1], isFalse); // (1,1) is occupied
        expect(results[2], isTrue);  // (2,2) is free
      });
    });

    group('Gesture Validation', () {
      test('validates drag gestures', () {
        final gestureData = {
          'startPosition': Offset(100, 100),
          'currentPosition': Offset(150, 150),
        };

        final result = sanitizationService.validateGesture('drag', gestureData);

        expect(result.isValid, isTrue);
        expect(result.sanitizedData!['startPosition'], equals(Offset(100, 100)));
        expect(result.sanitizedData!['currentPosition'], equals(Offset(150, 150)));
      });

      test('rejects invalid drag gestures', () {
        final gestureData = {
          'startPosition': 'invalid',
          'currentPosition': Offset(150, 150),
        };

        final result = sanitizationService.validateGesture('drag', gestureData);

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('Invalid drag positions'));
      });

      test('validates pan gestures', () {
        final gestureData = {
          'delta': Offset(50, 30),
        };

        final result = sanitizationService.validateGesture('pan', gestureData);

        expect(result.isValid, isTrue);
        expect(result.sanitizedData!['delta'], equals(Offset(50, 30)));
      });

      test('validates scale gestures', () {
        final gestureData = {
          'scale': 1.5,
        };

        final result = sanitizationService.validateGesture('scale', gestureData);

        expect(result.isValid, isTrue);
        expect(result.sanitizedData!['scale'], equals(1.5));
      });

      test('rejects excessive pan deltas', () {
        final gestureData = {
          'delta': Offset(5000, 5000), // Too large
        };

        final result = sanitizationService.validateGesture('pan', gestureData);

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('too large'));
      });

      test('sanitizes scale values', () {
        final gestureData = {
          'scale': 25.0, // Too large
        };

        final result = sanitizationService.validateGesture('scale', gestureData);

        expect(result.isValid, isTrue);
        expect(result.sanitizedData!['scale'], equals(10.0)); // Clamped
      });
    });

    group('Performance Tests', () {
      test('grid manager performs well with many operations', () {
        // Add many positions
        for (int i = 0; i < 50; i++) {
          gridManager.addOccupiedPosition(Offset((i % 10).toDouble(), (i ~/ 10).toDouble()));
        }

        expect(gridManager.occupiedCount, equals(50));

        // Performance test: many occupancy checks
        final startTime = DateTime.now();
        for (int i = 0; i < 1000; i++) {
          final x = i % 10;
          final y = (i ~/ 10) % 10;
          gridManager.isPositionOccupied(Offset(x.toDouble(), y.toDouble()));
        }
        final endTime = DateTime.now();

        final duration = endTime.difference(startTime);
        expect(duration.inMilliseconds, lessThan(100)); // Should be very fast
      });

      test('input sanitization caches results', () {
        final dragData = {
          'componentType': 'resistor',
          'componentName': 'Test Resistor',
          'cost': 5,
        };

        // First call
        final startTime1 = DateTime.now();
        final result1 = sanitizationService.sanitizeDragData(dragData);
        final endTime1 = DateTime.now();

        // Second call (should use cache)
        final startTime2 = DateTime.now();
        final result2 = sanitizationService.sanitizeDragData(dragData);
        final endTime2 = DateTime.now();

        expect(result1.isValid, equals(result2.isValid));
        expect(result1.sanitizedData, equals(result2.sanitizedData));

        // Cached call should be faster
        final duration1 = endTime1.difference(startTime1);
        final duration2 = endTime2.difference(startTime2);

        expect(duration2.inMicroseconds, lessThanOrEqualTo(duration1.inMicroseconds));
      });
    });

    group('Integration Scenarios', () {
      test('complete drag-and-drop workflow', () {
        // 1. Sanitize drag data
        final dragData = {
          'componentType': 'resistor',
          'componentName': '10K Resistor',
          'cost': 5,
        };

        final sanitizedResult = sanitizationService.sanitizeDragData(dragData);
        expect(sanitizedResult.isValid, isTrue);

        // 2. Validate gesture
        final gestureData = {
          'startPosition': Offset(100, 100),
          'currentPosition': Offset(250, 300), // Grid position (5,6)
        };

        final gestureResult = sanitizationService.validateGesture('drag', gestureData);
        expect(gestureResult.isValid, isTrue);

        // 3. Check grid placement
        final targetPosition = Offset(5, 6);
        expect(gridManager.canPlaceComponent(targetPosition), isTrue);

        // 4. Place component
        gridManager.placeComponent(targetPosition);
        expect(gridManager.isPositionOccupied(targetPosition), isTrue);
        expect(gridManager.canPlaceComponent(targetPosition), isFalse);

        // 5. Verify final state
        expect(gridManager.occupiedCount, equals(1));
      });

      test('handles edge cases gracefully', () {
        // Test with invalid data
        final invalidDragData = {
          'componentType': 'invalid_type',
          'componentName': '',
          'cost': -100,
        };

        final result = sanitizationService.sanitizeDragData(invalidDragData);
        expect(result.isValid, isFalse);

        // Test with out-of-bounds position
        final outOfBoundsPos = Offset(20, 20);
        expect(gridManager.canPlaceComponent(outOfBoundsPos), isFalse);

        // Test with occupied position
        gridManager.addOccupiedPosition(Offset(1, 1));
        expect(gridManager.canPlaceComponent(Offset(1, 1)), isFalse);
      });
    });
  });
}