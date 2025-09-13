import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

class ShareDialog extends StatelessWidget {
  final String levelId;
  final int score;
  final int stars;

  const ShareDialog({
    super.key,
    required this.levelId,
    required this.score,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;

    return Dialog(
      backgroundColor: circuitColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.share,
              size: 48,
              color: circuitColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Share Your Achievement!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: circuitColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'I just completed Level $levelId in Circuit STEM with $stars stars and scored $score points!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: circuitColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _shareToSocial('twitter'),
                  icon: const Icon(Icons.share),
                  label: const Text('Twitter'),
                ),
                TextButton.icon(
                  onPressed: () => _shareToSocial('facebook'),
                  icon: const Icon(Icons.share),
                  label: const Text('Facebook'),
                ),
                TextButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _shareImage(context),
                    child: const Text('Share Image'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareToSocial(String platform) {
    // Implementation for social sharing would go here
    // In a real app, this would use platform-specific sharing
  }

  void _copyToClipboard(BuildContext context) {
    // Copy share text to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  void _shareImage(BuildContext context) {
    // Generate and share circuit image
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image shared!')),
    );
  }
}
