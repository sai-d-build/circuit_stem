import 'dart:ui' as ui;

abstract class SvgProcessorBase {
  Future<Map<String, ui.Image>> processSvgs(List<String> assetPaths);
}
