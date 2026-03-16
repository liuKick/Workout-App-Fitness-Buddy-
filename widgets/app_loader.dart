// lib/widgets/app_loader.dart
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loaderColor = color ?? theme.primaryColor;
    final loaderSize = size ?? 40.0;

    return Center(
      child: SizedBox(
        width: loaderSize,
        height: loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
          backgroundColor: theme.dividerColor,
        ),
      ),
    );
  }
}

// Optional: Full screen loader widget
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final Color? color;

  const FullScreenLoader({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;

    return Container(
      color: theme.scaffoldBackgroundColor.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLoader(color: color),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait...',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}