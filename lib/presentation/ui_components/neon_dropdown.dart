import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

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

class _NeonDropdownState<T> extends State<NeonDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  final bool _isOpen = false;

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
    final colors = Theme.of(context).extension<CircuitColorScheme>() ??
        const CircuitColorScheme(
          primary: Color(0xFF1E88E5),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFE3F2FD),
          onPrimaryContainer: Color(0xFF0D47A1),
          secondary: Color(0xFF43A047),
          onSecondary: Color(0xFFFFFFFF),
          tertiary: Color(0xFFFF8F00),
          onTertiary: Color(0xFFFFFFFF),
          error: Color(0xFFD32F2F),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFFFEBEE),
          onErrorContainer: Color(0xFFB71C1C),
          surface: Color(0xFFFAFAFA),
          onSurface: Color(0xFF1C1C1C),
          surfaceContainer: Color(0xFFEFEFEF),
          onSurfaceVariant: Color(0xFF424242),
          shadow: Color(0xFF000000),
          outline: Color(0xFFBDBDBD),
          wireActive: Color(0xFF00E676),
          wireInactive: Color(0xFF616161),
          componentBase: Color(0xFF2196F3),
          gridLine: Color(0xFFE0E0E0),
          glowEffect: Color(0xFF00E5FF),
          neonPrimary: Color(0xFF00FFFF),
          neonAccent: Color(0xFFFF00FF),
          errorGlow: Color(0xFFFF0040),
          energyPulse: Color(0xFF39FF14),
          highlightAccent: Color(0xFFFFFF00),
        );
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
                      color: colors.neonPrimary.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.neonPrimary.withValues(alpha: 0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.neonPrimary
                        .withValues(alpha: _glowAnimation.value * 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
                color: colors.surface.withValues(alpha: 0.1),
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
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          )
                        : null,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                    borderRadius: BorderRadius.circular(8),
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
