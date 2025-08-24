import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:circuit_stem/common/assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All assets in AppAssets exist', () async {
    for (final asset in AppAssets.all) {
      final file = File(asset);
      expect(await file.exists(), isTrue, reason: 'Asset not found: $asset');
    }
  });
}
