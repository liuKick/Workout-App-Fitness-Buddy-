// lib/features/onboarding/widgets/selection_card.dart
import 'package:flutter/material.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }
}