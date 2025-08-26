# Circuit STEM UI Implementation Guide

**Author:** Kilo Code  
**Date:** 2025-08-20  
**Status:** Implementation Specification  
**Version:** 1.0  

---

## Implementation Overview

This guide provides detailed implementation specifications for the Circuit STEM UI redesign, including code examples, refactoring strategies, and integration patterns with the existing Component-Behavior architecture.

## Phase 1: Foundation Implementation

### 1.1 Enhanced Theme System

#### Create New Theme Architecture
```dart
// lib/ui/theme/circuit_theme.dart
import 'package:flutter/material.dart';

class CircuitTheme {
  final CircuitColorScheme colorScheme;
  final CircuitAnimationTheme animations;
  final CircuitComponentTheme components;
  final CircuitGridTheme grid;
  final CircuitAccessibilityTheme accessibility;

  const CircuitTheme({
    required this.colorScheme,
    required this.animations,
    required this.components,
    required this.grid,
    required this.accessibility,
  });

  static CircuitTheme light() => CircuitTheme(
    colorScheme: CircuitColorScheme.light(),
    animations: CircuitAnimationTheme.standard(),
    components: CircuitComponentTheme.light(),
    grid: CircuitGridTheme.light(),
    accessibility: CircuitAccessibilityTheme.standard(),
  );

  static CircuitTheme dark() => CircuitTheme(
    colorScheme: CircuitColorScheme.dark(),
    animations: CircuitAnimationTheme.standard(),
    components: CircuitComponentTheme.dark(),
    grid: CircuitGridTheme.dark(),
    accessibility: CircuitAccessibilityTheme.standard(),
  );

  static CircuitTheme highContrast() => CircuitTheme(
    colorScheme: CircuitColorScheme.highContrast(),
    animations: CircuitAnimationTheme.reduced(),
    components: CircuitComponentTheme.highContrast(),
    grid: CircuitGridTheme.highContrast(),
    accessibility: CircuitAccessibilityTheme.enhanced(),
  );
}
```

#### Color Scheme Enhancement
```dart
// lib/ui/theme/color_schemes.dart
class CircuitColorScheme {
  // Grid colors
  final Color gridBackground;
  final Color gridLines;
  final Color gridHover;
  final Color gridValidDrop;
  final Color gridInvalidDrop;
  
  // Component colors
  final Color wirePowered;
  final Color wireUnpowered;
  final Color componentActive;
  final Color componentInactive;
  final Color componentHover;
  final Color componentSelected;
  
  // UI colors
  final Color paletteBackground;
  final Color paletteItemBackground;
  final Color paletteItemBorder;
  final Color topBarBackground;
  final Color progressComplete;
  final Color progressIncomplete;
  
  // Feedback colors
  final Color successGlow;
  final Color errorGlow;
  final Color warningGlow;
  final Color hintGlow;

  const CircuitColorScheme({
    required this.gridBackground,
    required this.gridLines,
    required this.gridHover,
    required this.gridValidDrop,
    required this.gridInvalidDrop,
    required this.wirePowered,
    required this.wireUnpowered,
    required this.componentActive,
    required this.componentInactive,
    required this.componentHover,
    required this.componentSelected,
    required this.paletteBackground,
    required this.paletteItemBackground,
    required this.paletteItemBorder,
    required this.topBarBackground,
    required this.progressComplete,
    required this.progressIncomplete,
    required this.successGlow,
    required this.errorGlow,
    required this.warningGlow,
    required this.hintGlow,
  });

  static CircuitColorScheme light() => const CircuitColorScheme(
    gridBackground: Color(0xFFF8F9FA),
    gridLines: Color(0xFFE0E0E0),
    gridHover: Color(0x1A2196F3),
    gridValidDrop: Color(0x334CAF50),
    gridInvalidDrop: Color(0x33F44336),
    wirePowered: Color(0xFF4CAF50),
    wireUnpowered: Color(0xFF757575),
    componentActive: Color(0xFFFFC107),
    componentInactive: Color(0xFF9E9E9E),
    componentHover: Color(0x1A2196F3),
    componentSelected: Color(0xFF2196F3),
    paletteBackground: Color(0xFFFFFFFF),
    paletteItemBackground: Color(0xFFF5F5F5),
    paletteItemBorder: Color(0xFFE0E0E0),
    topBarBackground: Color(0xFFE8F5E8),
    progressComplete: Color(0xFF4CAF50),
    progressIncomplete: Color(0xFFE0E0E0),
    successGlow: Color(0xFF4CAF50),
    errorGlow: Color(0xFFF44336),
    warningGlow: Color(0xFFFF9800),
    hintGlow: Color(0xFF2196F3),
  );

  // Colorblind-friendly palette
  static CircuitColorScheme colorblindFriendly() => const CircuitColorScheme(
    // Use patterns and shapes instead of just colors
    gridBackground: Color(0xFFF8F9FA),
    gridLines: Color(0xFFE0E0E0),
    gridHover: Color(0x1A000000),
    gridValidDrop: Color(0x33000000),
    gridInvalidDrop: Color(0x33000000),
    wirePowered: Color(0xFF000000), // Use patterns for differentiation
    wireUnpowered: Color(0xFF757575),
    componentActive: Color(0xFF000000),
    componentInactive: Color(0xFF9E9E9E),
    componentHover: Color(0x1A000000),
    componentSelected: Color(0xFF000000),
    paletteBackground: Color(0xFFFFFFFF),
    paletteItemBackground: Color(0xFFF5F5F5),
    paletteItemBorder: Color(0xFFE0E0E0),
    topBarBackground: Color(0xFFE8F5E8),
    progressComplete: Color(0xFF000000),
    progressIncomplete: Color(0xFFE0E0E0),
    successGlow: Color(0xFF000000),
    errorGlow: Color(0xFF000000),
    warningGlow: Color(0xFF000000),
    hintGlow: Color(0xFF000000),
  );
}
```

