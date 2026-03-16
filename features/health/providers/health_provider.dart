// lib/features/health/providers/health_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../nutrition/providers/meal_log_provider.dart';
import '../../scoring/providers/scoring_provider.dart';

class HealthProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _workoutLogs = [];
  List<Map<String, dynamic>> _weightLogs = [];
  List<Map<String, dynamic>> _mealLogs = [];
  bool _isLoading = false;

  // Stats
  int _totalWorkouts = 0;
  int _totalMinutes = 0;
  int _streakDays = 0;
  int _workoutsThisWeek = 0;
  int _workoutsThisMonth = 0;
  double _weightLost = 0;
  List<Map<String, dynamic>> _weeklyData = [];
  
  // Nutrition stats
  int _totalCaloriesConsumed = 0;
  int _averageDailyCalories = 0;
  int _mealStreak = 0;

  // Getters
  List<Map<String, dynamic>> get workoutLogs => _workoutLogs;
  List<Map<String, dynamic>> get weightLogs => _weightLogs;
  List<Map<String, dynamic>> get mealLogs => _mealLogs;
  bool get isLoading => _isLoading;
  
  int get totalWorkouts => _totalWorkouts;
  int get totalMinutes => _totalMinutes;
  int get streakDays => _streakDays;
  int get workoutsThisWeek => _workoutsThisWeek;
  int get workoutsThisMonth => _workoutsThisMonth;
  double get weightLost => _weightLost;
  List<Map<String, dynamic>> get weeklyData => _weeklyData;
  
  int get totalCaloriesConsumed => _totalCaloriesConsumed;
  int get averageDailyCalories => _averageDailyCalories;
  int get mealStreak => _mealStreak;

  // Load all health data
  Future<void> loadHealthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Load workout logs (independent)
      try {
        final workoutResponse = await Supabase.instance.client
            .from('workout_logs')
            .select('''
              *,
              workouts (*)
            ''')
            .eq('user_id', user.id)
            .order('completed_at', ascending: false);
        _workoutLogs = List<Map<String, dynamic>>.from(workoutResponse);
      } catch (e) {
        // ignore workout logs error
      }

      // Load weight logs (independent) - using created_at
      try {
        final weightResponse = await Supabase.instance.client
            .from('weight_logs')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false); // ✅ changed from 'date' to 'created_at'
        _weightLogs = List<Map<String, dynamic>>.from(weightResponse);
      } catch (e) {
        // ignore weight logs error
        _weightLogs = [];
      }

      // Load meal logs (independent)
      try {
        final mealResponse = await Supabase.instance.client
            .from('meal_logs')
            .select()
            .eq('user_id', user.id)
            .order('logged_at', ascending: false);
        _mealLogs = List<Map<String, dynamic>>.from(mealResponse);
      } catch (e) {
        _mealLogs = [];
      }

      // Calculate stats
      _calculateStats();
      
    } catch (e) {
      // outermost catch just in case
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate all statistics from logs
  void _calculateStats() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    int oldStreak = _streakDays;
    
    _totalWorkouts = _workoutLogs.length;
    
    // Convert seconds to minutes for total minutes
    _totalMinutes = _workoutLogs.fold<int>(0, (sum, log) => 
        sum + ((log['duration_seconds'] as int? ?? 0) / 60).ceil());

    // Workouts this week - using completed_at
    _workoutsThisWeek = _workoutLogs.where((log) {
      try {
        final logDate = DateTime.parse(log['completed_at'] as String);
        return logDate.isAfter(startOfWeek);
      } catch (_) {
        return false;
      }
    }).length;

    // Workouts this month
    _workoutsThisMonth = _workoutLogs.where((log) {
      try {
        final logDate = DateTime.parse(log['completed_at'] as String);
        return logDate.isAfter(startOfMonth);
      } catch (_) {
        return false;
      }
    }).length;

    // Calculate streak
    _calculateStreak(oldStreak);

    // Calculate weight lost (if weight logs exist)
    if (_weightLogs.length >= 2) {
      final first = _weightLogs.last;
      final last = _weightLogs.first;
      final firstWeight = (first['weight'] as num?)?.toDouble() ?? 0;
      final lastWeight = (last['weight'] as num?)?.toDouble() ?? 0;
      _weightLost = (firstWeight - lastWeight).abs();
    }

    // Calculate nutrition stats
    _calculateNutritionStats();

    // Generate weekly data for last 4 weeks
    _generateWeeklyData();
  }

  void _calculateNutritionStats() {
    if (_mealLogs.isEmpty) {
      _totalCaloriesConsumed = 0;
      _averageDailyCalories = 0;
      _mealStreak = 0;
      return;
    }

    _totalCaloriesConsumed = _mealLogs.fold<int>(0, (sum, log) => 
        sum + (log['calories'] as int? ?? 0));

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final last30DaysLogs = _mealLogs.where((log) {
      try {
        final logDate = DateTime.parse(log['logged_at'] as String);
        return logDate.isAfter(thirtyDaysAgo);
      } catch (_) {
        return false;
      }
    }).toList();
    
    if (last30DaysLogs.isNotEmpty) {
      final Map<String, int> dailyCalories = {};
      for (var log in last30DaysLogs) {
        try {
          final date = DateTime.parse(log['logged_at'] as String).toLocal();
          final dateKey = '${date.year}-${date.month}-${date.day}';
          dailyCalories[dateKey] = (dailyCalories[dateKey] ?? 0) + (log['calories'] as int? ?? 0);
        } catch (_) {}
      }
      
      final totalDays = dailyCalories.length;
      if (totalDays > 0) {
        _averageDailyCalories = (dailyCalories.values.reduce((a, b) => a + b) / totalDays).round();
      }
    }

    if (_mealLogs.isNotEmpty) {
      final mealDates = _mealLogs.map((log) {
        try {
          return DateTime.parse(log['logged_at'] as String).toLocal();
        } catch (_) {
          return null;
        }
      }).whereType<DateTime>().toSet().toList()
        ..sort((a, b) => b.compareTo(a));

      if (mealDates.isNotEmpty) {
        int streak = 1;
        DateTime previousDate = mealDates[0];
        for (int i = 1; i < mealDates.length; i++) {
          DateTime currentDate = mealDates[i];
          DateTime expectedPrevious = currentDate.add(const Duration(days: 1));
          if (previousDate.year == expectedPrevious.year &&
              previousDate.month == expectedPrevious.month &&
              previousDate.day == expectedPrevious.day) {
            streak++;
            previousDate = currentDate;
          } else {
            break;
          }
        }
        _mealStreak = streak;
      }
    }
  }

  void _calculateStreak(int oldStreak) {
    if (_workoutLogs.isEmpty) {
      _streakDays = 0;
      return;
    }

    final workoutDates = _workoutLogs.map((log) {
      try {
        return DateTime.parse(log['completed_at'] as String).toLocal();
      } catch (_) {
        return null;
      }
    }).whereType<DateTime>().toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    if (workoutDates.isEmpty) {
      _streakDays = 0;
      return;
    }

    int streak = 1;
    DateTime previousDate = workoutDates[0];
    for (int i = 1; i < workoutDates.length; i++) {
      DateTime currentDate = workoutDates[i];
      DateTime expectedPrevious = currentDate.add(const Duration(days: 1));
      if (previousDate.year == expectedPrevious.year &&
          previousDate.month == expectedPrevious.month &&
          previousDate.day == expectedPrevious.day) {
        streak++;
        previousDate = currentDate;
      } else {
        break;
      }
    }
    _streakDays = streak;
  }

  void _generateWeeklyData() {
    _weeklyData = [];
    final now = DateTime.now();

    for (int weekOffset = 0; weekOffset < 4; weekOffset++) {
      final weekStart = now.subtract(Duration(days: (now.weekday - 1) + (7 * weekOffset)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      List<int> dailyMinutes = List.filled(7, 0);
      
      final weekLogs = _workoutLogs.where((log) {
        try {
          final logDate = DateTime.parse(log['completed_at'] as String).toLocal();
          return logDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
                 logDate.isBefore(weekEnd.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).toList();

      for (var log in weekLogs) {
        try {
          final logDate = DateTime.parse(log['completed_at'] as String).toLocal();
          final dayIndex = logDate.weekday - 1;
          if (dayIndex >= 0 && dayIndex < 7) {
            dailyMinutes[dayIndex] += ((log['duration_seconds'] as int? ?? 0) / 60).ceil();
          }
        } catch (_) {}
      }

      _weeklyData.add({
        'weekNumber': weekOffset + 1,
        'startDate': weekStart,
        'endDate': weekEnd,
        'dailyMinutes': dailyMinutes,
        'totalMinutes': dailyMinutes.reduce((a, b) => a + b),
        'averageMinutes': dailyMinutes.isNotEmpty ? (dailyMinutes.reduce((a, b) => a + b) / 7).round() : 0,
      });
    }
  }

  Future<void> logWorkout({
    required int workoutId,
    required int durationMinutes,
    required int caloriesBurned,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('workout_logs')
          .insert({
            'user_id': user.id,
            'workout_id': workoutId,
            'duration_seconds': durationMinutes * 60,
            'calories_burned': caloriesBurned,
            'completed_at': DateTime.now().toIso8601String(),
          }).select();

      await loadHealthData();
    } catch (e) {
      // ignore
    }
  }

  Future<void> logWorkoutAndCheckAchievements({
    required int workoutId,
    required int durationMinutes,
    required int caloriesBurned,
    required BuildContext context,
  }) async {
    int oldStreak = _streakDays;
    
    await logWorkout(
      workoutId: workoutId,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    final mealProvider = Provider.of<MealLogProvider>(context, listen: false);
    final scoringProvider = Provider.of<ScoringProvider>(context, listen: false);
    
    await achievementProvider.checkAchievements(
      workoutsCompleted: _totalWorkouts,
      streakDays: _streakDays,
      mealsLogged: mealProvider.todayMeals.length,
      totalMinutes: _totalMinutes,
    );
    
    if (_streakDays > oldStreak && _streakDays >= 3) {
      await scoringProvider.logStreakActivity(
        streakDays: _streakDays,
        context: context,
      );
    }

    notifyListeners();
  }

  Future<void> checkAchievementsAfterMeal(BuildContext context) async {
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    final mealProvider = Provider.of<MealLogProvider>(context, listen: false);
    final scoringProvider = Provider.of<ScoringProvider>(context, listen: false);
    
    await achievementProvider.checkAchievements(
      workoutsCompleted: _totalWorkouts,
      streakDays: _streakDays,
      mealsLogged: mealProvider.todayMeals.length,
      totalMinutes: _totalMinutes,
    );
  }

  Future<void> logWeight(double weight) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client
          .from('weight_logs')
          .insert({
            'user_id': user.id,
            'weight': weight,
            'created_at': DateTime.now().toIso8601String(), // ✅ changed from 'date' to 'created_at'
          });

      await loadHealthData();
    } catch (e) {
      // ignore
    }
  }

  String getTrendPercentage() {
    if (_weeklyData.length < 2) return '0%';
    
    final lastWeek = _weeklyData[0]['totalMinutes'] as int? ?? 0;
    final previousWeek = _weeklyData[1]['totalMinutes'] as int? ?? 0;
    
    if (previousWeek == 0) return '+100%';
    
    final change = ((lastWeek - previousWeek) / previousWeek * 100).round();
    return '${change > 0 ? '+' : ''}$change%';
  }

  Map<String, dynamic> getCurrentWeekData() {
    if (_weeklyData.isEmpty) {
      return {
        'dailyMinutes': List.filled(7, 0),
        'totalMinutes': 0,
        'averageMinutes': 0,
      };
    }
    return _weeklyData.first;
  }

  int calculateRealHealthScore({
    required int totalWorkouts,
    required int streakDays,
    required int totalMinutes,
    required int caloriesConsumed,
    required int calorieTarget,
    required double bmi,
    required int mealsLogged,
  }) {
    double score = 0;
    
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
    
    double consistencyScore = 0;
    consistencyScore += (streakDays * 1.5).clamp(0, 15);
    consistencyScore += (_workoutsThisWeek * 3).clamp(0, 15);
    consistencyScore = consistencyScore.clamp(0, 30);
    score += consistencyScore;
    
    double nutritionScore = 0;
    nutritionScore += (mealsLogged * 0.5).clamp(0, 15);
    
    if (calorieTarget > 0 && caloriesConsumed > 0) {
      double ratio = caloriesConsumed / calorieTarget;
      if (ratio >= 0.8 && ratio <= 1.2) {
        nutritionScore += 20;
      } else if (ratio >= 0.6 && ratio <= 1.4) {
        nutritionScore += 10;
      } else if (ratio >= 0.4 && ratio <= 1.6) {
        nutritionScore += 5;
      }
    }
    
    if (bmi > 0) {
      if (bmi >= 18.5 && bmi < 25) {
        // healthy - no penalty
      } else if (bmi >= 25 && bmi < 30) {
        nutritionScore *= 0.9;
      } else if (bmi >= 30) {
        nutritionScore *= 0.8;
      } else if (bmi < 18.5) {
        nutritionScore *= 0.85;
      }
    }
    
    nutritionScore = nutritionScore.clamp(0, 35);
    score += nutritionScore;
    
    return score.round().clamp(0, 100);
  }

  int calculateHealthScore({
    required int age,
    required double bmi,
    required int workoutsThisWeek,
    required int streakDays,
  }) {
    return calculateRealHealthScore(
      totalWorkouts: _totalWorkouts,
      streakDays: streakDays,
      totalMinutes: _totalMinutes,
      caloriesConsumed: _totalCaloriesConsumed,
      calorieTarget: 2000,
      bmi: bmi,
      mealsLogged: _mealLogs.length,
    );
  }
}