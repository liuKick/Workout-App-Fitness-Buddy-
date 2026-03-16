// lib/features/onboarding/screens/fitness_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/selection_card.dart';
import '../../../widgets/app_button.dart';

class FitnessGoalScreen extends StatefulWidget {
  const FitnessGoalScreen({super.key});

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
  String? _selectedGoal;

  final List<Map<String, String>> _goals = [
    {
      'title': 'Lose weight',
      'subtitle': 'Strength training can help manage or lose weight by increasing metabolism and burning more calories.'
    },
    {
      'title': 'Build muscle',
      'subtitle': 'Strength training is essential for building muscle mass and strength.'
    },
    {
      'title': 'Increase strength',
      'subtitle': 'This is a primary goal of strength training, which helps improve overall physical capabilities.'
    },
    {
      'title': 'Improve endurance',
      'subtitle': 'Cardio exercises, combined with strength training, enhance endurance and cardiovascular health.'
    },
    {
      'title': 'Stay healthy',
      'subtitle': 'Engaging in strength training contributes to overall health and well-being.'
    },
    {
      'title': 'Rehab / injury recovery',
      'subtitle': 'Strength training aids in recovery from injuries and rehabilitation.'
    },
    {
      'title': 'Prepare for competition',
      'subtitle': 'Training for specific sports or competitions can focus on strength and endurance.'
    },
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
          onPressed: () {
            context.read<OnboardingProvider>().previousStep();
            Navigator.pop(context);
          },
        ),
        title: const Text('Fitness Goals'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 6 (6 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 5 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'What is your primary fitness goal?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _goals.map((goal) {
                      return SelectionCard(
                        title: goal['title']!,
                        subtitle: goal['subtitle'],
                        isSelected: _selectedGoal == goal['title'],
                        onTap: () {
                          setState(() => _selectedGoal = goal['title']);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              AppButton(
                text: 'Next',
                onPressed: _selectedGoal != null
                    ? () {
                        context.read<OnboardingProvider>().setFitnessGoal(_selectedGoal!);
                        context.read<OnboardingProvider>().nextStep();
                        Navigator.pushNamed(context, '/workout_frequency');
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