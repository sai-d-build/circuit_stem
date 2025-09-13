import 'package:flutter/material.dart';

/// Animation utilities for SparkCircuit UI/UX polish
class AnimationUtils {
  // Standard animation durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // Animation curves
  static const Curve easeOutQuart = Curves.easeOutQuart;
  static const Curve easeInOutQuart = Curves.easeInOutQuart;
  static const Curve bounceOut = Curves.bounceOut;

  /// Get animation duration based on reduced motion preference
  static Duration getDuration(BuildContext context, Duration duration) {
    final platform = Theme.of(context).platform;
    // Respect reduced motion on iOS
    if (platform == TargetPlatform.iOS) {
      final mediaQuery = MediaQuery.of(context);
      if (mediaQuery.disableAnimations) {
        return Duration.zero;
      }
    }
    return duration;
  }

  /// Create a smooth scale animation for component placement
  static AnimationController createPlacementController(
    TickerProvider vsync, {
    Duration duration = normal,
  }) {
    return AnimationController(
      duration: duration,
      vsync: vsync,
    );
  }

  /// Create a bounce animation for successful actions
  static Animation<double> createBounceAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  /// Create a fade-in animation
  static Animation<double> createFadeInAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: easeOutQuart,
      ),
    );
  }

  /// Create a slide-in animation
  static Animation<Offset> createSlideInAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0, 1),
  }) {
    return Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: easeOutQuart,
      ),
    );
  }

  /// Create a scale-in animation
  static Animation<double> createScaleInAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: easeOutQuart,
      ),
    );
  }

  /// Create a staggered animation for lists
  static Animation<double> createStaggeredAnimation(
    AnimationController controller,
    int index,
    int totalItems,
  ) {
    final startDelay = index / totalItems;
    final endDelay = (index + 1) / totalItems;

    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          startDelay,
          endDelay,
          curve: easeOutQuart,
        ),
      ),
    );
  }

  /// Create a color transition animation
  static Animation<Color?> createColorAnimation(
    AnimationController controller,
    Color begin,
    Color end,
  ) {
    return ColorTween(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: easeInOutQuart,
      ),
    );
  }

  /// Create a pulse animation for loading states
  static Animation<double> createPulseAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Create a shimmer animation for skeleton loading
  static Animation<double> createShimmerAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: -1,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ),
    );
  }
}

/// Extension methods for animations
extension AnimationExtensions on AnimationController {
  /// Play animation forward and dispose
  void playAndDispose() {
    forward().then((_) => dispose());
  }

  /// Play animation with reverse
  void playWithReverse() {
    forward().then((_) => reverse());
  }
}

/// Pre-built animated widgets
class AnimatedComponentCard extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final bool isPlacing;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedComponentCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.isPlacing = false,
    this.onTap,
    this.animationDuration = AnimationUtils.normal,
  });

  @override
  State<AnimatedComponentCard> createState() => _AnimatedComponentCardState();
}

class _AnimatedComponentCardState extends State<AnimatedComponentCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: widget.isSelected ? 1.05 : 1.0,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AnimationUtils.easeOutQuart,
      ),
    );

    _bounceAnimation = AnimationUtils.createBounceAnimation(_bounceController);
  }

  @override
  void didUpdateWidget(AnimatedComponentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
        _bounceController.forward().then((_) => _bounceController.reverse());
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _bounceAnimation]),
      builder: (context, child) {
        final scale = _scaleAnimation.value * _bounceAnimation.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: InkWell(
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}

/// Fade-in slide animation for list items
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Offset slideBegin;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.slideBegin = const Offset(0, 0.2),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationUtils.normal,
      vsync: this,
    );

    _fadeAnimation = AnimationUtils.createFadeInAnimation(_controller);
    _slideAnimation = AnimationUtils.createSlideInAnimation(
      _controller,
      begin: widget.slideBegin,
    );

    // Add delay based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
