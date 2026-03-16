// lib/features/onboarding/screens/name_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../../../widgets/app_textfield.dart';
import '../../../widgets/app_button.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Name'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator - Step 1 (1 blue dot)
              Row(
                children: List.generate(13, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'What should we call you?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'This is how you\'ll appear in the app',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Name input
              Form(
                key: _formKey,
                child: AppTextfield(
                  controller: _nameController,
                  hintText: 'Your name or nickname',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
              ),
              
              const Spacer(),
              
              // Next button
              AppButton(
                text: 'Continue',
                onPressed: _nameController.text.trim().length >= 2
                    ? () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<OnboardingProvider>().setName(
                            _nameController.text.trim()
                          );
                          context.read<OnboardingProvider>().nextStep();
                          Navigator.pushNamed(context, '/gender');
                        }
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