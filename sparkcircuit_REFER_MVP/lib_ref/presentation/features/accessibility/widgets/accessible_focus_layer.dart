import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      // Announce focus change to screen readers
      SemanticsService.announce(
        'Circuit building area focused',
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Semantics(
        label: 'Interactive circuit building canvas',
        hint: 'Use arrow keys to navigate, enter to select components',
        child: widget.child,
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.arrowRight:
          // Handle navigation
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          // Handle selection
          return KeyEventResult.handled;
        case LogicalKeyboardKey.escape:
          // Handle cancellation
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}