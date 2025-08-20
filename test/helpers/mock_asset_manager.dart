import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:circuit_stem/services/asset_manager.dart';
import 'package:circuit_stem/services/asset_manager_state.dart';

class MockAssetManager extends StateNotifier<AssetState> implements AssetManagerNotifier {
  final Map<String, String> _files = {};

  MockAssetManager() : super(const AssetState());

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
    return Future.value();
  }

  @override
  ui.Image? getSvgAsImage(String path) => null;

  @override
  void setSvgImages(Map<String, ui.Image> images) {
    state = state.copyWith(svgImages: images);
  }
}