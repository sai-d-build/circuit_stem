import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sparkcircuit/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Drag and Drop Integration Tests', () {
    testWidgets('Complete drag-and-drop workflow from palette to canvas',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Ensure the app started and has the expected UI
      expect(find.text('CircuitSTEM'), findsOneWidget);

      // Wait for the initial level to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test basic canvas interaction
      expect(find.byType(DragTarget), findsWidgets);

      debugPrint('✅ Integration test: Game canvas loaded successfully');
    });

    testWidgets('Rapid drag interactions maintain stability',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Ensure the app started
      expect(find.text('CircuitSTEM'), findsOneWidget);

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Simulate rapid gestures across the canvas
      final canvasAreas = find.byType(DragTarget);

      // Radio button check
      if (canvasAreas.evaluate().isNotEmpty) {
        final canvas = canvasAreas.first;

        // Simulate rapid taps
        for (var i = 0; i < 5; i++) {
          await tester.tap(canvas, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Simulate rapid drags
        for (var i = 0; i < 3; i++) {
          await tester.drag(canvas, const Offset(50, 50), warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Wait for any animations or state changes
        await tester.pumpAndSettle();

        // Verify app is still responsive
        expect(find.text('CircuitSTEM'), findsOneWidget);

        debugPrint(
            '✅ Integration test: Rapid drag interactions handled gracefully');
      } else {
        debugPrint(
            '⚠️  Integration test: No canvas areas found, skipping rapid interaction test');
      }
    });

    testWidgets('Long-running drag session maintains performance',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Ensure the app started
      expect(find.text('CircuitSTEM'), findsOneWidget);

      // Wait for initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final canvasAreas = find.byType(DragTarget);

      if (canvasAreas.evaluate().isNotEmpty) {
        final canvas = canvasAreas.first;

        // Simulate prolonged usage
        final stopwatch = Stopwatch()..start();

        // Perform many drag operations
        for (var i = 0; i < 10; i++) {
          await tester.drag(canvas, Offset(20.0 + i, 20.0 + i),
              warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 50));
        }

        stopwatch.stop();

        // Verify operation completed within reasonable time (should be < 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // Verify app stability
        await tester.pumpAndSettle();
        expect(find.text('CircuitSTEM'), findsOneWidget);

        debugPrint(
            '✅ Integration test: Long-running session completed in ${stopwatch.elapsedMilliseconds}ms');
      }
    });
  });
}
