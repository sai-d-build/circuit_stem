import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/widgets/menu_button.dart';
import 'package:sparkcircuit/presentation/state/hud_state.dart';

// ✅ CLEAN ARCHITECTURE: HUD Service
class HudService {
  final dynamic hudNotifier;

  HudService(this.hudNotifier);

  void hideOverlay() {
    hudNotifier.hideOverlay();
  }
}

final hudServiceProvider = Provider.family<HudService, String>((ref, levelId) {
  final hudNotifier = ref.watch(hudStateProvider(levelId).notifier);
  return HudService(hudNotifier);
});

class PauseMenu extends ConsumerWidget {
  final String levelId;

  const PauseMenu({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final hudService = ref.watch(hudServiceProvider(levelId));
    
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: circuitColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: circuitColors.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: circuitColors.shadow.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pause_circle,
            size: 48,
            color: circuitColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Game Paused',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: circuitColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          MenuButton(
            text: 'Resume',
            icon: Icons.play_arrow,
            isPrimary: true,
            onPressed: () {
              hudService.hideOverlay();
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            text: 'Restart Level',
            icon: Icons.refresh,
            onPressed: () {
              _showRestartConfirmation(context, hudService);
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            text: 'Settings',
            icon: Icons.settings,
            onPressed: () {
              hudService.hideOverlay();
              context.go('/settings');
            },
          ),
          const SizedBox(height: 12),
          MenuButton(
            text: 'Main Menu',
            icon: Icons.home,
            onPressed: () {
              _showExitConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showRestartConfirmation(BuildContext context, HudService hudService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Level'),
        content: const Text('Are you sure you want to restart this level? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              hudService.hideOverlay();
              // Reset level logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Level restarted')),
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit to Main Menu'),
        content: const Text('Are you sure you want to exit? Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}