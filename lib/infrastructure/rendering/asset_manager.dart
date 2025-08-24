import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../common/logger.dart';
import '../../common/assets.dart';
import 'asset_manager_state.dart';

class AssetManagerNotifier extends StateNotifier<AssetState> {
  AssetManagerNotifier() : super(const AssetState());

  bool get isDark => state.isDark;

  void updateTheme(bool isDark) {
    Logger.log('AssetManager: Updating theme to isDark: $isDark');
    state = state.copyWith(isDark: isDark);
  }

  Future<void> loadAllAssets() async {
    Logger.log('AssetManager: Starting asset loading...');
    try {
      await _loadAudio();
      Logger.log('AssetManager: All non-SVG assets loaded successfully');
    } catch (e) {
      Logger.log('AssetManager: Error during loading: $e');
    }
  }

  void setSvgImages(Map<String, Image> images) {
    Logger.log('AssetManager: Setting ${images.length} SVG images.');
    state = state.copyWith(svgImages: images);
  }

  Future<void> _loadAudio() async {
    final audioFiles = AppAssets.all.where((p) => p.endsWith('.wav')).map((p) => p.split('/').last).toList();
    Logger.log('AssetManager: Loading audio files: $audioFiles');
    for (final file in audioFiles) {
      try {
        await FlameAudio.audioCache.load(file);
        Logger.log('AssetManager: Loaded audio: $file');
      } catch (e) {
        Logger.log('AssetManager: Failed to load audio: $file - $e');
      }
    }
    Logger.log('AssetManager: All audio files loaded.');
  }

  Future<String> loadString(String path) async {
    Logger.log('AssetManager: Loading string from path: $path');
    return await rootBundle.loadString(path);
  }

  Image? getSvgAsImage(String path) {
    final image = state.svgImages[path];
    if (image == null) {
      Logger.log('AssetManager: SVG image not found for path: $path');
    }
    return image;
  }

  @override
  void dispose() {
    Logger.log('AssetManager: Disposing assets.');
    for (final image in state.svgImages.values) {
      image.dispose();
    }
    state = const AssetState(); // Reset state
    super.dispose();
  }
}