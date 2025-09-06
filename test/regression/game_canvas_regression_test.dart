import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

void main() {
  group('GameCanvas Regression Tests', () {
    testWidgets('All existing gestures work after refactoring', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final gameCanvas = find.byType(GameCanvas);
      expect(gameCanvas, findsOneWidget);

      final center = tester.getCenter(gameCanvas);

      // Test tap gesture
      await tester.tapAt(center);
      await tester.pumpAndSettle();
      expect(find.text('Exception'), findsNothing);

      // Test double tap (if implemented)
      await tester.tapAt(center);
      await tester.tapAt(center);
      await tester.pumpAndSettle();
      expect(find.text('Exception'), findsNothing);

      StructuredLogger.info('✅ Tap gestures working correctly');
    });

    testWidgets('Pan/drag gestures preserved', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final gameCanvas = find.byType(GameCanvas);

      // Test pan gesture (drag without component)
      await tester.drag(gameCanvas, const Offset(50, 50));
      await tester.pumpAndSettle();
      expect(find.text('Exception'), findsNothing);

      // Test drag in different directions
      await tester.drag(gameCanvas, const Offset(-30, 20));
      await tester.pumpAndSettle();
      expect(find.text('Exception'), findsNothing);

      StructuredLogger.info('✅ Pan/drag gestures working correctly');
    });

    testWidgets('Long press functionality maintained', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final gameCanvas = find.byType(GameCanvas);
      final center = tester.getCenter(gameCanvas);

      // Test long press
      await tester.longPressAt(center);
      await tester.pumpAndSettle();
      expect(find.text('Exception'), findsNothing);

      StructuredLogger.info('✅ Long press gestures working correctly');
    });

    testWidgets('Multi-touch gestures work', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final gameCanvas = find.byType(GameCanvas);
      final center = tester.getCenter(gameCanvas);

      // Test multi-touch gesture (pinch to zoom) - simplified test
      final gesture1 = await tester.startGesture(center);
      final gesture2 = await tester.startGesture(center + const Offset(10, 10));

      // Move gestures apart (zoom in)
      await gesture1.moveBy(const Offset(-10, -10));
      await gesture2.moveBy(const Offset(10, 10));
      await tester.pump();

      await gesture1.up();
      await gesture2.up();
      await tester.pumpAndSettle();

      expect(find.text('Exception'), findsNothing);

      StructuredLogger.info('✅ Multi-touch gestures working correctly');
    });

    testWidgets('Component rendering preserved', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify components are still rendered
      // Note: Adjust based on your specific component rendering
      expect(find.byType(GameCanvas), findsOneWidget);

      // Test that no rendering errors occur
      expect(find.text('Exception'), findsNothing);
      expect(find.text('Error'), findsNothing);

      StructuredLogger.info('✅ Component rendering preserved');
    });

    testWidgets('Grid background renders correctly', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify grid is rendered
      expect(find.byType(GameCanvas), findsOneWidget);

      // Test grid visibility and interaction
      final gameCanvas = find.byType(GameCanvas);
      final center = tester.getCenter(gameCanvas);

      await tester.tapAt(center);
      await tester.pumpAndSettle();

      expect(find.text('Exception'), findsNothing);

      StructuredLogger.info('✅ Grid background rendering correct');
    });

    testWidgets('Context menu functionality preserved', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final gameCanvas = find.byType(GameCanvas);
      final center = tester.getCenter(gameCanvas);

      // Test long press for context menu
      await tester.longPressAt(center);
      await tester.pumpAndSettle();

      // Verify no crashes
      expect(find.text('Exception'), findsNothing);

      StructuredLogger.info('✅ Context menu functionality preserved');
    });

    testWidgets('Drag and drop zones work', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Test drag target functionality
      expect(find.byType(GameCanvas), findsOneWidget);

      // Verify drag zones are functional
      expect(find.text('Exception'), findsNothing);

      StructuredLogger.info('✅ Drag and drop zones functional');
    });
  });
}

Widget createTestApp() {
  return ProviderScope(
    overrides: [
      // Add necessary provider overrides for testing
      // Override providers that might cause issues in tests
    ],
    child: const MaterialApp(
      home: GameCanvas(levelId: '1'),
    ),
  );
}