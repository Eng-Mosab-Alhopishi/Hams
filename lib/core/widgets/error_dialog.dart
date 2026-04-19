import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/glass_container.dart';
import '../errors/hams_error.dart';

class ErrorDialog extends StatelessWidget {
  final HamsError error;
  final VoidCallback onAction;
  final String actionLabel;

  const ErrorDialog({
    super.key,
    required this.error,
    required this.onAction,
    this.actionLabel = 'RETRY',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorRed,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              error.translate('en'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error.translate('ar'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, HamsError error, VoidCallback onAction, {String actionLabel = 'RETRY'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        error: error,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }
}
