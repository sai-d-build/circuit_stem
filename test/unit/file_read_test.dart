import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Can read level manifest file', () async {
    try {
      final content =
          await File('assets/levels/level_manifest.json').readAsString();

      expect(content.isNotEmpty, isTrue);
    } catch (e) {
      fail('Failed to read level_manifest.json: $e');
    }
  });
}
