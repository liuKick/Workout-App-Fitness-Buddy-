// lib/features/onboarding/screens/workout_frequency_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../widgets/app_button.dart';

class WorkoutFrequencyScreen extends StatefulWidget {
  const WorkoutFrequencyScreen({super.key});

  @override
  State<WorkoutFrequencyScreen> createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen> {
  int _selectedDays = 3;
  final List<int> _dayOptions = [1, 2, 3, 4, 5, 6, 7];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.read<OnboardingProvider>().previousStep();
            Navigator.pop(context);
          },
        ),
        title: const Text('Workout Frequency'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 7 (7 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 6 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'How often do you plan to work out each week?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                height: 250,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      itemExtent: 80,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedDays = _dayOptions[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _dayOptions.length,
                        builder: (context, index) {
                          final days = _dayOptions[index];
                          final isSelected = days == _selectedDays;
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  days.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 80 : 40,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.primaryColor : theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                if (isSelected)
                                  Text(
                                    days == 1 ? ' day' : ' days',
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Next',
                onPressed: () {
                  context.read<OnboardingProvider>().setWorkoutFrequency(_selectedDays);
                  context.read<OnboardingProvider>().nextStep();
                  Navigator.pushNamed(context, '/fitness_level');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}