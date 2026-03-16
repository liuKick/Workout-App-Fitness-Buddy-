// lib/features/onboarding/screens/weight_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../widgets/app_button.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double _selectedWeight = 70;
  final List<double> _weights = List.generate(150, (index) => (index + 30).toDouble());

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
              // Progress indicator – Step 4 (4 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 3 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'What is your Weight?',
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
                        setState(() => _selectedWeight = _weights[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _weights.length,
                        builder: (context, index) {
                          final weight = _weights[index];
                          final isSelected = weight == _selectedWeight;
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weight.toStringAsFixed(0),
                                  style: TextStyle(
                                    fontSize: isSelected ? 80 : 40,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.primaryColor : theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                if (isSelected)
                                  const Text(
                                    ' kg',
                                    style: TextStyle(
                                      fontSize: 30,
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
                  context.read<OnboardingProvider>().setWeight(_selectedWeight);
                  context.read<OnboardingProvider>().nextStep();
                  Navigator.pushNamed(context, '/height');
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