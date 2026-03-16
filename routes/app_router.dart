// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/quick_setup_screen.dart';
import '../features/onboarding/screens/gender_screen.dart';
import '../features/onboarding/screens/age_screen.dart';
import '../features/onboarding/screens/weight_screen.dart';
import '../features/onboarding/screens/height_screen.dart';
import '../features/onboarding/screens/fitness_goal_screen.dart';
import '../features/onboarding/screens/workout_frequency_screen.dart';
import '../features/onboarding/screens/fitness_level_screen.dart';
import '../features/onboarding/screens/workout_preference_screen.dart';
import '../features/onboarding/screens/workout_duration_screen.dart';
import '../features/onboarding/screens/workout_location_screen.dart';
import '../features/onboarding/screens/equipment_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/name_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/health/screens/health_screen.dart';
import '../features/nutrition/screens/nutrition_screen.dart';
import '../features/nutrition/screens/today_log_screen.dart'; // ✅ ADD THIS
import '../features/workouts/screens/workout_detail_screen.dart';
import '../features/workouts/screens/workouts_hub_screen.dart';
import '../features/achievements/screens/achievement_screen.dart';
import '../features/auth/screens/auth_wrapper.dart';
import '../features/scoring/screens/scoring_screen.dart';



class AppRouter {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String quickSetup = '/quick-setup';
  static const String name = '/name';
  static const String gender = '/gender';
  static const String age = '/age';
  static const String weight = '/weight';
  static const String height = '/height';
  static const String fitnessGoal = '/fitness_goal';
  static const String workoutFrequency = '/workout_frequency';
  static const String fitnessLevel = '/fitness_level';
  static const String workoutPreference = '/workout_preference';
  static const String workoutDuration = '/workout_duration';
  static const String workoutLocation = '/workout_location';
  static const String equipment = '/equipment';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String health = '/health';
  static const String nutrition = '/nutrition';
  static const String todayLog = '/today-log'; // ✅ ADD THIS
  static const String workoutDetail = '/workout_detail';
  static const String achievements = '/achievements';
  static const String scoring = '/scoring';

  

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case quickSetup:
        return MaterialPageRoute(builder: (_) => const QuickSetupScreen());
      case name:
        return MaterialPageRoute(builder: (_) => const NameScreen());
      case gender:
        return MaterialPageRoute(builder: (_) => const GenderScreen());
      case age:
        return MaterialPageRoute(builder: (_) => const AgeScreen());
      case weight:
        return MaterialPageRoute(builder: (_) => const WeightScreen());
      case height:
        return MaterialPageRoute(builder: (_) => const HeightScreen());
      case fitnessGoal:
        return MaterialPageRoute(builder: (_) => const FitnessGoalScreen());
      case workoutFrequency:
        return MaterialPageRoute(builder: (_) => const WorkoutFrequencyScreen());
      case fitnessLevel:
        return MaterialPageRoute(builder: (_) => const FitnessLevelScreen());
      case workoutPreference:
        return MaterialPageRoute(builder: (_) => const WorkoutPreferenceScreen());
      case workoutDuration:
        return MaterialPageRoute(builder: (_) => const WorkoutDurationScreen());
      case workoutLocation:
        return MaterialPageRoute(builder: (_) => const WorkoutLocationScreen());
      case equipment:
        return MaterialPageRoute(builder: (_) => const EquipmentScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/achievements':
        return MaterialPageRoute(builder: (_) => const AchievementsScreen());
      case '/scoring':
        return MaterialPageRoute(builder: (_) => const ScoringScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case health:
        return MaterialPageRoute(builder: (_) => const HealthScreen());
      case nutrition:
        return MaterialPageRoute(builder: (_) => const NutritionScreen());
      case '/today-log': // ✅ ADD THIS
        return MaterialPageRoute(builder: (_) => const TodayLogScreen());
      case '/workouts':
        return MaterialPageRoute(builder: (_) => const WorkoutsHubScreen());
      case '/workout-detail':
        final workoutId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workoutId: workoutId),
        );   
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}