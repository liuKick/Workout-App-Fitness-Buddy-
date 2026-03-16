// lib/features/onboarding/screens/workout_location_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/selection_card.dart';
import '../../../widgets/app_button.dart';

class WorkoutLocationScreen extends StatefulWidget {
  const WorkoutLocationScreen({super.key});

  @override
  State<WorkoutLocationScreen> createState() => _WorkoutLocationScreenState();
}

class _WorkoutLocationScreenState extends State<WorkoutLocationScreen> {
  String? _selectedLocation;

  final List<String> _locations = [
    'Commercial gym',
    'Home gym',
    'Outdoors',
    'Fitness studio',
    'Hotel / travel gym',
    'University / school gym',
    'Multiple locations',
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
        title: const Text('Workout Location'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 11 (11 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 10 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'Where do you usually work out?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return SelectionCard(
                      title: location,
                      isSelected: _selectedLocation == location,
                      onTap: () {
                        setState(() => _selectedLocation = location);
                      },
                    );
                  },
                ),
              ),
              AppButton(
                text: 'Next',
                onPressed: _selectedLocation != null
                    ? () {
                        context.read<OnboardingProvider>().setWorkoutLocation(_selectedLocation!);
                        context.read<OnboardingProvider>().nextStep();
                        Navigator.pushNamed(context, '/equipment');
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