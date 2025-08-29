import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlowEffect extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final bool isGlowing;
  final Duration duration;
  final Curve curve;
  final double minOpacity;
  final double maxOpacity;

  const GlowEffect({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowRadius = 10.0,
    this.isGlowing = true,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOut,
    this.minOpacity = 0.3,
    this.maxOpacity = 0.8,
  });

  @override
  State<GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends State<GlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.isGlowing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGlowing != oldWidget.isGlowing) {
      if (widget.isGlowing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
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
        return Container(
          decoration: BoxDecoration(
            boxShadow: widget.isGlowing
                ? [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: _animation.value),
                      blurRadius: widget.glowRadius,
                      spreadRadius: widget.glowRadius * 0.3,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class PulseEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool isPulsing;

  const PulseEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 1.0,
    this.maxScale = 1.1,
    this.isPulsing = true,
  });

  @override
  State<PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isPulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
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
        return Transform.scale(
          scale: widget.isPulsing ? _animation.value : 1.0,
          child: widget.child,
        );
      },
    );
  }
}

class ShakeEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double shakeIntensity;
  final bool isShaking;
  final int shakeCount;

  const ShakeEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.shakeIntensity = 5.0,
    this.isShaking = false,
    this.shakeCount = 3,
  });

  @override
  State<ShakeEffect> createState() => _ShakeEffectState();
}

class _ShakeEffectState extends State<ShakeEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(ShakeEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _startShake();
    }
  }

  void _startShake() {
    _controller.reset();
    _controller.forward();
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
        return Transform.translate(
          offset: widget.isShaking
              ? Offset(
                  _animation.value * widget.shakeIntensity * math.sin(_animation.value * math.pi * widget.shakeCount),
                  0,
                )
              : Offset.zero,
          child: widget.child,
        );
      },
    );
  }
}

class HighlightEffect extends StatefulWidget {
  final Widget child;
  final Color highlightColor;
  final Duration duration;
  final bool isHighlighted;
  final double borderWidth;
  final BorderRadius? borderRadius;

  const HighlightEffect({
    super.key,
    required this.child,
    required this.highlightColor,
    this.duration = const Duration(milliseconds: 300),
    this.isHighlighted = false,
    this.borderWidth = 2.0,
    this.borderRadius,
  });

  @override
  State<HighlightEffect> createState() => _HighlightEffectState();
}

class _HighlightEffectState extends State<HighlightEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isHighlighted) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(HighlightEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.highlightColor.withValues(alpha: _animation.value),
              width: widget.borderWidth,
            ),
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.highlightColor.withValues(alpha: _animation.value * 0.3),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class ElectricCurrentEffect extends StatefulWidget {
  final Widget child;
  final Color currentColor;
  final Duration duration;
  final bool isFlowing;
  final double strokeWidth;

  const ElectricCurrentEffect({
    super.key,
    required this.child,
    required this.currentColor,
    this.duration = const Duration(milliseconds: 800),
    this.isFlowing = true,
    this.strokeWidth = 3.0,
  });

  @override
  State<ElectricCurrentEffect> createState() => _ElectricCurrentEffectState();
}

class _ElectricCurrentEffectState extends State<ElectricCurrentEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    if (widget.isFlowing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ElectricCurrentEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlowing != oldWidget.isFlowing) {
      if (widget.isFlowing) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
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
        return CustomPaint(
          painter: ElectricCurrentPainter(
            progress: _animation.value,
            currentColor: widget.currentColor,
            strokeWidth: widget.strokeWidth,
            isFlowing: widget.isFlowing,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class ElectricCurrentPainter extends CustomPainter {
  final double progress;
  final Color currentColor;
  final double strokeWidth;
  final bool isFlowing;

  ElectricCurrentPainter({
    required this.progress,
    required this.currentColor,
    required this.strokeWidth,
    required this.isFlowing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isFlowing) return;

    final paint = Paint()
      ..color = currentColor.withValues(alpha: 0.8)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create flowing current effect with dashed lines
    const dashLength = 10.0;
    const gapLength = 5.0;
    final totalLength = size.width;
    final offset = progress * (dashLength + gapLength);

    for (double x = -offset; x < totalLength; x += dashLength + gapLength) {
      final startX = math.max(0.0, x);
      final endX = math.min(totalLength, x + dashLength);

      if (startX < endX) {
        canvas.drawLine(
          Offset(startX, size.height / 2),
          Offset(endX, size.height / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ElectricCurrentPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.currentColor != currentColor ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.isFlowing != isFlowing;
  }
}