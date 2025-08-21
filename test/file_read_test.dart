import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Can read level manifest file', () async {
    print('[File Read Test] Attempting to read level_manifest.json...');
    try {
      final content = await File('assets/levels/level_manifest.json').readAsString();
      print('[File Read Test] File read successfully. Content length: ${content.length}');
      expect(content.isNotEmpty, isTrue);
    } catch (e) {
      print('[File Read Test] Error reading file: $e');
      fail('Failed to read level_manifest.json: $e');
    }
  });
}