### 1.2 Enhanced Grid Renderer

#### Grid State Management
```dart
// lib/ui/rendering/grid_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'grid_state.freezed.dart';

@freezed
class GridState with _$GridState {
  const factory GridState({
    @Default(null) Offset? hoverPosition,
    @Default(null) Offset? dragPosition,
    @Default({}) Set<Offset> validDropZones,
    @Default({}) Set<Offset> invalidDropZones,
    @Default({}) Set<Offset> connectionHints,
    @Default(false) bool showGrid,
    @Default(1.0) double gridOpacity,
    @Default(null) String? selectedComponentId,
  }) = _GridState;
}

class GridStateNotifier extends StateNotifier<GridState> {
  GridStateNotifier() : super(const GridState());

  void updateHoverPosition(Offset? position) {
    state = state.copyWith(hoverPosition: position);
  }

  void updateDragPosition(Offset? position) {
    state = state.copyWith(dragPosition: position);
  }

  void setValidDropZones(Set<Offset> zones) {
    state = state.copyWith(validDropZones: zones);
  }

  void setInvalidDropZones(Set<Offset> zones) {
    state = state.copyWith(invalidDropZones: zones);
  }

  void toggleGrid() {
    state = state.copyWith(showGrid: !state.showGrid);
  }

  void setGridOpacity(double opacity) {
    state = state.copyWith(gridOpacity: opacity.clamp(0.0, 1.0));
  }
}

// Provider
final gridStateProvider = StateNotifierProvider<GridStateNotifier, GridState>((ref) {
  return GridStateNotifier();
});
```

