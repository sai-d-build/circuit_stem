import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. A minimal provider for the test.
final simpleProvider = Provider((ref) => 'Hello, World!');

// 2. A minimal widget that uses the provider.
class MinimalWidget extends ConsumerWidget {
  const MinimalWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(simpleProvider);
    return Text(text);
  }
}

void main() {
  testWidgets(
    'Minimal reproduction case for timeout issue',
    (WidgetTester tester) async {
      // 3. Pump the minimal widget within a ProviderScope.
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MinimalWidget(),
          ),
        ),
      );

      // 4. A simple expectation.
      expect(find.text('Hello, World!'), findsOneWidget);
    },
    // 5. Apply the same timeout that is failing in other tests.
    timeout: const Timeout(Duration(minutes: 1)),
  );
}
