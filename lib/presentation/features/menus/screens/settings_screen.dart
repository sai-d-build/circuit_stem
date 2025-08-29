import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/widgets/responsive_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _animationsEnabled = true;
  bool _hintsEnabled = true;
  bool _highContrastMode = false;
  double _gameSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Audio',
            children: [
              _buildSwitchTile(
                title: 'Sound Effects',
                subtitle: 'Play sounds during gameplay',
                value: _soundEnabled,
                onChanged: (value) => setState(() => _soundEnabled = value),
                icon: Icons.volume_up,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Gameplay',
            children: [
              _buildSwitchTile(
                title: 'Animations',
                subtitle: 'Enable visual animations and effects',
                value: _animationsEnabled,
                onChanged: (value) => setState(() => _animationsEnabled = value),
                icon: Icons.animation,
              ),
              _buildSwitchTile(
                title: 'Hints',
                subtitle: 'Show helpful hints during levels',
                value: _hintsEnabled,
                onChanged: (value) => setState(() => _hintsEnabled = value),
                icon: Icons.lightbulb_outline,
              ),
              _buildSliderTile(
                title: 'Game Speed',
                subtitle: 'Adjust simulation speed',
                value: _gameSpeed,
                onChanged: (value) => setState(() => _gameSpeed = value),
                min: 0.5,
                max: 2.0,
                divisions: 6,
                icon: Icons.speed,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Accessibility',
            children: [
              _buildSwitchTile(
                title: 'High Contrast Mode',
                subtitle: 'Increase contrast for better visibility',
                value: _highContrastMode,
                onChanged: (value) => setState(() => _highContrastMode = value),
                icon: Icons.contrast,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Data',
            children: [
              _buildActionTile(
                title: 'Reset Progress',
                subtitle: 'Clear all level progress and scores',
                onTap: _showResetConfirmation,
                icon: Icons.refresh,
                isDestructive: true,
              ),
              _buildActionTile(
                title: 'Export Data',
                subtitle: 'Export your progress and settings',
                onTap: _exportData,
                icon: Icons.download,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: circuitColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        icon,
        color: circuitColors.onSurface.withValues(alpha: 0.7),
      ),
      activeColor: circuitColors.primary,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required int divisions,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    
    return ListTile(
      leading: Icon(
        icon,
        color: circuitColors.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: divisions,
            label: '${value.toStringAsFixed(1)}x',
            activeColor: circuitColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? circuitColors.error
            : circuitColors.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(
        title,
        style: isDestructive
            ? TextStyle(color: circuitColors.error)
            : null,
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'This will permanently delete all your level progress, scores, and achievements. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetProgress();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    // Implementation for resetting progress
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress reset successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportData() {
    // Implementation for exporting data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data exported successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}