#### Enhanced Grid Renderer
```dart
// lib/ui/rendering/grid_renderer.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../theme/circuit_theme.dart';
import 'grid_state.dart';
import '../../common/constants.dart';

class GridRenderer extends CustomPainter {
  final CircuitTheme theme;
  final GridState gridState;
  final int rows;
  final int cols;
  final Animation<double> hoverAnimation;
  final ui.Image? gridTexture;

  GridRenderer({
    required this.theme,
    required this.gridState,
    required this.rows,
    required this.cols,
    required this.hoverAnimation,
    this.gridTexture,
  }) : super(repaint: hoverAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    if (gridState.showGrid) {
      _drawGridLines(canvas, size);
    }
    _drawHoverEffects(canvas, size);
    _drawDropZoneIndicators(canvas, size);
    _drawConnectionHints(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = theme.colorScheme.gridBackground;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw subtle texture if available
    if (gridTexture != null) {
      final texturePaint = Paint()
        ..color = theme.colorScheme.gridLines.withOpacity(0.1)
        ..blendMode = BlendMode.overlay;
      
      canvas.drawImageRect(
        gridTexture!,
        Rect.fromLTWH(0, 0, gridTexture!.width.toDouble(), gridTexture!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        texturePaint,
      );
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.gridLines.withOpacity(gridState.gridOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (int i = 0; i <= cols; i++) {
      final x = i * cellSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 0; i <= rows; i++) {
      final y = i * cellSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawHoverEffects(Canvas canvas, Size size) {
    final hoverPos = gridState.hoverPosition;
    if (hoverPos == null) return;

    final cellCol = (hoverPos.dx / cellSize).floor();
    final cellRow = (hoverPos.dy / cellSize).floor();

    if (cellCol >= 0 && cellCol < cols && cellRow >= 0 && cellRow < rows) {
      final cellRect = Rect.fromLTWH(
        cellCol * cellSize,
        cellRow * cellSize,
        cellSize,
        cellSize,
      );

      final hoverPaint = Paint()
        ..color = theme.colorScheme.gridHover.withOpacity(hoverAnimation.value)
        ..style = PaintingStyle.fill;

      canvas.drawRect(cellRect, hoverPaint);

      // Add subtle border
      final borderPaint = Paint()
        ..color = theme.colorScheme.componentSelected.withOpacity(hoverAnimation.value * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(cellRect, borderPaint);
    }
  }

  void _drawDropZoneIndicators(Canvas canvas, Size size) {
    // Valid drop zones
    for (final zone in gridState.validDropZones) {
      final cellRect = Rect.fromLTWH(
        zone.dx * cellSize,
        zone.dy * cellSize,
        cellSize,
        cellSize,
      );

      final validPaint = Paint()
        ..color = theme.colorScheme.gridValidDrop
        ..style = PaintingStyle.fill;

      canvas.drawRect(cellRect, validPaint);

      // Add checkmark icon
      _drawCheckmark(canvas, cellRect.center, cellSize * 0.3);
    }

    // Invalid drop zones
    for (final zone in gridState.invalidDropZones) {
      final cellRect = Rect.fromLTWH(
        zone.dx * cellSize,
        zone.dy * cellSize,
        cellSize,
        cellSize,
      );

      final invalidPaint = Paint()
        ..color = theme.colorScheme.gridInvalidDrop
        ..style = PaintingStyle.fill;

      canvas.drawRect(cellRect, invalidPaint);

      // Add X icon
      _drawX(canvas, cellRect.center, cellSize * 0.3);
    }
  }

  void _drawConnectionHints(Canvas canvas, Size size) {
    for (final hint in gridState.connectionHints) {
      final center = Offset(
        hint.dx * cellSize + cellSize / 2,
        hint.dy * cellSize + cellSize / 2,
      );

      final hintPaint = Paint()
        ..color = theme.colorScheme.hintGlow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Draw pulsing circle
      final radius = cellSize * 0.4 * (0.8 + 0.2 * math.sin(DateTime.now().millisecondsSinceEpoch / 200));
      canvas.drawCircle(center, radius, hintPaint);
    }
  }

  void _drawCheckmark(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = theme.colorScheme.successGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(center.dx - size * 0.3, center.dy);
    path.lineTo(center.dx - size * 0.1, center.dy + size * 0.2);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.2);

    canvas.drawPath(path, paint);
  }

  void _drawX(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = theme.colorScheme.errorGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - size * 0.3, center.dy - size * 0.3),
      Offset(center.dx + size * 0.3, center.dy + size * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + size * 0.3, center.dy - size * 0.3),
      Offset(center.dx - size * 0.3, center.dy + size * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(GridRenderer oldDelegate) {
    return oldDelegate.theme != theme ||
           oldDelegate.gridState != gridState ||
           oldDelegate.rows != rows ||
           oldDelegate.cols != cols ||
           oldDelegate.gridTexture != gridTexture;
  }
}
```

### 1.3 Animation System Foundation

#### Animation Orchestrator
```dart
// lib/ui/animations/animation_orchestrator.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class AnimationOrchestrator {
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Timer> _timers = {};

  AnimationController createController({
    required String id,
    required Duration duration,
    required TickerProvider vsync,
  }) {
    _controllers[id]?.dispose();
    final controller = AnimationController(duration: duration, vsync: vsync);
    _controllers[id] = controller;
    return controller;
  }

  void startAnimation(String id) {
    _controllers[id]?.forward();
  }

  void stopAnimation(String id) {
    _controllers[id]?.stop();
  }

  void reverseAnimation(String id) {
    _controllers[id]?.reverse();
  }

  void resetAnimation(String id) {
    _controllers[id]?.reset();
  }

  void scheduleAnimation(String id, Duration delay) {
    _timers[id]?.cancel();
    _timers[id] = Timer(delay, () => startAnimation(id));
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _controllers.clear();
    _timers.clear();
  }
}

// Provider
final animationOrchestratorProvider = Provider<AnimationOrchestrator>((ref) {
  final orchestrator = AnimationOrchestrator();
  ref.onDispose(() => orchestrator.dispose());
  return orchestrator;
});
```

