// lib/features/onboarding/screens/equipment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../widgets/app_button.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final List<Map<String, dynamic>> _equipmentOptions = [
    {'title': 'No equipment', 'selected': false},
    {'title': 'Dumbbells only', 'selected': false},
    {'title': 'Barbell & plates', 'selected': false},
    {'title': 'Machines', 'selected': false},
    {'title': 'Resistance bands', 'selected': false},
    {'title': 'Full gym access', 'selected': false},
    {'title': 'Limited / mixed equipment', 'selected': false},
  ];

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const int currentStep = 11; // 0-based index, so 11 = 12th screen

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
        title: const Text('Equipment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator – Step 12
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index <= currentStep ? Colors.blue : theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Text(
                'What equipment do you have access to?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _equipmentOptions.length,
                  itemBuilder: (context, index) {
                    final option = _equipmentOptions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _equipmentOptions[index]['selected'] = !_equipmentOptions[index]['selected'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: option['selected'] ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: option['selected'] ? theme.primaryColor : theme.dividerColor,
                            width: option['selected'] ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option['title'],
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: option['selected'] ? theme.primaryColor : null,
                                ),
                              ),
                            ),
                            if (option['selected'])
                              Icon(Icons.check_circle, color: theme.primaryColor),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              AppButton(
                text: _isSaving ? 'Saving...' : 'Submit',
                onPressed: _isSaving ? null : () async {
                  final selectedEquipment = _equipmentOptions
                      .where((option) => option['selected'] == true)
                      .map((option) => option['title'] as String)
                      .toList();

                  final onboardingProvider = context.read<OnboardingProvider>();
                  onboardingProvider.setEquipment(selectedEquipment);
                  onboardingProvider.nextStep();

                  setState(() => _isSaving = true);

                  final success = await onboardingProvider.saveToDatabase(context);

                  if (!mounted) return;

                  setState(() => _isSaving = false);

                  if (success) {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error saving your data. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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