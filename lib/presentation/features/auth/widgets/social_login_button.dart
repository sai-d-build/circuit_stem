// lib/presentation/features/auth/widgets/social_login_button.dart
// Social Login Button Widget

import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String label;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
        backgroundColor: backgroundColor ?? theme.colorScheme.surface,
        foregroundColor: textColor ?? theme.colorScheme.onSurface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            // TODO: Replace with actual icon asset
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _getIconForLabel(label),
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    if (label.toLowerCase().contains('google')) {
      return Icons.g_mobiledata; // Placeholder for Google icon
    } else if (label.toLowerCase().contains('apple')) {
      return Icons.apple; // Apple icon
    } else if (label.toLowerCase().contains('facebook')) {
      return Icons.facebook; // Facebook icon
    } else if (label.toLowerCase().contains('twitter') || label.toLowerCase().contains('x')) {
      return Icons.alternate_email; // Twitter/X icon
    } else {
      return Icons.account_circle; // Generic social icon
    }
  }
}