#### Component Animation State
```dart
// lib/ui/animations/animation_state.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'animation_state.freezed.dart';

@freezed
class AnimationState with _$AnimationState {
  const factory AnimationState({
    @Default(0.0) double glowIntensity,
    @Default(0.0) double pulsePhase,
    @Default(0.0) double flowOffset,
    @Default(0.0) double scaleAnimation,
    @Default(0.0) double rotationAnimation,
    @Default(Offset.zero) Offset positionOffset,
    @Default(1.0) double opacity,
    @Default(false) bool isAnimating,
  }) = _AnimationState;
}

class ComponentAnimationController {
  final AnimationController _glowController;
  final AnimationController _pulseController;
  final AnimationController _flowController;
  final AnimationController _scaleController;

  late final Animation<double> glowAnimation;
  late final Animation<double> pulseAnimation;
  late final Animation<double> flowAnimation;
  late final Animation<double> scaleAnimation;

  ComponentAnimationController({
    required TickerProvider vsync,
  }) : _glowController = AnimationController(
          duration: const Duration(milliseconds: 1000),
          vsync: vsync,
        ),
        _pulseController = AnimationController(
          duration: const Duration(milliseconds: 2000),
          vsync: vsync,
        ),
        _flowController = AnimationController(
          duration: const Duration(milliseconds: 3000),
          vsync: vsync,
        ),
        _scaleController = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: vsync,
        ) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    flowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flowController, curve: Curves.linear),
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void startGlow() {
    _glowController.repeat(reverse: true);
  }

  void stopGlow() {
    _glowController.stop();
    _glowController.reset();
  }

  void startPulse() {
    _pulseController.repeat();
  }

  void stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  void startFlow() {
    _flowController.repeat();
  }

  void stopFlow() {
    _flowController.stop();
    _flowController.reset();
  }

  void animateScale() {
    _scaleController.forward().then((_) => _scaleController.reverse());
  }

  AnimationState get currentState => AnimationState(
    glowIntensity: glowAnimation.value,
    pulsePhase: pulseAnimation.value,
    flowOffset: flowAnimation.value,
    scaleAnimation: scaleAnimation.value,
    isAnimating: _glowController.isAnimating || 
                 _pulseController.isAnimating || 
                 _flowController.isAnimating || 
                 _scaleController.isAnimating,
  );

  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _flowController.dispose();
    _scaleController.dispose();
  }
}
```

## Phase 2: Enhanced Component Behaviors

### 2.1 Enhanced Drawing Behaviors

#### Updated Drawing Behavior Interface
```dart
// lib/behaviors/drawing_behavior.dart (Enhanced)
import 'package:flutter/painting.dart';
import '../models/component.dart';
import '../services/asset_manager.dart';
import '../ui/animations/animation_state.dart';
import '../ui/theme/circuit_theme.dart';

/// Enhanced drawing behavior with animation support
abstract class DrawingBehavior {
  void draw(
    Canvas canvas, 
    Size size, 
    ComponentModel component, 
    AssetManagerNotifier assets,
    {
      AnimationState? animationState,
      CircuitTheme? theme,
      bool isPreview = false,
    }
  );
}
```

