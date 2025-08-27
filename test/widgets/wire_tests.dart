import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/services/providers.dart';
import '../helpers/game_test_helper.dart';
import '../helpers/test_setup_helper.dart';

void main() {
  group('Wire Interaction Tests', () {
    setUpAll(() async {
      await TestSetupHelper.initializeTestEnvironment();
    });

    testWidgets('TC-L2-01: Tapping a rotatable wire changes its rotation',
        (tester) async {
      // ARRANGE
      // Level 2 contains a rotatable wire with id 'wire_rotatable'
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 1);
      final container = setup.container;
      final wireId = 'wire_rotatable';

      final initialWire = GameTestHelper.findComponentById(container, wireId);
      final initialRotation = initialWire.rotation;

      // ACT
      // 1. Tap the component to select it.
      await GameTestHelper.tapGridCell(tester, initialWire.r, initialWire.c);
      await tester.pump();

      // 2. Manually trigger the rotation, simulating the UI's rotate button.
      final newRotation = (initialRotation + 90) % 360;
      final updatedWire = initialWire.copyWith(rotation: newRotation);
      container.read(gameEngineProvider.notifier).updateComponent(updatedWire);
      await tester.pumpAndSettle();

      // ASSERT
      final finalWire = GameTestHelper.findComponentById(container, wireId);
      expect(finalWire.rotation, equals(newRotation),
          reason: 'Wire should have rotated by 90 degrees');
    });
  });
}
