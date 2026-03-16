// lib/features/onboarding/screens/age_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../widgets/app_button.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int _selectedAge = 25;
  final List<int> _ages = List.generate(83, (index) => index + 18);

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 3 (3 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 2 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'How old are you?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This helps us create your personalized plan',
                style: theme.textTheme.bodyMedium,
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
                        setState(() => _selectedAge = _ages[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _ages.length,
                        builder: (context, index) {
                          final age = _ages[index];
                          final isSelected = age == _selectedAge;
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  age.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 80 : 40,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.primaryColor : theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                if (isSelected)
                                  Text(
                                    ' years',
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
                  context.read<OnboardingProvider>().setAge(_selectedAge);
                  context.read<OnboardingProvider>().nextStep();
                  Navigator.pushNamed(context, '/weight');
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