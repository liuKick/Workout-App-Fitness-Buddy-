import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                'Last updated: March 2026\n\n'
                'Fitness Buddy ("we", "our", "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and disclose your information.\n\n'
                '1. Information We Collect\n'
                '• Personal information (name, email) you provide during registration.\n'
                '• Health and fitness data you enter (age, weight, workout logs, meals).\n'
                '• Usage data (app interactions, features used).\n\n'
                '2. How We Use Information\n'
                '• To provide and improve the app.\n'
                '• To personalize your experience.\n'
                '• To communicate updates and offers (with your consent).\n'
                '• To analyze usage and enhance our services.\n\n'
                '3. Sharing of Information\n'
                'We do not sell your personal data. We may share anonymized data with partners for research. We may disclose information if required by law.\n\n'
                '4. Data Security\n'
                'We implement industry-standard measures to protect your data, but no method is 100% secure.\n\n'
                '5. Your Rights\n'
                'You can access, correct, or delete your personal data by contacting us.\n\n'
                '6. Changes to Policy\n'
                'We may update this policy; we will notify you of material changes.\n\n'
                '7. Contact Us\n'
                'For questions, email: support@fitnessbuddy.com',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}