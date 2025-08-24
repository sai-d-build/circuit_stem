import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

class AnimationState {
  double _elapsedTime = 0.0;
  bool _isActive = true;
  final List<AnimationCallback> _callbacks = [];

  double get elapsedTime => _elapsedTime;
  bool get isActive => _isActive;
  
  void addCallback(AnimationCallback callback) {
    _callbacks.add(callback);
  }
  
  void removeCallback(AnimationCallback callback) {
    _callbacks.remove(callback);
  }
  
  void clearCallbacks() {
    _callbacks.clear();
  }
}

typedef AnimationCallback = void Function(double dt);

class AnimationScheduler {
  final AnimationState _state = AnimationState();
  Ticker? _ticker;
  DateTime? _lastFrameTime;

  double get bulbIntensity {
    // Sinusoidal pulse between 0.9 and 1.2 with frame-rate independence
    return 0.9 + 0.15 * (1 + math.sin(_state.elapsedTime * 2 * math.pi));
  }

  double get wireOffset {
    // Linear progression from 0.0 to 1.0, then repeats
    return (_state.elapsedTime / 2.0) % 1.0; // 2 seconds for one cycle
  }

  void start() {
    if (_ticker == null) {
      _ticker = Ticker(_onTick);
      _ticker!.start();
    }
  }

  void stop() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    _lastFrameTime = null;
  }

  void pause() {
    _state._isActive = false;
  }

  void resume() {
    _state._isActive = true;
  }

  void reset() {
    _state._elapsedTime = 0.0;
    _lastFrameTime = null;
  }

  void addCallback(AnimationCallback callback) {
    _state.addCallback(callback);
  }

  void removeCallback(AnimationCallback callback) {
    _state.removeCallback(callback);
  }

  void _onTick(Duration elapsed) {
    if (!_state.isActive) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final dt = now.difference(_lastFrameTime!).inMicroseconds / 1000000.0;
      _state._elapsedTime += dt;
      
      for (final callback in _state._callbacks) {
        callback(dt);
      }
    }
    _lastFrameTime = now;
  }

  void dispose() {
    stop();
    _state.clearCallbacks();
  }
}