// lib/features/onboarding/screens/welcome_screen.dart
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (you can use LoginScreen2.jpg or any welcome image)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/LoginScreen1.jpg'), // Use your second image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  
                  // "Welcome to" text
                  Text(
                    'Welcome',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 36,
                    ),
                  ),
                  
                  // "Fitness" text (styled like your screenshot)
                  Text(
                    'to',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 36,
                    ),
                  ),
                  
                  Text(
                    'Fitness Buddy',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 64,
                      height: 1.2,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // "Hi" text (seems like a greeting in your screenshot)
                  Text(
                    'Hi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Motivational text (optional)
                  Text(
                    'Ready to start your journey?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // "Start" button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Login screen
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}