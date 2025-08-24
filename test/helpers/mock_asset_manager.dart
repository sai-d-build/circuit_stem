
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager_state.dart';

class MockAssetManager extends StateNotifier<AssetState>
    implements AssetManagerNotifier {
  final Map<String, String> _files = {};
  ui.Image? _testImage;

  MockAssetManager() : super(const AssetState()) {
    _testImage = _createMinimalTestImage();
  }

  // Helper to create a minimal 1x1 test image to avoid nulls
  ui.Image _createMinimalTestImage() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = Colors.blue);
    final picture = recorder.endRecording();
    // Use toImageSync for test environments
    return picture.toImageSync(1, 1);
  }

  @override
  bool get isDark => state.isDark;

  @override
  void updateTheme(bool isDark) {
    state = state.copyWith(isDark: isDark);
  }

  void primeFile(String path, String content) {
    _files[path] = content;
  }

  @override
  Future<String> loadString(String path) {
    if (_files.containsKey(path)) {
      return Future.value(_files[path]!);
    }
    return Future.error(Exception('MockAssetManager: File not primed: $path'));
  }

  @override
  Future<void> loadAllAssets() {
    // In tests, we assume assets are primed manually.
    return Future.value();
  }

  @override
  ui.Image? getSvgAsImage(String path) {
    // Return the minimal test image instead of null
    return _testImage;
  }

  @override
  void setSvgImages(Map<String, ui.Image> images) {
    state = state.copyWith(svgImages: images);
  }
}
