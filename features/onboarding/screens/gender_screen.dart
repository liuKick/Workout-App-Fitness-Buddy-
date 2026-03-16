// lib/features/onboarding/screens/gender_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

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
        title: const Text('Sign Up', style: TextStyle(fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 2 (2 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 1 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'Tell us about yourself',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'To give you a better experience by knowing your gender',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 60),
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      title: 'Male',
                      icon: Icons.male,
                      onTap: () {
                        context.read<OnboardingProvider>().setGender('male');
                        context.read<OnboardingProvider>().nextStep();
                        Navigator.pushNamed(context, '/age');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderCard(
                      title: 'Female',
                      icon: Icons.female,
                      onTap: () {
                        context.read<OnboardingProvider>().setGender('female');
                        context.read<OnboardingProvider>().nextStep();
                        Navigator.pushNamed(context, '/age');
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'You can always change it later',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _GenderCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: theme.primaryColor),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}