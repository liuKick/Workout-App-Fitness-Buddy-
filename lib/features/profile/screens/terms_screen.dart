import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms of Service', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                '1. Acceptance of Terms\n'
                'By accessing or using the Fitness Buddy app, you agree to be bound by these Terms. If you do not agree, you may not use the app.\n\n'
                '2. User Accounts\n'
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use.\n\n'
                '3. Privacy\n'
                'Your use of the app is also governed by our Privacy Policy, which is incorporated into these Terms.\n\n'
                '4. Content\n'
                'The app provides fitness and nutrition information for informational purposes only. Consult a professional before starting any workout or diet.\n\n'
                '5. Prohibited Conduct\n'
                'You agree not to misuse the app, interfere with its operation, or attempt to access restricted areas.\n\n'
                '6. Termination\n'
                'We may suspend or terminate your access at any time for violations of these Terms.\n\n'
                '7. Disclaimer of Warranties\n'
                'The app is provided "as is" without warranties of any kind.\n\n'
                '8. Limitation of Liability\n'
                'To the fullest extent permitted by law, we are not liable for any damages arising from your use of the app.\n\n'
                '9. Governing Law\n'
                'These Terms are governed by the laws of [Your Jurisdiction].\n\n'
                '10. Changes to Terms\n'
                'We may update these Terms from time to time. Continued use of the app constitutes acceptance of the revised Terms.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}