import 'package:flutter/material.dart';

/// Accessibility layer for keyboard/screen reader navigation
class AccessibleFocusLayer extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const AccessibleFocusLayer({
    super.key,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<AccessibleFocusLayer> createState() => _AccessibleFocusLayerState();
}

class _AccessibleFocusLayerState extends State<AccessibleFocusLayer> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) {
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // TODO: Implement screen reader announcement when SemanticsService is available
      // For now, just provide semantic information through the widget tree
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    return Focus(
      focusNode: _focusNode,
      child: Semantics(
        label: 'Interactive circuit building canvas',
        hint: 'Use mouse or touch to interact with circuit components',
        child: widget.child,
      ),
    );
  }
}