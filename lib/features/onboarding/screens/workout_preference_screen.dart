// lib/features/onboarding/screens/workout_preference_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/selection_card.dart';
import '../../../widgets/app_button.dart';

class WorkoutPreferenceScreen extends StatefulWidget {
  const WorkoutPreferenceScreen({super.key});

  @override
  State<WorkoutPreferenceScreen> createState() => _WorkoutPreferenceScreenState();
}

class _WorkoutPreferenceScreenState extends State<WorkoutPreferenceScreen> {
  String? _selectedPreference;

  final List<String> _preferences = [
    'Weight training',
    'Cardio',
    'HIIT',
    'Bodyweight exercises',
    'Cross-training',
    'Yoga / stretching',
    'Mixed workouts',
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
        title: const Text('Workout Preference'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 9 (9 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 8 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'Which type of workout do you prefer most?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _preferences.length,
                  itemBuilder: (context, index) {
                    final preference = _preferences[index];
                    return SelectionCard(
                      title: preference,
                      isSelected: _selectedPreference == preference,
                      onTap: () {
                        setState(() => _selectedPreference = preference);
                      },
                    );
                  },
                ),
              ),
              AppButton(
                text: 'Next',
                onPressed: _selectedPreference != null
                    ? () {
                        context.read<OnboardingProvider>().setWorkoutPreference(_selectedPreference!);
                        context.read<OnboardingProvider>().nextStep();
                        Navigator.pushNamed(context, '/workout_duration');
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