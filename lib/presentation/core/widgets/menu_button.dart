import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

import '../../core/utils/feedback_utils.dart';

class MenuButton extends ConsumerStatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isEnabled;
  final double? width;
  final double? height;

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isEnabled = true,
    this.width,
    this.height,
  });

  @override
  ConsumerState<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends ConsumerState<MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled) {
      _animationController.reverse();
    }
  }

  void _playButtonSound() {
    FeedbackUtils.provideSoundFeedback(ref, SoundType.tap);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width ?? 280,
            height: widget.height ?? 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.isPrimary
                      ? circuitColors.glowEffect
                          .withValues(alpha: 0.3 + (0.4 * _glowAnimation.value))
                      : theme.colorScheme.shadow.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8 + (8 * _glowAnimation.value),
                  spreadRadius: widget.isPrimary ? 2 * _glowAnimation.value : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isEnabled
                    ? () {
                        _playButtonSound();
                        widget.onPressed();
                      }
                    : null,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: widget.isPrimary
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              circuitColors.primary,
                              circuitColors.primary.withValues(alpha: 0.8),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              circuitColors.surfaceContainer,
                              circuitColors.surfaceContainer
                                  .withValues(alpha: 0.9),
                            ],
                          ),
                    border: Border.all(
                      color: widget.isPrimary
                          ? circuitColors.primary.withValues(alpha: 0.3)
                          : circuitColors.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.isPrimary
                              ? circuitColors.onPrimary
                              : circuitColors.onSurface,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.text,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: widget.isPrimary
                              ? circuitColors.onPrimary
                              : circuitColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
