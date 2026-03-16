// lib/features/home/providers/home_provider.dart
import 'package:flutter/material.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../workouts/providers/workout_provider.dart';
import '../../nutrition/providers/meal_log_provider.dart';
import '../../health/providers/health_provider.dart';

class HomeProvider extends ChangeNotifier {
  final OnboardingProvider onboardingProvider;
  final WorkoutProvider workoutProvider;
  final MealLogProvider mealLogProvider;
  final HealthProvider healthProvider;

  HomeProvider({
    required this.onboardingProvider,
    required this.workoutProvider,
    required this.mealLogProvider,
    required this.healthProvider,
  });

  // ===== USER INFO =====
  String get userName => onboardingProvider.name ?? 'there';
  int get streakDays => healthProvider.streakDays;

  // ===== HEALTH SCORE =====
  int get healthScore {
    // Calculate based on available data
    int score = 50; // Base score
    
    // Streak bonus
    score += healthProvider.streakDays * 2;
    
    // Workout frequency bonus
    score += healthProvider.workoutsThisWeek * 5;
    
    // BMI factor (if available from onboarding)
    if (onboardingProvider.weight != null && onboardingProvider.height != null) {
      double heightInMeters = onboardingProvider.height! / 100;
      double bmi = onboardingProvider.weight! / (heightInMeters * heightInMeters);
      
      if (bmi >= 18.5 && bmi < 25) score += 20;
      else if (bmi >= 25 && bmi < 30) score += 10;
    }
    
    return score.clamp(0, 100);
  }

  String get healthMessage {
    if (healthScore >= 80) return '🔥 BEAST MODE! Your consistency is paying off!';
    if (healthScore >= 60) return '💪 Great progress! Keep it up!';
    if (healthScore >= 40) return '👍 You\'re on the right track!';
    return '🌱 Every journey starts with one step!';
  }

  String get healthRank {
    if (healthScore >= 80) return 'TOP 15%';
    if (healthScore >= 60) return 'TOP 30%';
    if (healthScore >= 40) return 'TOP 50%';
    return 'KEEP GOING';
  }

  // ===== TODAY'S PROGRESS =====
  int get todayPoints {
    int points = 0;
    
    // Points from workouts today
    final todayWorkouts = healthProvider.workoutLogs.where((log) {
      final logDate = DateTime.parse(log['created_at'] as String);
      final now = DateTime.now();
      return logDate.year == now.year && 
             logDate.month == now.month && 
             logDate.day == now.day;
    }).toList();
    
    for (var workout in todayWorkouts) {
      // 10 points per exercise (estimate)
      int exercises = workout['exercises_completed'] ?? 0;
      if (exercises == 0) exercises = 5; // Default estimate
      points += exercises * 10;
      
      // Completion bonus
      if (workout['completed'] == true) points += 50;
    }
    
    // Points from meals logged
    points += mealLogProvider.todayMeals.length * 10;
    
    // Streak bonus
    points = (points * (1 + (streakDays * 0.1))).round();
    
    return points;
  }

  int get activeEnergy {
    // 8-12 kcal per minute of exercise
    int totalMinutes = 0;
    
    final todayWorkouts = healthProvider.workoutLogs.where((log) {
      final logDate = DateTime.parse(log['created_at'] as String);
      final now = DateTime.now();
      return logDate.year == now.year && 
             logDate.month == now.month && 
             logDate.day == now.day;
    }).toList();
    
    for (var workout in todayWorkouts) {
      totalMinutes += workout['duration_minutes'] as int? ?? 0;
    }
    
    return totalMinutes * 10; // 10 kcal per minute estimate
  }

  int get activeEnergyGoal => 325; // Default goal (can be customized)
  
  int get exerciseTime {
    final todayWorkouts = healthProvider.workoutLogs.where((log) {
      final logDate = DateTime.parse(log['created_at'] as String);
      final now = DateTime.now();
      return logDate.year == now.year && 
             logDate.month == now.month && 
             logDate.day == now.day;
    }).toList();
    
    return todayWorkouts.fold<int>(0, (sum, log) => 
        sum + (log['duration_minutes'] as int? ?? 0));
  }

  int get exerciseTimeGoal => 28; // Default goal (can be customized)
  
  int get dailySteps => 6240; // Placeholder - needs pedometer integration
  int get dailyStepsGoal => 6240;

  // ===== WORKOUT SECTION =====
  Map<String, dynamic>? get todaysWorkout {
    // Get the most recent workout for today
    final todayWorkouts = healthProvider.workoutLogs.where((log) {
      final logDate = DateTime.parse(log['created_at'] as String);
      final now = DateTime.now();
      return logDate.year == now.year && 
             logDate.month == now.month && 
             logDate.day == now.day;
    }).toList();
    
    if (todayWorkouts.isNotEmpty) {
      return todayWorkouts.first;
    }
    
    // If no workout logged today, return a placeholder or first recommended
    if (workoutProvider.recommendedWorkouts.isNotEmpty) {
      return workoutProvider.recommendedWorkouts.first;
    }
    
    return null;
  }

  String get workoutTitle {
    final workout = todaysWorkout;
    if (workout == null) return 'No workout planned';
    
    // If it's from workout_logs, it has a nested workouts object
    if (workout.containsKey('workouts')) {
      return workout['workouts']?['title'] ?? 'Workout';
    }
    
    return workout['title'] ?? 'Full Body Activation';
  }

  int get workoutDuration {
    final workout = todaysWorkout;
    if (workout == null) return 45; // Default
    
    if (workout.containsKey('duration_minutes')) {
      return workout['duration_minutes'] as int;
    }
    
    return workout['duration'] ?? 45;
  }

  bool get hasTodaysWorkout => todaysWorkout != null;

  // ===== NUTRITION SECTION =====
  int get mealCount => mealLogProvider.todayMeals.length;
  int get totalCalories => mealLogProvider.totalCalories;
  int get totalProtein => mealLogProvider.totalProtein;
  int get remainingProtein {
    int goal = 100; // Default protein goal
    return (goal - totalProtein).clamp(0, goal);
  }
  int get calorieGoal => 2400; // Default calorie goal

  // Load all data
  Future<void> loadHomeData() async {
    await Future.wait([
      workoutProvider.loadWorkouts(),
      healthProvider.loadHealthData(),
    ]);
    
    // Get recommendations based on user data
    if (onboardingProvider.fitnessLevel != null && 
        onboardingProvider.fitnessGoal != null) {
      await workoutProvider.getRecommendedWorkouts(
        userLevel: onboardingProvider.fitnessLevel!,
        userGoals: [onboardingProvider.fitnessGoal!],
        userEquipment: onboardingProvider.availableEquipment,
      );
    }
    
    notifyListeners();
  }
}