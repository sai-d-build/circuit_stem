// lib/ui/svg_capture.dart
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgCapture extends StatefulWidget {
  /// Map: assetPath -> svgString
  final Map<String, String> svgMap;
  final Function(Map<String, ui.Image>) onImagesCaptured;
  final double captureSize; // logical size to render each svg (width & height)

  const SvgCapture({
    super.key,
    required this.svgMap,
    required this.onImagesCaptured,
    this.captureSize = 64.0,
  });

  @override
  SvgCaptureState createState() => SvgCaptureState();
}

class SvgCaptureState extends State<SvgCapture> {
  final Map<String, GlobalKey> _keys = {};
  final Map<String, ui.Image> _images = {};

  @override
  void initState() {
    super.initState();
    for (final key in widget.svgMap.keys) {
      _keys[key] = GlobalKey();
    }
    // Wait one frame for layout then capture
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureWidgets());
  }

  Future<void> _captureWidgets() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    for (final entry in widget.svgMap.entries) {
      final path = entry.key;
      final image = await _captureWidget(path, pixelRatio: pixelRatio);
      if (image != null) {
        _images[path] = image;
      } else {
        debugPrint('SvgCapture: failed to capture $path');
      }
      // Allow a frame to breathe between heavy captures (reduces jank)
      await Future.delayed(const Duration(milliseconds: 8));
    }
    widget.onImagesCaptured(_images);
  }

  Future<ui.Image?> _captureWidget(String key, {required double pixelRatio}) async {
    try {
      final gKey = _keys[key]!;
      final context = gKey.currentContext;
      if (context == null) return null;
      final boundary = context.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      return image;
    } catch (e) {
      debugPrint('Error capturing widget for $key: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Opacity(0.0) (visible to layout but invisible to user)
    return Opacity(
      opacity: 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.svgMap.entries.map((entry) {
          final path = entry.key;
          final svgString = entry.value;
          return RepaintBoundary(
            key: _keys[path],
            child: SizedBox(
              width: widget.captureSize,
              height: widget.captureSize,
              child: SvgPicture.string(
                svgString,
                width: widget.captureSize,
                height: widget.captureSize,
                fit: BoxFit.contain,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}