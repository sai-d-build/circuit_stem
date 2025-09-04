import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// Loading state utilities for SparkCircuit
class LoadingUtils {
  /// Creates a shimmer effect for skeleton loading
  static Widget buildShimmerEffect({
    required BuildContext context,
    required double width,
    required double height,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: ShimmerLoading(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Creates a skeleton for component palette items
  static Widget buildComponentSkeleton(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final itemWidth = isMobile ? 80.0 : 100.0;
    final itemHeight = isMobile ? 100.0 : 120.0;

    return Container(
      width: itemWidth,
      height: itemHeight,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon skeleton
          buildShimmerEffect(
            context: context,
            width: isMobile ? 24 : 32,
            height: isMobile ? 24 : 32,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 8),
          // Text skeleton
          buildShimmerEffect(
            context: context,
            width: itemWidth * 0.8,
            height: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          // Count skeleton
          buildShimmerEffect(
            context: context,
            width: itemWidth * 0.4,
            height: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  /// Creates a skeleton for the game canvas
  static Widget buildCanvasSkeleton(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          // Grid background skeleton
          Positioned.fill(
            child: ShimmerLoading(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          // Component placeholders
          ...List.generate(6, (index) {
            final left = (index % 3) * 100.0 + 50;
            final top = (index ~/ 3) * 100.0 + 50;
            return Positioned(
              left: left,
              top: top,
              child: buildShimmerEffect(
                context: context,
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Creates a skeleton for the HUD
  static Widget buildHudSkeleton(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: isMobile ? 60 : 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level title skeleton
          buildShimmerEffect(
            context: context,
            width: 120,
            height: 20,
            borderRadius: BorderRadius.circular(4),
          ),
          // Timer skeleton
          Row(
            children: [
              buildShimmerEffect(
                context: context,
                width: 16,
                height: 16,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 8),
              buildShimmerEffect(
                context: context,
                width: 60,
                height: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading effect widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _shimmerAnimation = AnimationUtils.createShimmerAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final baseColor = widget.baseColor ??
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);
            final highlightColor = widget.highlightColor ??
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ],
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Progress indicator with custom styling
class SparkProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double strokeWidth;
  final String? label;

  const SparkProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.strokeWidth = 4.0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: value,
            backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ?? theme.colorScheme.primary,
            ),
            strokeWidth: strokeWidth,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Loading overlay for full-screen loading states
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final bool dismissible;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            child: Center(
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SparkProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton screen for game loading
class GameSkeletonScreen extends StatelessWidget {
  const GameSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: LoadingUtils.buildShimmerEffect(
          context: context,
          width: 120,
          height: 24,
          margin: const EdgeInsets.symmetric(vertical: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // HUD skeleton
          LoadingUtils.buildHudSkeleton(context),
          // Canvas skeleton
          Expanded(
            child: LoadingUtils.buildCanvasSkeleton(context),
          ),
          // Palette skeleton
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: List.generate(
                5,
                (index) => LoadingUtils.buildComponentSkeleton(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hook for managing loading states
class LoadingState {
  bool _isLoading = false;
  String? _message;

  bool get isLoading => _isLoading;
  String? get message => _message;

  void startLoading([String? message]) {
    _isLoading = true;
    _message = message;
  }

  void stopLoading() {
    _isLoading = false;
    _message = null;
  }

  void updateMessage(String message) {
    _message = message;
  }
}