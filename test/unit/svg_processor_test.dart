import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/infrastructure/rendering/svg_processor.dart';
import 'dart:ui' as ui;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SvgProcessor', () {
    final svgProcessor = SvgProcessor();

    test('should process a valid SVG asset', () async {
      // Arrange
      final assetPaths = ['assets/images/battery.svg'];

      // Act
      final result = await svgProcessor.processSvgs(assetPaths);

      // Assert
      expect(result, isA<Map<String, ui.Image>>());
      expect(result.length, 1);
      expect(result.containsKey('assets/images/battery.svg'), isTrue);
      final image = result['assets/images/battery.svg'];
      expect(image, isNotNull);
      expect(image, isA<ui.Image>());
    });

    test('should handle a missing SVG asset gracefully', () async {
      // Arrange
      final assetPaths = ['assets/images/non_existent.svg'];

      // Act
      final result = await svgProcessor.processSvgs(assetPaths);

      // Assert
      expect(result, isA<Map<String, ui.Image>>());
      expect(result.isEmpty, isTrue);
    });

    test('should handle a mix of valid and invalid assets', () async {
      // Arrange
      final assetPaths = [
        'assets/images/battery.svg',
        'assets/images/non_existent.svg',
        'assets/images/bulb_on.svg'
      ];

      // Act
      final result = await svgProcessor.processSvgs(assetPaths);

      // Assert
      expect(result, isA<Map<String, ui.Image>>());
      expect(result.length, 2);
      expect(result.containsKey('assets/images/battery.svg'), isTrue);
      expect(result.containsKey('assets/images/bulb_on.svg'), isTrue);
      expect(result.containsKey('assets/images/non_existent.svg'), isFalse);
    });
  });
}
