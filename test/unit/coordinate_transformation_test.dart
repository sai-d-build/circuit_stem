import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Coordinate Transformation Tests', () {

    group('Basic Coordinate Transformation', () {
      test('should correctly transform global to local coordinates', () {
        // Given
        const globalOffset = Offset(200, 150);
        const scale = 1.0;
        const panOffset = Offset(0, 0);
        const cellSize = 60.0;

        // When
        final transformedDy = (globalOffset.dy - panOffset.dy) / scale;
        final transformedDx = (globalOffset.dx - panOffset.dx) / scale;
        final row = (transformedDy / cellSize).floor();
        final col = (transformedDx / cellSize).floor();

        // Then
        expect(row, equals(2)); // 150 / 60 = 2.5 -> floor = 2
        expect(col, equals(3)); // 200 / 60 = 3.33 -> floor = 3
      });

      test('should handle scaled coordinates correctly', () {
        // Given
        const globalOffset = Offset(300, 180);
        const scale = 2.0;
        const panOffset = Offset(50, 30);
        const cellSize = 60.0;

        // When
        final transformedDy = (globalOffset.dy - panOffset.dy) / scale;
        final transformedDx = (globalOffset.dx - panOffset.dx) / scale;
        final row = (transformedDy / cellSize).floor();
        final col = (transformedDx / cellSize).floor();

        // Then
        expect(row, equals(1)); // (180-0)/2 = 90, 90/60 = 1.5 -> floor = 1
        expect(col, equals(2)); // (300-0)/2 = 150, 150/60 = 2.5 -> floor = 2
      });

      test('should handle negative pan offsets', () {
        // Given
        const globalOffset = Offset(100, 80);
        const scale = 1.0;
        const panOffset = Offset(-20, -10);
        const cellSize = 60.0;

        // When
        final transformedDy = (globalOffset.dy - panOffset.dy) / scale;
        final transformedDx = (globalOffset.dx - panOffset.dx) / scale;
        final row = (transformedDy / cellSize).floor();
        final col = (transformedDx / cellSize).floor();

        // Then
        expect(row, equals(1)); // (80 - (-10)) = 90, 90/60 = 1.5 -> floor = 1
        expect(col, equals(2)); // (100 - (-20)) = 120, 120/60 = 2.0 -> floor = 2
      });
    });

    group('Bounds Validation', () {
      test('should validate coordinates within grid bounds', () {
        // Given
        const rows = 8;
        const cols = 10;
        const testCases = [
          (row: 0, col: 0, expected: true),   // Top-left corner
          (row: 7, col: 9, expected: true),   // Bottom-right corner
          (row: 4, col: 5, expected: true),   // Center
          (row: -1, col: 0, expected: false), // Negative row
          (row: 0, col: -1, expected: false), // Negative col
          (row: 8, col: 0, expected: false),  // Row out of bounds
          (row: 0, col: 10, expected: false), // Col out of bounds
          (row: 10, col: 15, expected: false), // Both out of bounds
        ];

        for (final testCase in testCases) {
          // When
          final isWithinBounds = testCase.row >= 0 &&
                                testCase.row < rows &&
                                testCase.col >= 0 &&
                                testCase.col < cols;

          // Then
          expect(isWithinBounds, equals(testCase.expected),
                 reason: 'Failed for row=${testCase.row}, col=${testCase.col}');
        }
      });

      test('should handle edge cases in bounds validation', () {
        // Given
        const rows = 20;
        const cols = 20;

        // When & Then
        expect(_isWithinBounds(-1, 0, rows, cols), isFalse, reason: 'Negative row');
        expect(_isWithinBounds(0, -1, rows, cols), isFalse, reason: 'Negative col');
        expect(_isWithinBounds(19, 19, rows, cols), isTrue, reason: 'Max valid indices');
        expect(_isWithinBounds(20, 19, rows, cols), isFalse, reason: 'Row out of bounds');
        expect(_isWithinBounds(19, 20, rows, cols), isFalse, reason: 'Col out of bounds');
        expect(_isWithinBounds(100, 100, rows, cols), isFalse, reason: 'Both way out of bounds');
      });
    });

    group('Coordinate Transformation Edge Cases', () {
      test('should handle zero scale gracefully', () {
        // This test documents the issue with zero scale
        const globalOffset = Offset(100, 100);
        const scale = 0.0; // Problematic case
        const panOffset = Offset(0, 0);
        const cellSize = 60.0;

        // When - this would cause division by zero
        expect(() {
          final transformedDy = (globalOffset.dy - panOffset.dy) / scale;
          final row = (transformedDy / cellSize).floor();
        }, throwsA(isA<UnsupportedError>()));
      });

      test('should handle very small scale values', () {
        // Given
        const globalOffset = Offset(100, 100);
        const scale = 0.1; // Very small scale
        const panOffset = Offset(0, 0);
        const cellSize = 60.0;

        // When
        final transformedDy = (globalOffset.dy - panOffset.dy) / scale;
        final transformedDx = (globalOffset.dx - panOffset.dx) / scale;
        final row = (transformedDy / cellSize).floor();
        final col = (transformedDx / cellSize).floor();

        // Then
        expect(row, equals(16)); // (100/0.1) = 1000, 1000/60 = 16.66 -> floor = 16
        expect(col, equals(16)); // (100/0.1) = 1000, 1000/60 = 16.66 -> floor = 16
      });

      test('should handle floating point precision issues', () {
        // Given - values that might cause floating point precision issues
        const globalOffset = Offset(199.99999999999997, 299.99999999999994);
        const scale = 1.0;
        const panOffset = Offset(0, 0);
        const cellSize = 60.0;

        // When
        final transformedDy = (globalOffset.dy - panOffset.dy) / scale;
        final transformedDx = (globalOffset.dx - panOffset.dx) / scale;
        final row = (transformedDy / cellSize).floor();
        final col = (transformedDx / cellSize).floor();

        // Then - should still produce correct integer results
        expect(row, equals(4)); // 299.99999999999994 / 60 = 4.999999999999999 -> floor = 4
        expect(col, equals(3)); // 199.99999999999997 / 60 = 3.333333333333333 -> floor = 3
      });
    });
  });
}

// Helper function for bounds validation testing
bool _isWithinBounds(int row, int col, int rows, int cols) {
  return row >= 0 && row < rows && col >= 0 && col < cols;
}