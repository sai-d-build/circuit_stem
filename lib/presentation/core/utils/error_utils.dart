import 'package:flutter/material.dart';
import 'feedback_utils.dart';

/// Error types for SparkCircuit
enum SparkErrorType {
  componentPlacement,
  componentSelection,
  simulation,
  network,
  validation,
  system,
  permission,
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Standardized error information
class SparkError {
  final SparkErrorType type;
  final ErrorSeverity severity;
  final String title;
  final String message;
  final String? suggestion;
  final String? actionLabel;
  final VoidCallback? action;
  final IconData icon;
  final Color? color;

  const SparkError({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.suggestion,
    this.actionLabel,
    this.action,
    required this.icon,
    this.color,
  });

  /// Predefined common errors
  static SparkError componentNotAvailable = SparkError(
    type: SparkErrorType.componentPlacement,
    severity: ErrorSeverity.medium,
    title: 'Component Not Available',
    message: 'This component is not available in your current inventory.',
    suggestion: 'Try selecting a different component or complete more levels to unlock it.',
    icon: Icons.inventory_2_outlined,
    color: Colors.orange,
  );

  static SparkError positionOccupied = SparkError(
    type: SparkErrorType.componentPlacement,
    severity: ErrorSeverity.low,
    title: 'Position Occupied',
    message: 'There\'s already a component at this position.',
    suggestion: 'Try placing the component in an empty grid cell.',
    icon: Icons.place_outlined,
    color: Colors.blue,
  );

  static SparkError simulationFailed = SparkError(
    type: SparkErrorType.simulation,
    severity: ErrorSeverity.high,
    title: 'Circuit Simulation Failed',
    message: 'Unable to simulate the circuit. Please check your connections.',
    suggestion: 'Ensure all components are properly connected and try again.',
    actionLabel: 'Retry Simulation',
    icon: Icons.flash_off_outlined,
    color: Colors.red,
  );

  static SparkError networkError = SparkError(
    type: SparkErrorType.network,
    severity: ErrorSeverity.medium,
    title: 'Connection Error',
    message: 'Unable to connect to the server. Please check your internet connection.',
    suggestion: 'Check your network settings and try again.',
    actionLabel: 'Retry',
    icon: Icons.wifi_off_outlined,
    color: Colors.orange,
  );

  static SparkError invalidCircuit = SparkError(
    type: SparkErrorType.validation,
    severity: ErrorSeverity.medium,
    title: 'Invalid Circuit',
    message: 'Your circuit configuration is not valid.',
    suggestion: 'Check that all components are properly connected and powered.',
    icon: Icons.error_outline,
    color: Colors.red,
  );
}

/// Error handling utilities
class ErrorUtils {
  /// Show error using SnackBar
  static void showSnackBarError(
    BuildContext context,
    SparkError error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error.icon,
              color: error.color ?? theme.colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: error.color ?? theme.colorScheme.onError,
                    ),
                  ),
                  if (error.message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      error.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: error.color?.withValues(alpha: 0.9) ?? theme.colorScheme.onError,
                      ),
                    ),
                  ],
                  if (error.suggestion != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      error.suggestion!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: error.color?.withValues(alpha: 0.7) ?? theme.colorScheme.onError.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: error.color?.withValues(alpha: 0.1) ?? theme.colorScheme.errorContainer,
        duration: duration,
        action: error.action != null && error.actionLabel != null
            ? SnackBarAction(
                label: error.actionLabel!,
                textColor: error.color ?? theme.colorScheme.onError,
                onPressed: () {
                  error.action!();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Provide haptic feedback for errors
    FeedbackUtils.provideHapticFeedback(
      error.severity == ErrorSeverity.critical
          ? FeedbackType.error
          : FeedbackType.medium,
    );
  }

  /// Show error using Dialog
  static void showDialogError(
    BuildContext context,
    SparkError error, {
    bool barrierDismissible = true,
  }) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        icon: Icon(
          error.icon,
          size: 48,
          color: error.color ?? theme.colorScheme.error,
        ),
        title: Text(
          error.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: error.color ?? theme.colorScheme.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error.message,
              style: theme.textTheme.bodyMedium,
            ),
            if (error.suggestion != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error.suggestion!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (error.action != null && error.actionLabel != null)
            TextButton(
              onPressed: () {
                error.action!();
                Navigator.of(context).pop();
              },
              child: Text(error.actionLabel!),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    // Provide haptic feedback
    FeedbackUtils.provideHapticFeedback(FeedbackType.medium);
  }

  /// Show error using Bottom Sheet (for mobile)
  static void showBottomSheetError(
    BuildContext context,
    SparkError error,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error.icon,
              size: 48,
              color: error.color ?? theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: error.color ?? theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (error.suggestion != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  error.suggestion!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (error.action != null && error.actionLabel != null)
              FilledButton(
                onPressed: () {
                  error.action!();
                  Navigator.of(context).pop();
                },
                child: Text(error.actionLabel!),
              ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );

    // Provide haptic feedback
    FeedbackUtils.provideHapticFeedback(FeedbackType.medium);
  }

  /// Automatically choose the best error display method based on screen size
  static void showError(
    BuildContext context,
    SparkError error, {
    ErrorDisplayMethod? method,
  }) {
    final methodToUse = method ?? _getBestDisplayMethod(context, error);

    switch (methodToUse) {
      case ErrorDisplayMethod.snackBar:
        showSnackBarError(context, error);
        break;
      case ErrorDisplayMethod.dialog:
        showDialogError(context, error);
        break;
      case ErrorDisplayMethod.bottomSheet:
        showBottomSheetError(context, error);
        break;
    }
  }

  static ErrorDisplayMethod _getBestDisplayMethod(
    BuildContext context,
    SparkError error,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Use bottom sheet for mobile, dialog for desktop
    if (isMobile) {
      return ErrorDisplayMethod.bottomSheet;
    }

    // Use dialog for high severity errors
    if (error.severity == ErrorSeverity.high || error.severity == ErrorSeverity.critical) {
      return ErrorDisplayMethod.dialog;
    }

    // Use snackbar for low/medium severity
    return ErrorDisplayMethod.snackBar;
  }

  /// Create error from exception
  static SparkError fromException(
    dynamic exception, {
    SparkErrorType type = SparkErrorType.system,
  }) {
    if (exception is SparkError) {
      return exception;
    }

    return SparkError(
      type: type,
      severity: ErrorSeverity.medium,
      title: 'Something went wrong',
      message: exception.toString(),
      suggestion: 'Please try again or contact support if the problem persists.',
      icon: Icons.error_outline,
      color: Colors.red,
    );
  }
}

/// Error display methods
enum ErrorDisplayMethod {
  snackBar,
  dialog,
  bottomSheet,
}

/// Success message utilities
class SuccessUtils {
  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Provide success haptic feedback
    FeedbackUtils.provideHapticFeedback(FeedbackType.success);
  }
}

/// Warning message utilities
class WarningUtils {
  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: theme.colorScheme.tertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Provide warning haptic feedback
    FeedbackUtils.provideHapticFeedback(FeedbackType.medium);
  }
}