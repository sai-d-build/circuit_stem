import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/presentation/core/animations/glow_effect.dart';

class ComponentWidget extends StatefulWidget {
  final ComponentDefinition component;
  final ComponentInventory? inventory;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDragStart;

  const ComponentWidget({
    super.key,
    required this.component,
    required this.inventory,
    required this.isSelected,
    required this.onTap,
    required this.onDragStart,
  });

  @override
  State<ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<ComponentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
    final canUse = widget.inventory?.canUse ?? false;
    final isExhausted = widget.inventory?.isExhausted ?? false;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GlowEffect(
            glowColor: circuitColors.glowEffect,
            glowRadius: 8,
            isGlowing: widget.isSelected && canUse,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canUse ? widget.onTap : null,
                onTapDown: canUse ? (_) => _animationController.forward() : null,
                onTapUp: canUse ? (_) => _animationController.reverse() : null,
                onTapCancel: () => _animationController.reverse(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(circuitColors, canUse, isExhausted),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isSelected && canUse
                          ? circuitColors.primary
                          : circuitColors.outline.withValues(alpha: 0.3),
                      width: widget.isSelected && canUse ? 2 : 1,
                    ),
                    boxShadow: widget.isSelected && canUse
                        ? [
                            BoxShadow(
                              color: circuitColors.primary.withValues(alpha: 0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      _buildIcon(circuitColors, canUse, isExhausted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfo(theme, circuitColors, canUse, isExhausted),
                      ),
                      _buildInventoryIndicator(theme, circuitColors, canUse),
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

  Color _getBackgroundColor(
    CircuitColorScheme circuitColors,
    bool canUse,
    bool isExhausted,
  ) {
    if (isExhausted) {
      return circuitColors.surface.withValues(alpha: 0.5);
    } else if (widget.isSelected && canUse) {
      return circuitColors.primaryContainer.withValues(alpha: 0.2);
    } else {
      return circuitColors.surface.withValues(alpha: 0.9);
    }
  }

  Widget _buildIcon(
    CircuitColorScheme circuitColors,
    bool canUse,
    bool isExhausted,
  ) {
    final iconColor = isExhausted
        ? circuitColors.onSurface.withValues(alpha: 0.3)
        : canUse
            ? circuitColors.primary
            : circuitColors.onSurfaceVariant;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isExhausted
            ? circuitColors.surfaceContainer.withValues(alpha: 0.3)
            : canUse
                ? circuitColors.primary.withValues(alpha: 0.1)
                : circuitColors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: _getComponentIcon(widget.component.type, iconColor),
      ),
    );
  }

  Widget _buildInfo(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    bool canUse,
    bool isExhausted,
  ) {
    final textColor = isExhausted
        ? circuitColors.onSurface.withValues(alpha: 0.4)
        : circuitColors.onSurface;

    final subtitleColor = isExhausted
        ? circuitColors.onSurfaceVariant.withValues(alpha: 0.4)
        : circuitColors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.component.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.component.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: subtitleColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.component.cost > 1) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.stars,
                size: 12,
                color: subtitleColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.component.cost} cost',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInventoryIndicator(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    bool canUse,
  ) {
    final inventory = widget.inventory;
    if (inventory == null) return const SizedBox.shrink();

    final indicatorColor = inventory.isExhausted
        ? circuitColors.error
        : inventory.available <= 2
            ? circuitColors.tertiary
            : circuitColors.secondary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: indicatorColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: indicatorColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            '${inventory.available}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (inventory.total > inventory.available) ...[
          const SizedBox(height: 4),
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: circuitColors.outline.withValues(alpha: 0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: inventory.usagePercentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: indicatorColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Icon _getComponentIcon(String componentType, Color color) {
    switch (componentType) {
      case 'battery':
        return Icon(Icons.battery_full, color: color, size: 20);
      case 'resistor':
        return Icon(Icons.linear_scale, color: color, size: 20);
      case 'led':
        return Icon(Icons.lightbulb, color: color, size: 20);
      case 'wire':
        return Icon(Icons.horizontal_rule, color: color, size: 20);
      case 'switch':
        return Icon(Icons.power, color: color, size: 20);
      case 'capacitor':
        return Icon(Icons.battery_charging_full, color: color, size: 20);
      case 'inductor':
        return Icon(Icons.settings_ethernet, color: color, size: 20);
      case 'voltmeter':
        return Icon(Icons.speed, color: color, size: 20);
      case 'ammeter':
        return Icon(Icons.electric_bolt, color: color, size: 20);
      case 'multimeter':
        return Icon(Icons.dashboard, color: color, size: 20);
      default:
        return Icon(Icons.electrical_services, color: color, size: 20);
    }
  }
}