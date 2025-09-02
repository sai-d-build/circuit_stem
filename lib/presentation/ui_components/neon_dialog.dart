import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/theme/app_theme.dart';

class NeonDialog extends StatefulWidget {
  final String? title;
  final Widget content;
  final List<Widget> actions;
  final double? width;
  final double? height;

  const NeonDialog({
    super.key,
    this.title,
    required this.content,
    this.actions = const [],
    this.width,
    this.height,
  });

  @override
  State<NeonDialog> createState() => _NeonDialogState();
}

class _NeonDialogState extends State<NeonDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
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
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: widget.width ?? MediaQuery.of(context).size.width * 0.8,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: colors.surface.withOpacity(0.95),
                border: Border.all(
                  color: colors.neonPrimary.withOpacity(0.8),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.neonPrimary.withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 20.0,
                    spreadRadius: 4.0,
                  ),
                  BoxShadow(
                    color: colors.neonAccent.withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 30.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14.0),
                          topRight: Radius.circular(14.0),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            colors.neonPrimary.withOpacity(0.2),
                            colors.neonAccent.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.title!,
                          style: textTheme.headlineSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              BoxShadow(
                                color: colors.neonPrimary.withOpacity(0.5),
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      color: colors.neonPrimary.withOpacity(0.3),
                      thickness: 1.0,
                      height: 1.0,
                    ),
                  ],
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: widget.content,
                    ),
                  ),
                  if (widget.actions.isNotEmpty) ...[
                    Divider(
                      color: colors.neonPrimary.withOpacity(0.3),
                      thickness: 1.0,
                      height: 1.0,
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: widget.actions,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}