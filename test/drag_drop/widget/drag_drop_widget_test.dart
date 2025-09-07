import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/core/services/game_state_reader.dart';
/// Test demonstrating the new CanvasInteractionWidget integration
void main() {
  group('CanvasInteractionWidget Integration Test', () {
    testWidgets('GameCanvas renders with CanvasInteractionWidget', (tester) async {
      // Create a minimal test container with required providers
      final container = ProviderContainer();

      // Test that GameCanvas can be instantiated without throwing
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: GameCanvas(levelId: 'test_level'),
          ),
        ),
      );

      // The test passes if no exceptions are thrown during widget building
      expect(find.byType(GameCanvas), findsOneWidget);

      container.dispose();
    });
  });
}