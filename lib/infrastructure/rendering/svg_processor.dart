import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:circuit_stem/common/logger.dart';
import 'svg_processor_base.dart';

class SvgProcessor implements SvgProcessorBase {
  @override
  Future<Map<String, ui.Image>> processSvgs(List<String> assetPaths) async {
    Logger.log('SvgProcessor: Starting SVG processing for ${assetPaths.length} assets...');
    Logger.log('SvgProcessor: Asset paths: $assetPaths');
    final Map<String, ui.Image> images = {};
    for (final path in assetPaths) {
      try {
        final svgString = await rootBundle.loadString(path);
        final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
        final image = await pictureInfo.picture.toImage(64, 64); // Assuming a default size
        pictureInfo.picture.dispose();
        images[path] = image;
        Logger.log('SvgProcessor: Successfully processed $path');
      } catch (e) {
        debugPrint('Failed to process SVG $path: $e. Skipping.');
      }
    }
    return images;
  }
}
