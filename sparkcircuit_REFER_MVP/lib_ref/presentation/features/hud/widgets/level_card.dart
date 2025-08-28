import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/animations/glow_effect.dart';

class LevelCard extends StatefulWidget {
  final String levelId;
  final String title;
  final String description;
  final int difficulty;
  final bool isCompleted;
  final int stars;
  final bool isLocked;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.levelId,
    required this.title,
    required this.description,
    required this.difficulty,
    this.isCompleted = false,
    this.stars = 0,
    this.isLocked = false,
    this.onTap,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard>
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
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final canPlay = !widget.isLocked && widget.onTap != null;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlowEffect(
            glowColor: circuitColors.glowEffect,
            glowRadius: 12,
            isGlowing: canPlay && _glowAnimation.value > 0.5,
            child: Card(
              elevation: widget.isCompleted ? 6 : 4,
              child: InkWell(
                onTap: canPlay ? widget.onTap : null,
                onTapDown: canPlay ? (_) => _animationController.forward() : null,
                onTapUp: canPlay ? (_) => _animationController.reverse() : null,
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _getCardGradient(circuitColors),
                    border: widget.isCompleted
                        ? Border.all(
                            color: circuitColors.secondary.withValues(alpha: 0.5),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme, circuitColors),
                      const Spacer(),
                      _buildTitle(theme, circuitColors),
                      const SizedBox(height: 8),
                      _buildDescription(theme, circuitColors),
                      const Spacer(),
                      _buildFooter(theme, circuitColors),
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

  LinearGradient _getCardGradient(CircuitColorScheme circuitColors) {
    if (widget.isLocked) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          circuitColors.surface.withValues(alpha: 0.5),
          circuitColors.surfaceContainer.withValues(alpha: 0.5),
        ],
      );
    } else if (widget.isCompleted) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          circuitColors.secondary.withValues(alpha: 0.1),
          circuitColors.surface,
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          circuitColors.primary.withValues(alpha: 0.05),
          circuitColors.surface,
        ],
      );
    }
  }

  Widget _buildHeader(ThemeData theme, CircuitColorScheme circuitColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDifficultyIndicator(circuitColors),
        if (widget.isLocked)
          Icon(
            Icons.lock,
            color: circuitColors.onSurface.withValues(alpha: 0.5),
            size: 20,
          )
        else if (widget.isCompleted)
          _buildStarsIndicator(circuitColors)
        else
          Icon(
            Icons.play_circle_outline,
            color: circuitColors.primary,
            size: 24,
          ),
      ],
    );
  }

  Widget _buildDifficultyIndicator(CircuitColorScheme circuitColors) {
    final difficultyColor = widget.difficulty <= 2
        ? circuitColors.secondary
        : widget.difficulty <= 4
            ? circuitColors.tertiary
            : circuitColors.error;

    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            index < widget.difficulty ? Icons.circle : Icons.circle_outlined,
            color: index < widget.difficulty
                ? difficultyColor
                : circuitColors.onSurface.withValues(alpha: 0.2),
            size: 8,
          ),
        );
      }),
    );
  }

  Widget _buildStarsIndicator(CircuitColorScheme circuitColors) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Icon(
            index < widget.stars ? Icons.star : Icons.star_outline,
            color: index < widget.stars
                ? Colors.amber
                : circuitColors.onSurface.withValues(alpha: 0.3),
            size: 16,
          ),
        );
      }),
    );
  }

  Widget _buildTitle(ThemeData theme, CircuitColorScheme circuitColors) {
    return Text(
      widget.title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: widget.isLocked
            ? circuitColors.onSurface.withValues(alpha: 0.5)
            : circuitColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(ThemeData theme, CircuitColorScheme circuitColors) {
    return Text(
      widget.description,
      style: theme.textTheme.bodySmall?.copyWith(
        color: widget.isLocked
            ? circuitColors.onSurfaceVariant.withValues(alpha: 0.5)
            : circuitColors.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(ThemeData theme, CircuitColorScheme circuitColors) {
    return Row(
      children: [
        Text(
          'Level ${widget.levelId}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: widget.isLocked
                ? circuitColors.onSurfaceVariant.withValues(alpha: 0.5)
                : circuitColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (widget.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: circuitColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: circuitColors.secondary.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              'Completed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: circuitColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}