import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class NeonDropdown<T> extends StatefulWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;

  const NeonDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
  });

  @override
  State<NeonDropdown<T>> createState() => _NeonDropdownState<T>();
}

class _NeonDropdownState<T> extends State<NeonDropdown<T>> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CircuitColorScheme>()!;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  shadows: [
                    BoxShadow(
                      color: colors.neonPrimary.withOpacity(0.3),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: colors.neonPrimary.withOpacity(0.6),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.neonPrimary.withOpacity(_glowAnimation.value * 0.4),
                    blurRadius: 12.0,
                    spreadRadius: 1.0,
                  ),
                ],
                color: colors.surface.withOpacity(0.1),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: colors.surface,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: widget.value,
                    items: widget.items,
                    onChanged: widget.onChanged,
                    hint: widget.hint != null
                        ? Text(
                            widget.hint!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          )
                        : null,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                    ),
                    dropdownColor: colors.surface,
                    icon: AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: colors.neonPrimary,
                        size: 24,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    elevation: 8,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}