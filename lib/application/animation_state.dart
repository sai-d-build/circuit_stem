import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

/// Provides animation state across the app
final animationStateProvider = StateNotifierProvider<AnimationStateNotifier, AnimationState>((ref) {
  return AnimationStateNotifier();
});

/// Manages the animation state
class AnimationState {
  final double elapsedTime;
  final bool isActive;
  final List<String> activeAnimations;

  const AnimationState({
    this.elapsedTime = 0.0,
    this.isActive = true,
    this.activeAnimations = const [],
  });

  AnimationState copyWith({
    double? elapsedTime,
    bool? isActive,
    List<String>? activeAnimations,
  }) {
    return AnimationState(
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isActive: isActive ?? this.isActive,
      activeAnimations: activeAnimations ?? this.activeAnimations,
    );
  }

  double get bulbIntensity {
    // Sinusoidal pulse between 0.9 and 1.2
    return 0.9 + 0.15 * (1 + math.sin(elapsedTime * 2 * math.pi));
  }

  double get wireOffset {
    // Linear progression from 0.0 to 1.0, then repeats
    return (elapsedTime / 2.0) % 1.0; // 2 seconds for one cycle
  }
}

/// Controls animation state with proper resource management
class AnimationStateNotifier extends StateNotifier<AnimationState> {
  Ticker? _ticker;
  DateTime? _lastFrameTime;
  final Map<String, AnimationCallback> _callbacks = {};

  AnimationStateNotifier() : super(const AnimationState()) {
    _setupTicker();
  }

  void _setupTicker() {
    _ticker = Ticker(_onTick);
    if (state.isActive) {
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    if (!state.isActive) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final dt = now.difference(_lastFrameTime!).inMicroseconds / 1000000.0;
      
      // Update elapsed time
      state = state.copyWith(
        elapsedTime: state.elapsedTime + dt
      );

      // Execute callbacks
      for (final callback in _callbacks.values) {
        callback(dt);
      }
    }
    _lastFrameTime = now;
  }

  void addAnimation(String id, AnimationCallback callback) {
    _callbacks[id] = callback;
    state = state.copyWith(
      activeAnimations: [...state.activeAnimations, id]
    );
  }

  void removeAnimation(String id) {
    _callbacks.remove(id);
    state = state.copyWith(
      activeAnimations: state.activeAnimations.where((aid) => aid != id).toList()
    );
  }

  void pause() {
    if (!state.isActive) return;
    _ticker?.stop();
    state = state.copyWith(isActive: false);
  }

  void resume() {
    if (state.isActive) return;
    _ticker?.start();
    state = state.copyWith(isActive: true);
  }

  void reset() {
    _lastFrameTime = null;
    state = state.copyWith(elapsedTime: 0.0);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}

typedef AnimationCallback = void Function(double dt);
