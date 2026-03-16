// lib/features/onboarding/screens/workout_duration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/selection_card.dart';
import '../../../widgets/app_button.dart';

class WorkoutDurationScreen extends StatefulWidget {
  const WorkoutDurationScreen({super.key});

  @override
  State<WorkoutDurationScreen> createState() => _WorkoutDurationScreenState();
}

class _WorkoutDurationScreenState extends State<WorkoutDurationScreen> {
  String? _selectedDuration;

  final List<String> _durations = [
    'Less than 20 minutes',
    '20–30 minutes',
    '30–45 minutes',
    '45–60 minutes',
    '60–75 minutes',
    '75–90 minutes',
    'More than 90 minutes',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Workout Duration'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 10 (10 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 9 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'How long do you usually want your workout sessions to be?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _durations.length,
                  itemBuilder: (context, index) {
                    final duration = _durations[index];
                    return SelectionCard(
                      title: duration,
                      isSelected: _selectedDuration == duration,
                      onTap: () {
                        setState(() => _selectedDuration = duration);
                      },
                    );
                  },
                ),
              ),
              AppButton(
                text: 'Next',
                onPressed: _selectedDuration != null
                    ? () {
                        context.read<OnboardingProvider>().setWorkoutDuration(_selectedDuration!);
                        context.read<OnboardingProvider>().nextStep();
                        Navigator.pushNamed(context, '/workout_location');
                      }
                    : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}