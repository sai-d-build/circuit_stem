import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/debug/structured_logger.dart';

class AssetManager {
  final Map<String, ui.Image> _imageCache = {};
  late final Map<String, Function> _drawFunctions;

  AssetManager() {
    _drawFunctions = {
      'battery': _drawBattery,
      'bulb_on': (Canvas c, Size s) => _drawBulb(c, s, true),
      'bulb_off': (Canvas c, Size s) => _drawBulb(c, s, false),
      'wire_straight': _drawWireStraight,
      'wire_corner': _drawWireCorner,
      'wire_t': _drawWireT,
      'switch_open': (Canvas c, Size s) => _drawSwitch(c, s, true),
      'switch_closed': (Canvas c, Size s) => _drawSwitch(c, s, false),
    };
  }

  Future<void> loadAllAssets() async {
    // Load all images
    await _loadImages([
      'images/battery.svg',
      'images/bulb_off.svg',
      'images/bulb_on.svg',
      'images/wire_straight.svg',
      'images/wire_corner.svg',
      'images/wire_t.svg',
      'images/switch_open.svg',
      'images/switch_closed.svg',
      'images/grid_bg_level1.png',
    ]);

    // Load all audio
    await FlameAudio.audioCache.loadAll([
      'audio/place.wav',
      'audio/toggle.wav',
      'audio/success.wav',
      'audio/short_warning.wav',
    ]);
  }

  Future<void> _loadImages(List<String> paths) async {
    for (final path in paths) {
      try {
        await getImage(path);
        StructuredLogger.info('Successfully loaded image: $path');
      } catch (e) {
        StructuredLogger.error('Failed to load asset "$path": $e');
      }
    }
  }

  Future<ui.Image> getImage(String path) async {
    final assetPath = path.startsWith('assets/') ? path : 'assets/$path';
    if (_imageCache.containsKey(path)) {
      return _imageCache[path]!;
    }

    if (path.toLowerCase().endsWith('.svg')) {
      try {
        final image = await _createCustomComponentImage(path, 128, 128);
        _imageCache[path] = image;
        StructuredLogger.info('Successfully created custom image for: $path');
        return image;
      } catch (e) {
        StructuredLogger.error('Failed to create custom image for "$path": $e');
        final fallbackImage = await _createFallbackImage(128, 128);
        _imageCache[path] = fallbackImage;
        return fallbackImage;
      }
    }

    try {
      final byteData = await rootBundle.load(assetPath);
      final codec =
          await ui.instantiateImageCodec(byteData.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _imageCache[path] = frame.image;
      return frame.image;
    } catch (e) {
      StructuredLogger.error('Failed to load regular image "$path": $e');
      final fallbackImage = await _createFallbackImage(128, 128);
      _imageCache[path] = fallbackImage;
      return fallbackImage;
    }
  }

  Future<ui.Image> _createCustomComponentImage(
      String path, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());

    // Clear background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.transparent,
    );

    final key = path.split('/').last.split('.').first;
    final drawFunction = _drawFunctions[key];

    if (drawFunction != null) {
      drawFunction(canvas, size);
    } else {
      _drawGenericComponent(canvas, size);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    return image;
  }

  void _drawBattery(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final bodyRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.6,
      height: size.height * 0.4,
    );

    // Battery body
    canvas.drawRect(bodyRect, paint);

    // Battery terminal
    final terminalRect = Rect.fromLTWH(
      bodyRect.right,
      bodyRect.top + bodyRect.height * 0.3,
      size.width * 0.15,
      bodyRect.height * 0.4,
    );
    canvas.drawRect(terminalRect, paint);

    // + and - symbols
    paint.strokeWidth = 2;
    final centerY = size.height / 2;
    // Plus sign
    canvas.drawLine(
      Offset(bodyRect.left + bodyRect.width * 0.2, centerY),
      Offset(bodyRect.left + bodyRect.width * 0.35, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(bodyRect.left + bodyRect.width * 0.275, centerY - 7),
      Offset(bodyRect.left + bodyRect.width * 0.275, centerY + 7),
      paint,
    );

    // Minus sign
    canvas.drawLine(
      Offset(bodyRect.left + bodyRect.width * 0.65, centerY),
      Offset(bodyRect.left + bodyRect.width * 0.8, centerY),
      paint,
    );
  }

