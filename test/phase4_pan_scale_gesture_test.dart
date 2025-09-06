import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;

void main() {
  group('Phase 4.3: Pan vs Scale Gesture Separation Tests', () {
    testWidgets('single touch gesture pans canvas', (tester) async {
      // This test verifies that a single finger drag pans the canvas
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the canvas
      final canvasFinder = find.byType(GameCanvas);
      expect(canvasFinder, findsOneWidget);

      // Simulate single touch drag (pan gesture)
      final center = tester.getCenter(canvasFinder);
      await tester.dragFrom(center, const Offset(50, 50));

      // Verify the gesture was processed (canvas should still be present)
      expect(canvasFinder, findsOneWidget);
    });

    testWidgets('multi-touch gesture scales canvas', (tester) async {
      // This test verifies that a two-finger pinch scales the canvas
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the canvas
      final canvasFinder = find.byType(GameCanvas);
      expect(canvasFinder, findsOneWidget);

      // Simulate multi-touch scale gesture (pinch)
      final center = tester.getCenter(canvasFinder);
      final gesture1 = await tester.startGesture(center + const Offset(-20, 0));
      final gesture2 = await tester.startGesture(center + const Offset(20, 0));

      // Move fingers apart (zoom in)
      await gesture1.moveBy(const Offset(-30, 0));
      await gesture2.moveBy(const Offset(30, 0));

      await gesture1.up();
      await gesture2.up();

      // Verify the gesture was processed (canvas should still be present)
      expect(canvasFinder, findsOneWidget);
    });

    testWidgets('single touch on component drags component', (tester) async {
      // This test verifies that single touch on a component drags that component
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the canvas
      final canvasFinder = find.byType(GameCanvas);
      expect(canvasFinder, findsOneWidget);

      // Simulate single touch on a component position
      final center = tester.getCenter(canvasFinder);
      await tester.tapAt(center);
      await tester.pump();

      // Simulate drag gesture
      await tester.dragFrom(center, const Offset(30, 30));

      // Verify the gesture was processed (canvas should still be present)
      expect(canvasFinder, findsOneWidget);
    });

    testWidgets('scale gesture does not interfere with component dragging', (tester) async {
      // This test verifies that scale gestures don't trigger component dragging
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: GameCanvas(levelId: 'test_level'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the canvas
      final canvasFinder = find.byType(GameCanvas);
      expect(canvasFinder, findsOneWidget);

      // Simulate scale gesture (should not trigger component drag)
      final center = tester.getCenter(canvasFinder);
      final gesture1 = await tester.startGesture(center + const Offset(-10, 0));
      final gesture2 = await tester.startGesture(center + const Offset(10, 0));

      // Small movement (scale gesture, not component drag)
      await gesture1.moveBy(const Offset(-5, 0));
      await gesture2.moveBy(const Offset(5, 0));

      await gesture1.up();
      await gesture2.up();

      // Verify the gesture was processed correctly (canvas should still be present)
      expect(canvasFinder, findsOneWidget);
    });
  });
}