// lib/features/auth/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../onboarding/screens/name_screen.dart';
import 'login_screen.dart'; // ✅ Use LoginScreen as the entry point

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();

    print('🔍 AUTH WRAPPER CHECK');
    print('   Logged in: ${authProvider.isLoggedIn}');

    // NOT LOGGED IN → Login Screen
    if (!authProvider.isLoggedIn) {
      print('➡️ Not logged in → LoginScreen');
      return const LoginScreen(); // ✅ Use LoginScreen
    }

    // LOGGED IN BUT NO ONBOARDING DATA → Start Onboarding
    if (onboardingProvider.fitnessGoal == null) {
      print('➡️ Logged in but NO fitness goal → Starting Onboarding');
      return const NameScreen();
    }

    // LOGGED IN AND HAS ONBOARDING DATA → Home
    print('➡️ Logged in WITH fitness goal → HomeScreen');
    return const HomeScreen();
  }
}