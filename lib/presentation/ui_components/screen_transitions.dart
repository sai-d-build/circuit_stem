import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

enum TransitionType {
  fade,
  scale,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  neonPulse,
}

class ScreenTransition extends StatefulWidget {
  final Widget child;
  final TransitionType type;
  final Duration duration;
  final Curve curve;
  final bool reverse;

  const ScreenTransition({
    super.key,
    required this.child,
    this.type = TransitionType.fade,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.reverse = false,
  });

  @override
  State<ScreenTransition> createState() => _ScreenTransitionState();
}

class _ScreenTransitionState extends State<ScreenTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _setupAnimation();
    _controller.forward();
  }

  void _setupAnimation() {
    switch (widget.type) {
      case TransitionType.fade:
        _animation = Tween<double>(
          begin: widget.reverse ? 1.0 : 0.0,
          end: widget.reverse ? 0.0 : 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ));
        break;

      case TransitionType.scale:
        _animation = Tween<double>(
          begin: widget.reverse ? 1.0 : 0.8,
          end: widget.reverse ? 0.8 : 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ));
        break;

      case TransitionType.neonPulse:
        _animation = Tween<double>(
          begin: widget.reverse ? 1.0 : 0.0,
          end: widget.reverse ? 0.0 : 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ));
        break;

      default:
        _animation = Tween<double>(
          begin: widget.reverse ? 1.0 : 0.0,
          end: widget.reverse ? 0.0 : 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.type) {
          case TransitionType.fade:
            return Opacity(
              opacity: _animation.value,
              child: widget.child,
            );

          case TransitionType.scale:
            return Transform.scale(
              scale: _animation.value,
              child: widget.child,
            );

          case TransitionType.slideUp:
            return Transform.translate(
              offset: Offset(0, (1 - _animation.value) * 100),
              child: widget.child,
            );

          case TransitionType.slideDown:
            return Transform.translate(
              offset: Offset(0, (1 - _animation.value) * -100),
              child: widget.child,
            );

          case TransitionType.slideLeft:
            return Transform.translate(
              offset: Offset((1 - _animation.value) * 100, 0),
              child: widget.child,
            );

          case TransitionType.slideRight:
            return Transform.translate(
              offset: Offset((1 - _animation.value) * -100, 0),
              child: widget.child,
            );

          case TransitionType.neonPulse:
            final colors = Theme.of(context).extension<CircuitColorScheme>()!;
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: colors.neonPrimary
                        .withValues(alpha: _animation.value * 0.5),
                    blurRadius: 20.0 * _animation.value,
                    spreadRadius: 5.0 * _animation.value,
                  ),
                ],
              ),
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );
        }
      },
    );
  }
}

// Pre-configured transitions for common use cases
class FadeTransition extends StatelessWidget {
  final Widget child;
  final bool reverse;

  const FadeTransition({
    super.key,
    required this.child,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenTransition(
      type: TransitionType.fade,
      reverse: reverse,
      child: child,
    );
  }
}

class ScaleTransition extends StatelessWidget {
  final Widget child;
  final bool reverse;

  const ScaleTransition({
    super.key,
    required this.child,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenTransition(
      type: TransitionType.scale,
      reverse: reverse,
      child: child,
    );
  }
}

class NeonPulseTransition extends StatelessWidget {
  final Widget child;
  final bool reverse;

  const NeonPulseTransition({
    super.key,
    required this.child,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenTransition(
      type: TransitionType.neonPulse,
      reverse: reverse,
      child: child,
    );
  }
}

// Transition wrapper for route navigation
class TransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;

  TransitionRoute({
    required this.page,
    this.transitionType = TransitionType.fade,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScreenTransition(
              type: transitionType,
              child: child,
            );
          },
        );
}
