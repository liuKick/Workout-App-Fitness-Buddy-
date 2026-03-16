// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../workouts/providers/workout_provider.dart';
import '../../workouts/providers/program_provider.dart';
import '../../nutrition/providers/meal_log_provider.dart';
import '../../health/providers/health_provider.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../scoring/providers/scoring_provider.dart';
import '../../nutrition/screens/today_log_screen.dart';
import '../../workouts/screens/workout_detail_screen.dart';
import '../../workouts/screens/program_detail_screen.dart';
import '../widgets/today_progress_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // REAL DATA GETTERS
  int get _caloriesBurned {
    final healthProvider = context.read<HealthProvider>();
    final today = DateTime.now();
    
    final todayWorkouts = healthProvider.workoutLogs.where((log) {
      final dateStr = log['completed_at']?.toString();
      if (dateStr == null) return false;
      try {
        final logDate = DateTime.parse(dateStr);
        return logDate.year == today.year && 
               logDate.month == today.month && 
               logDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).toList();
    
    return todayWorkouts.fold<int>(0, (sum, log) => 
        sum + (log['calories_burned'] as int? ?? 0));
  }

  int get _caloriesGoal => 500; // goal for active energy (workout calories)

  int get _activeMinutes {
    final healthProvider = context.read<HealthProvider>();
    final today = DateTime.now();
    
    final todayWorkouts = healthProvider.workoutLogs.where((log) {
      final dateStr = log['completed_at']?.toString();
      if (dateStr == null) return false;
      try {
        final logDate = DateTime.parse(dateStr);
        return logDate.year == today.year && 
               logDate.month == today.month && 
               logDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).toList();
    
    // Convert seconds to minutes and sum them up
    int totalSeconds = 0;
    for (var log in todayWorkouts) {
      totalSeconds += log['duration_seconds'] as int? ?? 0;
    }
    return (totalSeconds / 60).ceil();
  }

  int get _minutesGoal => 30;

  // Steps removed – no longer needed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final workoutProvider = context.read<WorkoutProvider>();
    final healthProvider = context.read<HealthProvider>();
    final programProvider = context.read<ProgramProvider>();
    final achievementProvider = context.read<AchievementProvider>();
    final scoringProvider = context.read<ScoringProvider>();
    
    await Future.wait([
      workoutProvider.loadWorkouts(),
      healthProvider.loadHealthData(),
      programProvider.loadUserProgress(),
      achievementProvider.loadAchievements(),
      scoringProvider.loadActivityLogs(),
    ]);
    
    // Check for achievements based on current stats
    achievementProvider.checkAchievements(
      workoutsCompleted: healthProvider.totalWorkouts,
      streakDays: healthProvider.streakDays,
      mealsLogged: context.read<MealLogProvider>().todayMeals.length,
      totalMinutes: healthProvider.totalMinutes,
    );
  }

  int _calculateHealthScore({
    required int totalWorkouts,
    required int streakDays,
    required int totalMinutes,
    required int caloriesConsumed,
    required int calorieTarget,
    required double bmi,
    required int mealsLogged,
  }) {
    double score = 0;
    
    // 1. WORKOUT SCORE (0-35 points)
    double workoutScore = 0;
    
    if (totalWorkouts >= 50) workoutScore += 20;
    else if (totalWorkouts >= 30) workoutScore += 15;
    else if (totalWorkouts >= 20) workoutScore += 12;
    else if (totalWorkouts >= 10) workoutScore += 8;
    else if (totalWorkouts >= 5) workoutScore += 5;
    else if (totalWorkouts >= 1) workoutScore += 2;
    
    if (totalMinutes >= 1000) workoutScore += 15;
    else if (totalMinutes >= 500) workoutScore += 10;
    else if (totalMinutes >= 200) workoutScore += 5;
    else if (totalMinutes >= 50) workoutScore += 2;
    
    workoutScore = workoutScore.clamp(0, 35);
    score += workoutScore;
    
    // 2. CONSISTENCY SCORE (0-30 points)
    double consistencyScore = 0;
    consistencyScore += (streakDays * 1.5).clamp(0, 15);
    consistencyScore += (context.read<HealthProvider>().workoutsThisWeek * 3).clamp(0, 15);
    consistencyScore = consistencyScore.clamp(0, 30);
    score += consistencyScore;
    
    // 3. NUTRITION SCORE (0-35 points)
    double nutritionScore = 0;
    nutritionScore += (mealsLogged * 0.5).clamp(0, 15);
    
    if (calorieTarget > 0 && caloriesConsumed > 0) {
      double ratio = caloriesConsumed / calorieTarget;
      if (ratio >= 0.8 && ratio <= 1.2) nutritionScore += 20;
      else if (ratio >= 0.6 && ratio <= 1.4) nutritionScore += 10;
      else if (ratio >= 0.4 && ratio <= 1.6) nutritionScore += 5;
    }
    
    // BMI adjustment
    if (bmi > 0) {
      if (bmi >= 18.5 && bmi < 25) { /* healthy - no penalty */ }
      else if (bmi >= 25 && bmi < 30) nutritionScore *= 0.9;
      else if (bmi >= 30) nutritionScore *= 0.8;
      else if (bmi < 18.5) nutritionScore *= 0.85;
    }
    
    nutritionScore = nutritionScore.clamp(0, 35);
    score += nutritionScore;
    
    return score.round().clamp(0, 100);
  }

  String _getHealthMessage(int score) {
    if (score >= 85) return '🌟 LEGEND! You\'re crushing it!';
    if (score >= 70) return '🔥 BEAST MODE! Your consistency is paying off!';
    if (score >= 50) return '💪 ON FIRE! Every workout brings you closer!';
    if (score >= 30) return '📈 PROGRESS! Small steps, big changes!';
    return '🌱 STARTING STRONG! Your journey begins today!';
  }

  int _calculateTodayPoints() {
    final scoringProvider = context.read<ScoringProvider>();
    final today = DateTime.now();
    
    final todayLogs = scoringProvider.activityLogs.where((log) {
      return log.timestamp.year == today.year &&
             log.timestamp.month == today.month &&
             log.timestamp.day == today.day;
    }).toList();
    
    return todayLogs.fold<int>(0, (sum, log) => sum + log.points);
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0: break;
      case 1:
        Navigator.pushReplacementNamed(context, '/workouts');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/nutrition');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/health');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  double _calculateBMI(OnboardingProvider onboarding) {
    final weight = onboarding.weight ?? 70.0;
    final height = onboarding.height ?? 175;
    
    if (weight <= 0 || height <= 0) return 22.6;
    double heightM = height / 100;
    return double.parse((weight / (heightM * heightM)).toStringAsFixed(1));
  }

  int _calculateTDEE(OnboardingProvider onboarding) {
    final age = onboarding.age ?? 25;
    final weight = onboarding.weight ?? 70.0;
    final height = onboarding.height ?? 175;
    final gender = onboarding.gender ?? 'male';
    
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    
    return (bmr * 1.55).round();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final mealProvider = context.watch<MealLogProvider>();
    final programProvider = context.watch<ProgramProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final achievementProvider = context.watch<AchievementProvider>();
    final scoringProvider = context.watch<ScoringProvider>();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;
    
    // Safe string conversion
    final userName = onboardingProvider.name?.toString() ?? 
                    authProvider.userEmail?.split('@')[0]?.toString() ?? 
                    'Guest';
    
    // Calculate REAL values
    final bmi = _calculateBMI(onboardingProvider);
    final tdee = _calculateTDEE(onboardingProvider);
    
    // Calculate REAL health score
    final healthScore = _calculateHealthScore(
      totalWorkouts: healthProvider.totalWorkouts,
      streakDays: healthProvider.streakDays,
      totalMinutes: healthProvider.totalMinutes,
      caloriesConsumed: healthProvider.totalCaloriesConsumed,
      calorieTarget: tdee,
      bmi: bmi,
      mealsLogged: mealProvider.todayMeals.length,
    );
    
    final healthMessage = _getHealthMessage(healthScore);
    final todayPoints = _calculateTodayPoints();
    
    // GET USER'S PROGRAM DATA
    final userProgress = programProvider.userProgress;
    final hasActiveProgram = userProgress != null;
    final todaysWorkout = programProvider.getTodaysWorkout();
    final program = userProgress?['programs'];
    
    // Program details for display
    String programName = 'Full Body Activation';
    String workoutTitle = 'Full Body Activation';
    int workoutDuration = 45;
    
    if (hasActiveProgram && todaysWorkout != null) {
      programName = program?['name']?.toString() ?? 'Your Program';
      workoutTitle = todaysWorkout['title']?.toString() ?? 'Workout';
      workoutDuration = todaysWorkout['duration_minutes'] as int? ?? 45;
    } else if (!hasActiveProgram) {
      programName = 'No Active Program';
      workoutTitle = 'Tap to choose a program';
      workoutDuration = 0;
    }
    
    // Nutrition data
    final mealCount = mealProvider.todayMeals.length;
    final totalCalories = mealProvider.totalCalories;
    final totalProtein = mealProvider.totalProtein;
    final proteinGoal = 120;
    final remainingProtein = (proteinGoal - totalProtein).clamp(0, proteinGoal);
    
    // Get the most recent meal
    Map<String, dynamic>? latestMeal;
    if (mealProvider.todayMeals.isNotEmpty) {
      latestMeal = mealProvider.todayMeals.last;
    }
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER with profile and streak
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade700, Colors.purple.shade700],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName[0].toUpperCase() + userName.substring(1),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Streak badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade800, Colors.orange.shade600],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${healthProvider.streakDays}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // ACHIEVEMENT BADGES
                if (achievementProvider.userAchievements.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RECENT ACHIEVEMENTS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: achievementProvider.userAchievements.length > 3 
                              ? 3 : achievementProvider.userAchievements.length,
                          itemBuilder: (context, index) {
                            final ua = achievementProvider.userAchievements.reversed.toList()[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: ua.achievement.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: ua.achievement.color.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(ua.achievement.icon, color: ua.achievement.color, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    ua.achievement.title,
                                    style: TextStyle(
                                      color: ua.achievement.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ua.achievement.color.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '+${ua.achievement.points}',
                                      style: TextStyle(
                                        color: ua.achievement.color,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                // HEALTH SCORE CARD
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/health'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [const Color(0xFF4158D0), const Color(0xFFC850C0), const Color(0xFFFFCC70)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'HEALTH SCORE',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'TOP ${((100 - healthScore) / 10).round()}%',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              healthScore.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '/100',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 20),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${scoringProvider.totalPoints} pts',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.local_fire_department, color: Colors.orange.shade300, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                healthMessage,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // TODAY'S PROGRESS
                TodayProgressCard(
                  points: todayPoints,
                  activeEnergy: _caloriesBurned,
                  activeEnergyGoal: _caloriesGoal,      // fixed goal for workout calories (500)
                  exerciseTime: _activeMinutes,
                  exerciseTimeGoal: _minutesGoal,       // fixed goal for exercise minutes (30)
                  caloriesConsumed: totalCalories,      // from meals
                  caloriesGoal: tdee,                   // TDEE as daily calorie intake goal
                  onTap: () {
                    Navigator.pushNamed(context, '/scoring');
                  },
                ),
                
                const SizedBox(height: 24),
                
                // WORKOUT PROGRAM SECTION
                GestureDetector(
                  onTap: () {
                    if (hasActiveProgram) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProgramDetailScreen(
                            programId: program!['id'],
                          ),
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, '/workouts');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: hasActiveProgram 
                            ? [Colors.blue.shade900, Colors.purple.shade800]
                            : [Colors.grey.shade800, Colors.grey.shade900],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: hasActiveProgram ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                hasActiveProgram ? Icons.fitness_center : Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              hasActiveProgram ? 'YOUR PROGRAM' : 'CHOOSE A PROGRAM',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasActiveProgram ? programName : 'No Active Program',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (hasActiveProgram) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.fitness_center, color: Colors.white.withOpacity(0.7), size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        workoutTitle,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.timer, color: Colors.white.withOpacity(0.7), size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$workoutDuration min • Today',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  Text(
                                    'Tap to browse programs',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            
                            if (hasActiveProgram && todaysWorkout != null)
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange.shade700, Colors.red.shade500],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WorkoutDetailScreen(
                                          workoutId: todaysWorkout['id'] ?? 0,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'START',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // NUTRITION & MEAL SECTION
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TodayLogScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green.shade900, Colors.teal.shade800],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.restaurant,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'NUTRITION & MEAL',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (mealCount > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: latestMeal != null
                                        ? Text(
                                            latestMeal['name'][0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Icon(Icons.restaurant, color: Colors.white, size: 24),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        latestMeal?['name'] ?? 'No meals',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.local_fire_department, 
                                               color: Colors.orange.shade300, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${latestMeal?['calories'] ?? 0} kcal',
                                            style: TextStyle(
                                              color: Colors.orange.shade300,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 3,
                                            height: 3,
                                            decoration: const BoxDecoration(
                                              color: Colors.white38,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'x${latestMeal?['quantity'] ?? 1}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$mealCount meals',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$totalCalories kcal',
                                      style: TextStyle(
                                        color: Colors.orange.shade300,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.fitness_center, color: Colors.blue, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$remainingProtein g left',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No meals logged yet',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to add meals',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'VIEW DETAILS',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withOpacity(0.5),
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: secondaryTextColor,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}