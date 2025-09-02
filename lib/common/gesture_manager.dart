import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

class GestureManager {
  static final GestureManager _instance = GestureManager._internal();
  factory GestureManager() => _instance;
  GestureManager._internal();

  // Unified gesture settings
  static double get tapSlop => PlatformUtils.prefersPreciseGestures ? 8.0 : 12.0;
  static double get panSlop => PlatformUtils.prefersPreciseGestures ? 4.0 : 8.0;
  static Duration get longPressTimeout => PlatformUtils.isIOS
      ? const Duration(milliseconds: 500)
      : const Duration(milliseconds: 600);

  // Platform-specific gesture recognizers
  static TapGestureRecognizer createTapRecognizer({
    required GestureTapCallback onTap,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCancelCallback? onTapCancel,
  }) {
    return TapGestureRecognizer()
      ..onTap = onTap
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTapCancel = onTapCancel;
  }

  static PanGestureRecognizer createPanRecognizer({
    required GestureDragUpdateCallback onUpdate,
    GestureDragDownCallback? onDown,
    GestureDragStartCallback? onStart,
    GestureDragEndCallback? onEnd,
    GestureDragCancelCallback? onCancel,
  }) {
    return PanGestureRecognizer()
      ..onDown = onDown
      ..onStart = onStart
      ..onUpdate = onUpdate
      ..onEnd = onEnd
      ..onCancel = onCancel;
  }

  static LongPressGestureRecognizer createLongPressRecognizer({
    required GestureLongPressCallback onLongPress,
    GestureLongPressStartCallback? onLongPressStart,
    GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate,
    GestureLongPressEndCallback? onLongPressEnd,
    GestureLongPressCancelCallback? onLongPressCancel,
  }) {
    return LongPressGestureRecognizer(
      duration: longPressTimeout,
    )
      ..onLongPress = onLongPress
      ..onLongPressStart = onLongPressStart
      ..onLongPressMoveUpdate = onLongPressMoveUpdate
      ..onLongPressEnd = onLongPressEnd
      ..onLongPressCancel = onLongPressCancel;
  }

  // Unified gesture arena management
  static void resolveGestureArena(GestureArenaEntry entry, GestureDisposition disposition) {
    entry.resolve(disposition);
  }

  // Platform-specific haptic feedback
  static void performHapticFeedback(BuildContext context) {
    if (PlatformUtils.isIOS) {
      // iOS-specific haptic feedback
      // Implementation would use iOS-specific APIs
    } else if (PlatformUtils.isAndroid) {
      // Android-specific haptic feedback
      // Implementation would use Android-specific APIs
    }
  }
}