// lib/features/onboarding/screens/fitness_level_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/selection_card.dart';
import '../../../widgets/app_button.dart';

class FitnessLevelScreen extends StatefulWidget {
  const FitnessLevelScreen({super.key});

  @override
  State<FitnessLevelScreen> createState() => _FitnessLevelScreenState();
}

class _FitnessLevelScreenState extends State<FitnessLevelScreen> {
  String? _selectedLevel;

  final List<Map<String, String>> _levels = [
    {'title': 'Beginner (no experience)'},
    {'title': 'Beginner (some experience)'},
    {'title': 'Intermediate'},
    {'title': 'Upper-intermediate'},
    {'title': 'Advanced'},
    {'title': 'Athlete level'},
    {'title': 'Returning after a long break'},
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
        title: const Text('Fitness Level'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 8 (8 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 7 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'What is your current fitness level?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _levels.length,
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    return SelectionCard(
                      title: level['title']!,
                      isSelected: _selectedLevel == level['title'],
                      onTap: () {
                        setState(() => _selectedLevel = level['title']);
                      },
                    );
                  },
                ),
              ),
              AppButton(
                text: 'Next',
                onPressed: _selectedLevel != null
                    ? () {
                        context.read<OnboardingProvider>().setFitnessLevel(_selectedLevel!);
                        context.read<OnboardingProvider>().nextStep();
                        Navigator.pushNamed(context, '/workout_preference');
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