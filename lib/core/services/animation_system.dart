import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rive/rive.dart' as rive;
import '../../common/feature_flags.dart';

part 'animation_system.freezed.dart';

/// Animation system for Circuit STEM educational gaming platform
class AnimationSystem {
  final Map<String, rive.RiveAnimationController> _controllers = {};
  final Map<String, AnimationMetrics> _metrics = {};

  // Animation assets
  static const String componentAnimations = 'assets/animations/components.riv';
  static const String circuitAnimations = 'assets/animations/circuits.riv';
  static const String feedbackAnimations = 'assets/animations/feedback.riv';
  static const String uiAnimations = 'assets/animations/ui.riv';

  AnimationSystem() {
    _initializeAnimationSystem();
  }

  /// Initialize animation system
  void _initializeAnimationSystem() {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    // Pre-load critical animations
    _preloadAnimations();
  }

  /// Pre-load frequently used animations
  void _preloadAnimations() {
    // Component placement animations
    _loadAnimation('component_place', componentAnimations, 'place');
    _loadAnimation('component_rotate', componentAnimations, 'rotate');
    _loadAnimation('component_delete', componentAnimations, 'delete');

    // Circuit state animations
    _loadAnimation('circuit_powered', circuitAnimations, 'powered');
    _loadAnimation('circuit_short', circuitAnimations, 'short_circuit');
    _loadAnimation('current_flow', circuitAnimations, 'current_flow');

    // Feedback animations
    _loadAnimation('success_burst', feedbackAnimations, 'success');
    _loadAnimation('error_flash', feedbackAnimations, 'error');
    _loadAnimation('hint_glow', feedbackAnimations, 'hint');

    // UI animations
    _loadAnimation('level_complete', uiAnimations, 'level_complete');
    _loadAnimation('achievement_unlock', uiAnimations, 'achievement');
  }

  /// Load animation from Rive file
  void _loadAnimation(String key, String filePath, String animationName) {
    // In practice, this would load from actual Rive files
    // For now, we'll create placeholder controllers
    final controller = rive.SimpleAnimation(animationName);
    _controllers[key] = controller;

    // Track metrics
    _metrics[key] = AnimationMetrics(
      key: key,
      loadTime: DateTime.now(),
      playCount: 0,
      averageDuration: Duration.zero,
      totalDuration: Duration.zero,
    );
  }

  /// Private helper: centralize result usage tracking
  void _trackResultUsage(AnimationResult result, String key) {
    result.when(
      success: (duration) => _trackAnimationUsage(key, duration),
      failure: (_) => {},
    );
  }