  void _drawBulb(Canvas canvas, Size size, bool isOn) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = size.center(Offset.zero);
    final radius = size.width * 0.25;

    // Bulb circle
    paint.color = isOn ? Colors.yellow.shade700 : Colors.grey.shade600;
    canvas.drawCircle(center, radius, paint);

    if (isOn) {
      // Fill the bulb when on
      paint.style = PaintingStyle.fill;
      paint.color = Colors.yellow.shade200;
      canvas.drawCircle(center, radius, paint);

      // Draw light rays
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.orange;
      paint.strokeWidth = 2;
      for (var i = 0; i < 8; i++) {
        final angle = (i * 45) * (3.14159 / 180);
        final startX = center.dx + (radius + 5) * cos(angle);
        final startY = center.dy + (radius + 5) * sin(angle);
        final endX = center.dx + (radius + 15) * cos(angle);
        final endY = center.dy + (radius + 15) * sin(angle);
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }
    }

    // Bulb filament (when off)
    if (!isOn) {
      paint.style = PaintingStyle.stroke;
      paint.color = Colors.grey.shade400;
      paint.strokeWidth = 1;
      canvas.drawLine(
        Offset(center.dx - radius * 0.5, center.dy - radius * 0.3),
        Offset(center.dx + radius * 0.5, center.dy + radius * 0.3),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx - radius * 0.5, center.dy + radius * 0.3),
        Offset(center.dx + radius * 0.5, center.dy - radius * 0.3),
        paint,
      );
    }
  }

  void _drawWireStraight(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.1, size.height / 2),
      Offset(size.width * 0.9, size.height / 2),
      paint,
    );
  }

  void _drawWireCorner(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height / 2);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width / 2, size.height * 0.9);

    canvas.drawPath(path, paint);
  }

  void _drawWireT(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Horizontal line
    canvas.drawLine(
      Offset(size.width * 0.1, size.height / 2),
      Offset(size.width * 0.9, size.height / 2),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, size.height * 0.9),
      paint,
    );
  }

  void _drawSwitch(Canvas canvas, Size size, bool isOpen) {
    final paint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final leftPoint = Offset(size.width * 0.2, center.dy);
    final rightPoint = Offset(size.width * 0.8, center.dy);

    // Draw connection points
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(leftPoint, 4, paint);
    canvas.drawCircle(rightPoint, 4, paint);

    // Draw switch lever
    paint.style = PaintingStyle.stroke;
    if (isOpen) {
      // Open switch - angled line
      canvas.drawLine(
        leftPoint,
        Offset(rightPoint.dx - 10, rightPoint.dy - 20),
        paint,
      );
    } else {
      // Closed switch - straight line
      canvas.drawLine(leftPoint, rightPoint, paint);
    }

    // Draw base connections
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(leftPoint.dx - 10, leftPoint.dy),
      leftPoint,
      paint,
    );
    canvas.drawLine(
      rightPoint,
      Offset(rightPoint.dx + 10, rightPoint.dy),
      paint,
    );
  }

  void _drawGenericComponent(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.2, size.width * 0.6,
            size.height * 0.6),
        const Radius.circular(8),
      ),
      paint,
    );
  }

  Future<ui.Image> _createFallbackImage(int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.grey.shade300;

    // Draw a simple placeholder rectangle
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);

    // Draw an X to indicate missing image
    final strokePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2;
    canvas.drawLine(
        const Offset(10, 10), Offset(width - 10.0, height - 10.0), strokePaint);
    canvas.drawLine(
        Offset(width - 10.0, 10), Offset(10, height - 10.0), strokePaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    return image;
  }

  ui.Image? getImageFromCache(String path) => _imageCache[path];

  // Utility method to check if an asset is loaded
  bool isAssetLoaded(String path) => _imageCache.containsKey(path);

  // Get cache statistics for debugging
  Map<String, int> getCacheStats() {
    return {
      'totalAssets': _imageCache.length,
    };
  }

  // Clear cache (useful for hot reload during development)
  void clearCache() {
    _imageCache.clear();
  }

  // Dispose of all cached images
  void dispose() {
    for (final image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
  }
}
