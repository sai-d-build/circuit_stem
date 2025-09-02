import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/audio_manager.dart';

/// Visual feedback utilities for SparkCircuit UI/UX
class FeedbackUtils {
  /// Haptic feedback for different interaction types
  static void provideHapticFeedback(FeedbackType type) {
    switch (type) {
      case FeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case FeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case FeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case FeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case FeedbackType.success:
        // Custom success feedback - light then medium
        HapticFeedback.lightImpact();
        Future.delayed(const Duration(milliseconds: 50), HapticFeedback.mediumImpact);
        break;
      case FeedbackType.error:
        // Custom error feedback - heavy impact
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Sound feedback using audio manager with error handling
  static void provideSoundFeedback(WidgetRef ref, SoundType type) {
    try {
      final audioManager = ref.read(audioManagerProvider);
      String audioPath;
      switch (type) {
        case SoundType.tap:
          audioPath = 'audio/tap.mp3';
          break;
        case SoundType.success:
          audioPath = 'audio/success.mp3';
          break;
        case SoundType.error:
          audioPath = 'audio/error.mp3';
          break;
        case SoundType.componentPlaced:
          audioPath = 'audio/place.mp3';
          break;
        case SoundType.componentSelected:
          audioPath = 'audio/select.mp3';
          break;
      }

      // For web environments, wrap audio playback in try-catch
      try {
        audioManager.playSfx(audioPath);
      } catch (e) {
        // Silently handle audio errors in web environment
        debugPrint('Audio playback failed for $audioPath: $e');
      }
    } catch (e) {
      // Handle any other audio-related errors
      debugPrint('Sound feedback error: $e');
    }
  }
}

/// Feedback types for haptic responses
enum FeedbackType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
}

/// Sound types for audio feedback
enum SoundType {
  tap,
  success,
  error,
  componentPlaced,
  componentSelected,
}

/// Enhanced InkWell with visual feedback
class FeedbackInkWell extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableFeedback;
  final FeedbackType feedbackType;
  final Duration animationDuration;
  final double scaleFactor;
  final BorderRadius? borderRadius;

  const FeedbackInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enableFeedback = true,
    this.feedbackType = FeedbackType.light,
    this.animationDuration = const Duration(milliseconds: 100),
    this.scaleFactor = 0.95,
    this.borderRadius,
  });

  @override
  State<FeedbackInkWell> createState() => _FeedbackInkWellState();
}

class _FeedbackInkWellState extends State<FeedbackInkWell>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableFeedback) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableFeedback) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableFeedback) {
      _scaleController.reverse();
    }
  }

  void _handleTap() {
    if (widget.enableFeedback) {
      FeedbackUtils.provideHapticFeedback(widget.feedbackType);
    }
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.enableFeedback) {
      FeedbackUtils.provideHapticFeedback(FeedbackType.medium);
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Hover effect widget for desktop interactions
class HoverEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double hoverScale;
  final double hoverOpacity;
  final Color? hoverColor;
  final BoxShadow? hoverShadow;
  final VoidCallback? onHoverStart;
  final VoidCallback? onHoverEnd;

  const HoverEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.hoverScale = 1.05,
    this.hoverOpacity = 1.0,
    this.hoverColor,
    this.hoverShadow,
    this.onHoverStart,
    this.onHoverEnd,
  });

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverOpacity,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverStart(PointerEnterEvent event) {
    setState(() => _isHovered = true);
    _controller.forward();
    widget.onHoverStart?.call();
  }

  void _handleHoverEnd(PointerExitEvent event) {
    setState(() => _isHovered = false);
    _controller.reverse();
    widget.onHoverEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _handleHoverStart,
      onExit: _handleHoverEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: _isHovered ? BoxDecoration(
                  color: widget.hoverColor,
                  boxShadow: widget.hoverShadow != null ? [widget.hoverShadow!] : null,
                ) : null,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Focus effect widget for keyboard navigation
class FocusEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color focusColor;
  final double focusBorderWidth;
  final BorderRadius? borderRadius;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;

  const FocusEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.focusColor = Colors.blue,
    this.focusBorderWidth = 2.0,
    this.borderRadius,
    this.onFocus,
    this.onBlur,
  });

  @override
  State<FocusEffect> createState() => _FocusEffectState();
}

class _FocusEffectState extends State<FocusEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: widget.focusBorderWidth,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _controller.forward();
      widget.onFocus?.call();
    } else {
      _controller.reverse();
      widget.onBlur?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: _handleFocusChange,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: _isFocused ? Border.all(
                color: widget.focusColor,
                width: _borderAnimation.value,
              ) : null,
              borderRadius: widget.borderRadius,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Ripple effect for touch interactions
class RippleEffect extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? splashColor;
  final BorderRadius? borderRadius;

  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.splashColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor ?? Theme.of(context).splashColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

/// Combined interactive widget with all feedback types
class InteractiveFeedback extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHaptic;
  final bool enableHover;
  final bool enableFocus;
  final bool enableRipple;
  final FeedbackType feedbackType;
  final Color? hoverColor;
  final Color? focusColor;
  final Color? splashColor;
  final BorderRadius? borderRadius;

  const InteractiveFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enableHaptic = true,
    this.enableHover = true,
    this.enableFocus = true,
    this.enableRipple = true,
    this.feedbackType = FeedbackType.light,
    this.hoverColor,
    this.focusColor,
    this.splashColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    // Add ripple effect
    if (enableRipple) {
      result = RippleEffect(
        onTap: onTap,
        splashColor: splashColor,
        borderRadius: borderRadius,
        child: result,
      );
    }

    // Add hover effect (desktop only)
    if (enableHover && Theme.of(context).platform != TargetPlatform.android &&
        Theme.of(context).platform != TargetPlatform.iOS) {
      result = HoverEffect(
        hoverColor: hoverColor,
        child: result,
      );
    }

    // Add focus effect
    if (enableFocus) {
      result = FocusEffect(
        focusColor: focusColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: borderRadius,
        child: result,
      );
    }

    // Add haptic feedback
    if (enableHaptic) {
      result = FeedbackInkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        feedbackType: feedbackType,
        borderRadius: borderRadius,
        child: result,
      );
    }

    return result;
  }
}