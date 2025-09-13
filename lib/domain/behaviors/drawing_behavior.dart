import 'package:flutter/painting.dart';

import '../../infrastructure/rendering/asset_manager.dart';
import '../entities/core/component.dart';

/// Defines the interface for a component's drawing behavior.
abstract class DrawingBehavior {
  void draw(Canvas canvas, Size size, ComponentModel component,
      AssetManagerNotifier assets);
}