#### Enhanced Bulb Drawing with Animations
```dart
// lib/components/bulb.dart (Enhanced)
class BulbDrawingBehavior implements DrawingBehavior {
  @override
  void draw(
    Canvas canvas, 
    Size size, 
    ComponentModel component, 
    AssetManagerNotifier assets,
    {
      AnimationState? animationState,
      CircuitTheme? theme,
      bool isPreview = false,
    }
  ) {
    final effectiveTheme = theme ?? CircuitTheme.light();
    final effectiveAnimationState = animationState ?? const AnimationState();
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 3;
    
    // Apply scale animation
    final animatedRadius = baseRadius * effectiveAnimationState.scaleAnimation;

    final componentColor = component.isPowered
        ? effectiveTheme.colorScheme.componentActive
        : effectiveTheme.colorScheme.componentInactive;

    // Draw base bulb
    paint.color = componentColor;
    canvas.drawCircle(center, animatedRadius, paint);

    if (component.isPowered && !isPreview) {
      // Animated glow effect
      final glowIntensity = effectiveAnimationState.glowIntensity;
      final glowRadius = animatedRadius + (10 * glowIntensity);
      
      final glowPaint = Paint()
        ..color = effectiveTheme.colorScheme.successGlow.withOpacity(0.3 * glowIntensity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(center, glowRadius, glowPaint);

      // Fill with animated light
      fillPaint.color = componentColor.withOpacity(0.3 + 0.4 * glowIntensity);
      canvas.drawCircle(center, animatedRadius, fillPaint);

      // Animated light rays
      _drawAnimatedLightRays(canvas, center, animatedRadius, effectiveAnimationState, effectiveTheme);
    }

    // Draw filament
    _drawFilament(canvas, center, animatedRadius, paint);
  }

  void _drawAnimatedLightRays(
    Canvas canvas, 
    Offset center, 
    double radius, 
    AnimationState animationState,
    CircuitTheme theme,
  ) {
    final rayPaint = Paint()
      ..color = theme.colorScheme.successGlow
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rayCount = 8;
    final rayLength = 8 + 4 * animationState.glowIntensity;
    final rotationOffset = animationState.pulsePhase * 2 * math.pi / rayCount;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount) + rotationOffset;
      final rayOpacity = 0.5 + 0.5 * math.sin(animationState.pulsePhase * 2 * math.pi + i);
      
      rayPaint.color = theme.colorScheme.successGlow.withOpacity(rayOpacity);
      
      final start = Offset(
        center.dx + (radius + 2) * math.cos(angle),
        center.dy + (radius + 2) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + rayLength) * math.cos(angle),
        center.dy + (radius + rayLength) * math.sin(angle),
      );
      
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawFilament(Canvas canvas, Offset center, double radius, Paint paint) {
    paint.strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      paint,
    );
  }
}
```

#### Enhanced Wire Drawing with Flow Animation
```dart
// lib/components/wire.dart (Enhanced)
class WireStraightDrawingBehavior implements DrawingBehavior {
  @override
  void draw(
    Canvas canvas, 
    Size size, 
    ComponentModel component, 
    AssetManagerNotifier assets,
    {
      AnimationState? animationState,
      CircuitTheme? theme,
      bool isPreview = false,
    }
  ) {
    final effectiveTheme = theme ?? CircuitTheme.light();
    final effectiveAnimationState = animationState ?? const AnimationState();
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final wireColor = component.isPowered
        ? effectiveTheme.colorScheme.wirePowered
        : effectiveTheme.colorScheme.wireUnpowered;

    paint.color = wireColor;

    // Apply rotation
    canvas.save();
    final center = Offset(size.width / 2, size.height / 2);
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw base wire
    final wirePath = Path();
    wirePath.moveTo(size.width / 2, 0);
    wirePath.lineTo(size.width / 2, size.height);
    canvas.drawPath(wirePath, paint);

    // Draw animated flow if powered and not preview
    if (component.isPowered && !isPreview) {
      _drawFlowAnimation(canvas, size, effectiveAnimationState, effectiveTheme);
    }

    canvas.restore();
  }

  void _drawFlowAnimation(
    Canvas canvas, 
    Size size, 
    AnimationState animationState,
    CircuitTheme theme,
  ) {
    final flowPaint = Paint()
      ..color = theme.colorScheme.successGlow.withOpacity(0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final particleCount = 3;
    final wireLength = size.height;
    final particleSpacing = wireLength / particleCount;

    for (int i = 0; i < particleCount; i++) {
      final baseY = (i * particleSpacing + animationState.flowOffset * wireLength) % wireLength;
      final particleY = baseY;
      
      // Draw flowing particle
      canvas.drawCircle(
        Offset(size.width / 2, particleY),
        2.0,
        flowPaint,
      );
      
      // Draw particle trail
      final trailPaint = Paint()
        ..color = theme.colorScheme.successGlow.withOpacity(0.3)
        ..strokeWidth = 1.0;
      
      canvas.drawLine(
        Offset(size.width / 2, particleY),
        Offset(size.width / 2, particleY - 10),
        trailPaint,
      );
    }
  }
}
```

### 2.2 Enhanced Component Palette

#### Palette Container with Categories
```dart
// lib/ui/widgets/enhanced_palette/palette_container.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/component.dart';
import '../../../ui/theme/circuit_theme.dart';
import 'palette_category.dart';
import 'palette_search.dart';

class EnhancedPaletteContainer extends ConsumerStatefulWidget {
  final List<ComponentModel> availableComponents;
  final Function(ComponentModel) onComponentSelected;
  final ComponentModel? selectedComponent;

  const EnhancedPaletteContainer