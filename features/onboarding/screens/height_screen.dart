// lib/features/onboarding/screens/height_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../widgets/app_button.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  int _selectedHeight = 175;
  final List<int> _heights = List.generate(121, (index) => index + 100);

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
              // Progress indicator – Step 5 (5 blue dots)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= 4 ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'What is your Height?',
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
                        setState(() => _selectedHeight = _heights[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _heights.length,
                        builder: (context, index) {
                          final height = _heights[index];
                          final isSelected = height == _selectedHeight;
                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  height.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 80 : 40,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.primaryColor : theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                if (isSelected)
                                  const Text(
                                    ' cm',
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
                  context.read<OnboardingProvider>().setHeight(_selectedHeight);
                  context.read<OnboardingProvider>().nextStep();
                  Navigator.pushNamed(context, '/fitness_goal');
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