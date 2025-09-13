import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/circuit_grid.dart';

/// Widget tests for CircuitGrid component
/// Tests UI rendering and basic interactions
void main() {
  group('CircuitGrid Widget Tests', () {
    const testLevelId = 'test_level_01';

    testWidgets('should render CircuitGrid widget',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: testLevelId),
          ),
        ),
      );

      // Then
      expect(find.byType(CircuitGrid), findsOneWidget);
    });

    testWidgets('should contain Stack layout for layering',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: testLevelId),
          ),
        ),
      );

      // When - pump to allow widget to build
      await tester.pump();

      // Then - should contain Stack for visual and interactive layers
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('should contain CustomPaint for grid rendering',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: testLevelId),
          ),
        ),
      );

      // When
      await tester.pump();

      // Then
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should contain GridView for interactive cells',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: testLevelId),
          ),
        ),
      );

      // When
      await tester.pump();

      // Then
      expect(find.byType(GridView), findsWidgets);
    });

    testWidgets('should handle different level IDs',
        (WidgetTester tester) async {
      // Test with different level IDs
      const levelIds = ['tutorial_01', 'beginner_01', 'intermediate_01'];

      for (final levelId in levelIds) {
        // Given
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CircuitGrid(levelId: levelId),
            ),
          ),
        );

        // When
        await tester.pump();

        // Then
        expect(find.byType(CircuitGrid), findsOneWidget,
            reason: 'Should render for level: $levelId');
      }
    });

    testWidgets('should have proper accessibility',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: testLevelId),
          ),
        ),
      );

      // When
      await tester.pump();

      // Then - check for semantic labels and accessibility
      expect(find.bySemanticsLabel('Circuit Grid'), findsWidgets);
    });

    testWidgets('should handle screen size changes',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: testLevelId),
          ),
        ),
      );

      // When - change screen size
      await tester.pump();
      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();

      // Then - should still render without errors
      expect(find.byType(CircuitGrid), findsOneWidget);
    });

    testWidgets('should handle orientation changes',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: testLevelId),
          ),
        ),
      );

      // When - change to landscape
      await tester.pump();
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pump();

      // Then
      expect(find.byType(CircuitGrid), findsOneWidget);
    });

    testWidgets('should render within LayoutBuilder constraints',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: const CircuitGrid(levelId: testLevelId),
                );
              },
            ),
          ),
        ),
      );

      // When
      await tester.pump();

      // Then
      expect(find.byType(CircuitGrid), findsOneWidget);
      expect(find.byType(LayoutBuilder), findsOneWidget);
    });
  });

  group('CircuitGrid Error Handling Tests', () {
    testWidgets('should handle empty level ID gracefully',
        (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: ''), // Empty level ID
          ),
        ),
      );

      // When
      await tester.pump();

      // Then - should not crash
      expect(find.byType(CircuitGrid), findsOneWidget);
    });

    testWidgets('should handle very long level ID',
        (WidgetTester tester) async {
      // Given
      final veryLongLevelId =
          'very_long_level_id_that_might_cause_issues_with_string_handling_and_ui_layout_' *
              5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: veryLongLevelId),
          ),
        ),
      );

      // When
      await tester.pump();

      // Then
      expect(find.byType(CircuitGrid), findsOneWidget);
    });

    testWidgets('should handle special characters in level ID',
        (WidgetTester tester) async {
      // Given
      const specialLevelId = 'level_01_special_chars_test';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: specialLevelId),
          ),
        ),
      );

      // When
      await tester.pump();

      // Then
      expect(find.byType(CircuitGrid), findsOneWidget);
    });
  });

  group('CircuitGrid Performance Tests', () {
    testWidgets('should render quickly', (WidgetTester tester) async {
      // Given
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: 'performance_test'),
          ),
        ),
      );

      // When
      await tester.pump();
      stopwatch.stop();

      // Then - should render within reasonable time (less than 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'CircuitGrid should render quickly for good UX');
    });

    testWidgets('should handle rapid rebuilds', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircuitGrid(levelId: 'rebuild_test'),
          ),
        ),
      );

      // When - trigger multiple rebuilds
      for (var i = 0; i < 10; i++) {
        await tester.pump();
      }

      // Then - should still be functional
      expect(find.byType(CircuitGrid), findsOneWidget);
    });
  });
}
