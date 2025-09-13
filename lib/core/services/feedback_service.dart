import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FeedbackType {
  success,
  error,
  warning,
  info,
}

class FeedbackMessage {
  final String message;
  final FeedbackType type;
  final Duration duration;

  const FeedbackMessage({
    required this.message,
    this.type = FeedbackType.info,
    this.duration = const Duration(seconds: 3),
  });
}

final feedbackServiceProvider =
    Provider<FeedbackService>((ref) => FeedbackService());

class FeedbackService {
  void showSnackBar(BuildContext context, FeedbackMessage message) {
    final color = _getColorForType(message.type);
    final icon = _getIconForType(message.type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: message.duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void showSuccess(BuildContext context, String message) {
    showSnackBar(
        context,
        FeedbackMessage(
          message: message,
          type: FeedbackType.success,
        ));
  }

  void showError(BuildContext context, String message) {
    showSnackBar(
        context,
        FeedbackMessage(
          message: message,
          type: FeedbackType.error,
          duration: const Duration(seconds: 5),
        ));
  }

  void showWarning(BuildContext context, String message) {
    showSnackBar(
        context,
        FeedbackMessage(
          message: message,
          type: FeedbackType.warning,
        ));
  }

  void showInfo(BuildContext context, String message) {
    showSnackBar(
        context,
        FeedbackMessage(
          message: message,
          type: FeedbackType.info,
        ));
  }

  Color _getColorForType(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return Colors.green;
      case FeedbackType.error:
        return Colors.red;
      case FeedbackType.warning:
        return Colors.orange;
      case FeedbackType.info:
        return Colors.blue;
    }
  }

  IconData _getIconForType(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
    }
  }
}
