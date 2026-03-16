// lib/features/home/widgets/today_progress_card.dart
import 'package:flutter/material.dart';

class TodayProgressCard extends StatelessWidget {
  final int points;
  final int activeEnergy;
  final int activeEnergyGoal;
  final int exerciseTime;
  final int exerciseTimeGoal;
  final int caloriesConsumed;      // replaces dailySteps
  final int caloriesGoal;          // replaces dailyStepsGoal
  final VoidCallback onTap;

  const TodayProgressCard({
    super.key,
    required this.points,
    required this.activeEnergy,
    required this.activeEnergyGoal,
    required this.exerciseTime,
    required this.exerciseTimeGoal,
    required this.caloriesConsumed,
    required this.caloriesGoal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with points
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TODAY'S PROGRESS",
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$points pts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: theme.textTheme.bodySmall?.color,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Active Energy
            _buildProgressRow(
              context,
              icon: Icons.local_fire_department,
              color: Colors.orange,
              label: 'Active Energy',
              value: activeEnergy,
              goal: activeEnergyGoal,
              unit: 'kcal',
            ),
            const SizedBox(height: 16),
            
            // Exercise Time
            _buildProgressRow(
              context,
              icon: Icons.timer,
              color: Colors.green,
              label: 'Exercise Time',
              value: exerciseTime,
              goal: exerciseTimeGoal,
              unit: 'min',
            ),
            const SizedBox(height: 16),
            
            // Calories Consumed (replaces Daily Steps)
            _buildProgressRow(
              context,
              icon: Icons.restaurant,
              color: Colors.red,
              label: 'Calories',
              value: caloriesConsumed,
              goal: caloriesGoal,
              unit: 'kcal',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required int value,
    required int goal,
    required String unit,
  }) {
    final theme = Theme.of(context);
    final double progress = (value / goal).clamp(0.0, 1.0);

    return Row(
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label and value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '$value${unit.isNotEmpty ? ' $unit' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Progress bar
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}