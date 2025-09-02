import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

class AnimationControllerPool {
  static final AnimationControllerPool _instance = AnimationControllerPool._internal();
  factory AnimationControllerPool() => _instance;
  AnimationControllerPool._internal();

  final Map<String, _PooledController> _pool = {};
  final Map<String, int> _usageCount = {};

  AnimationController getController(
    String key,
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 300),
    String? debugLabel,
  }) {
    if (_pool.containsKey(key)) {
      final pooled = _pool[key]!;
      _usageCount[key] = (_usageCount[key] ?? 0) + 1;
      return pooled.controller;
    }

    final controller = AnimationController(
      duration: duration,
      debugLabel: debugLabel,
      vsync: vsync,
    );

    _pool[key] = _PooledController(controller, vsync);
    _usageCount[key] = 1;

    return controller;
  }

  void releaseController(String key) {
    if (_usageCount.containsKey(key)) {
      _usageCount[key] = _usageCount[key]! - 1;

      if (_usageCount[key] == 0) {
        _pool[key]?.controller.dispose();
        _pool.remove(key);
        _usageCount.remove(key);
      }
    }
  }

  void disposeAll() {
    for (final pooled in _pool.values) {
      pooled.controller.dispose();
    }
    _pool.clear();
    _usageCount.clear();
  }

  // Debug information
  Map<String, int> get usageStats => Map.from(_usageCount);
  int get totalControllers => _pool.length;
}

class _PooledController {
  final AnimationController controller;
  final TickerProvider vsync;

  _PooledController(this.controller, this.vsync);
}