  /// Play component placement animation
  Future<void> playComponentPlacement(
    String componentId,
    Offset position,
    ComponentType componentType,
  ) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'component_place';
    final result = await _playAnimation(
      animationKey,
      position: position,
      scale: _getComponentScale(componentType),
      onComplete: () => _onPlacementComplete(componentId),
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Play component rotation animation
  Future<void> playComponentRotation(
    String componentId,
    Offset position,
    double rotation,
  ) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'component_rotate';
    final result = await _playAnimation(
      animationKey,
      position: position,
      rotation: rotation,
      onComplete: () => _onRotationComplete(componentId, rotation),
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Play circuit power state animation
  Future<void> playCircuitPowerAnimation(
    List<String> poweredComponents,
    List<String> unpoweredComponents,
  ) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'circuit_powered';

    // Animate powered components
    for (final componentId in poweredComponents) {
      await _playComponentStateAnimation(componentId, true);
    }

    // Animate unpowered components
    for (final componentId in unpoweredComponents) {
      await _playComponentStateAnimation(componentId, false);
    }

    _trackAnimationUsage(animationKey, const Duration(milliseconds: 500));
  }

  /// Play current flow animation
  Future<void> playCurrentFlowAnimation(
    List<Offset> currentPath,
    double currentValue,
  ) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'current_flow';
    final result = await _playAnimation(
      animationKey,
      path: currentPath,
      intensity: _calculateCurrentIntensity(currentValue),
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Play success feedback animation
  Future<void> playSuccessAnimation(Offset position,
      {double scale = 1.0}) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'success_burst';
    final result = await _playAnimation(
      animationKey,
      position: position,
      scale: scale,
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Play error feedback animation
  Future<void> playErrorAnimation(Offset position) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'error_flash';
    final result = await _playAnimation(
      animationKey,
      position: position,
      color: Colors.red,
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Play hint reveal animation
  Future<void> playHintAnimation(Offset position) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'hint_glow';
    final result = await _playAnimation(
      animationKey,
      position: position,
      duration: const Duration(seconds: 2),
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Play level completion animation
  Future<void> playLevelCompleteAnimation() async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'level_complete';
    final result = await _playAnimation(
      animationKey,
      position: Offset.zero, // Full screen
      scale: 2,
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Play achievement unlock animation
  Future<void> playAchievementAnimation(
      String achievementId, Offset position) async {
    if (!FeatureFlagService.isEnabled(FeatureFlag.enableAnimations)) {
      return;
    }

    const animationKey = 'achievement_unlock';
    final result = await _playAnimation(
      animationKey,
      position: position,
      text: achievementId,
    );

    if (result.isSuccessful) {
      _trackResultUsage(result, animationKey);
    }
  }

  /// Get animation performance metrics
  AnimationPerformanceMetrics getPerformanceMetrics() {
    final totalAnimations = _metrics.length;
    final totalPlays =
        _metrics.values.fold<int>(0, (sum, m) => sum + m.playCount);
    final averageLoadTime = _metrics.values.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: _metrics.values
                    .map((m) => m.loadTime.millisecondsSinceEpoch)
                    .reduce((a, b) => a + b) ~/
                _metrics.length);

    return AnimationPerformanceMetrics(
      totalAnimations: totalAnimations,
      totalPlays: totalPlays,
      averageLoadTime: averageLoadTime,
      memoryUsage: _estimateMemoryUsage(),
      frameRate: 60, // Target frame rate
    );
  }

  /// Private helper methods

  Future<AnimationResult> _playAnimation(
    String key, {
    Offset? position,
    double? scale,
    double? rotation,
    Color? color,
    List<Offset>? path,
    double? intensity,
    String? text,
    Duration? duration,
    VoidCallback? onComplete,
  }) async {
    final controller = _controllers[key];
    if (controller == null) {
      return AnimationResult.failure('Animation $key not found');
    }

    final startTime = DateTime.now();

    try {
      // Configure animation parameters
      if (position != null) {
        // Set position (would be implemented with Rive state machines)
      }

      if (scale != null) {
        // Set scale
      }

      if (rotation != null) {
        // Set rotation
      }

      // Play animation
      controller.isActive = true;

      // Wait for completion or timeout
      final animationDuration = duration ?? const Duration(milliseconds: 500);
      await Future.delayed(animationDuration);

      controller.isActive = false;
      onComplete?.call();

      final actualDuration = DateTime.now().difference(startTime);
      return AnimationResult.success(actualDuration);
    } catch (e) {
      return AnimationResult.failure('Animation failed: ${e.toString()}');
    }
  }

  Future<void> _playComponentStateAnimation(
      String componentId, bool isPowered) async {
    // Simplified component state animation
    // In practice, this would animate the specific component
    await Future.delayed(const Duration(milliseconds: 200));
  }

  double _getComponentScale(ComponentType type) {
    switch (type) {
      case ComponentType.voltageSource:
        return 1.2;
      case ComponentType.resistor:
        return 1;
      case ComponentType.capacitor:
        return 1.1;
      case ComponentType.inductor:
        return 1.1;
      case ComponentType.diode:
        return 0.9;
    }
  }

  double _calculateCurrentIntensity(double currentValue) {
    // Normalize current value to animation intensity (0.0 to 1.0)
    const maxCurrent = 10.0; // Amperes
    return (currentValue / maxCurrent).clamp(0.0, 1.0);
  }

  void _onPlacementComplete(String componentId) {
    // Handle placement completion
    // Could trigger additional effects or state updates
  }

  void _onRotationComplete(String componentId, double rotation) {
    // Handle rotation completion
    // Could trigger snap effects or validation
  }

  void _trackAnimationUsage(String key, Duration duration) {
    final metrics = _metrics[key];
    if (metrics != null) {
      final updatedMetrics = metrics.copyWith(
        playCount: metrics.playCount + 1,
        totalDuration: metrics.totalDuration + duration,
        averageDuration: Duration(
          milliseconds:
              ((metrics.averageDuration.inMilliseconds * metrics.playCount) +
                      duration.inMilliseconds) ~/
                  (metrics.playCount + 1),
        ),
      );
      _metrics[key] = updatedMetrics;
    }
  }

  int _estimateMemoryUsage() {
    // Rough estimate based on number of loaded animations
    const bytesPerAnimation = 50000; // 50KB per animation
    return _controllers.length * bytesPerAnimation;
  }
}

// Animation result
@freezed
class AnimationResult with _$AnimationResult {
  const factory AnimationResult.success(Duration duration) =
      _AnimationResultSuccess;
  const factory AnimationResult.failure(String reason) =
      _AnimationResultFailure;

  const AnimationResult._();

  bool get isSuccessful => this is _AnimationResultSuccess;
}

// Animation metrics
@freezed
class AnimationMetrics with _$AnimationMetrics {
  const factory AnimationMetrics({
    required String key,
    required DateTime loadTime,
    required int playCount,
    required Duration averageDuration,
    required Duration totalDuration,
  }) = _AnimationMetrics;
}

// Animation performance metrics
@freezed
class AnimationPerformanceMetrics with _$AnimationPerformanceMetrics {
  const factory AnimationPerformanceMetrics({
    required int totalAnimations,
    required int totalPlays,
    required Duration averageLoadTime,
    required int memoryUsage,
    required double frameRate,
  }) = _AnimationPerformanceMetrics;
}

// Component types for animation scaling
enum ComponentType {
  voltageSource,
  resistor,
  capacitor,
  inductor,
  diode,
}
