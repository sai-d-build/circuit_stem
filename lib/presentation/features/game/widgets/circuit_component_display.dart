import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/behaviors/drawing_behavior.dart';
import 'package:circuit_stem/presentation/state/game_state.dart';
import 'package:circuit_stem/infrastructure/rendering/asset_manager.dart';
import 'package:circuit_stem/common/logger.dart';

class CircuitComponentDisplay extends ConsumerWidget {
  final ComponentModel component;
  final double size;
  final bool isPreview;

  const CircuitComponentDisplay({
    required this.component,
    required this.size,
    this.isPreview = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger.log(
        "CircuitComponentDisplay: Building for component: ${component.id} (type: ${component.type})");
    final assetManager = ref.watch(assetManagerProvider.notifier);
    return Transform.rotate(
      angle: component.rotation * pi / 2,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ComponentDisplayPainter(
            component: component,
            assetManager: assetManager,
          ),
        ),
      ),
    );
  }
}

class _ComponentDisplayPainter extends CustomPainter {
  final ComponentModel component;
  final AssetManagerNotifier assetManager;

  _ComponentDisplayPainter(
      {required this.component, required this.assetManager});

  @override
  void paint(Canvas canvas, Size size) {
    Logger.log(
        "_ComponentDisplayPainter: Painting component: ${component.id} (type: ${component.type})");
    final behavior = component.getBehavior<DrawingBehavior>();
    if (behavior != null) {
      Logger.log(
          "_ComponentDisplayPainter: Found DrawingBehavior for ${component.type}. Drawing...");
      behavior.draw(canvas, size, component, assetManager);
    } else {
      Logger.log(
          "_ComponentDisplayPainter: No DrawingBehavior found for component: ${component.type}");
    }
  }

  @override
  bool shouldRepaint(covariant _ComponentDisplayPainter oldDelegate) {
    return oldDelegate.component != component ||
        oldDelegate.assetManager.isDark != assetManager.isDark;
  }
}
