// lib/features/achievements/providers/achievement_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int points;
  final IconData icon;
  final Color color;
  final String requirement;
  final int targetValue;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.color,
    required this.requirement,
    required this.targetValue,
  });
}

class UserAchievement {
  final String achievementId;
  final DateTime unlockedAt;
  final Achievement achievement;

  UserAchievement({
    required this.achievementId,
    required this.unlockedAt,
    required this.achievement,
  });
}

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  List<UserAchievement> _userAchievements = [];
  int _totalPoints = 0;
  bool _isLoading = false;

  Function(Achievement)? onAchievementUnlocked;

  List<Achievement> get achievements => _achievements;
  List<UserAchievement> get userAchievements => _userAchievements;
  int get totalPoints => _totalPoints;
  bool get isLoading => _isLoading;

  final List<Achievement> _defaultAchievements = [
    Achievement(
      id: 'first_workout',
      title: 'First Step',
      description: 'Complete your first workout',
      points: 10,
      icon: Icons.fitness_center,
      color: Colors.blue,
      requirement: 'workouts',
      targetValue: 1,
    ),
    Achievement(
      id: 'workout_warrior',
      title: 'Workout Warrior',
      description: 'Complete 10 workouts',
      points: 50,
      icon: Icons.sports_mma,
      color: Colors.green,
      requirement: 'workouts',
      targetValue: 10,
    ),
    Achievement(
      id: 'fitness_addict',
      title: 'Fitness Addict',
      description: 'Complete 50 workouts',
      points: 200,
      icon: Icons.whatshot,
      color: Colors.orange,
      requirement: 'workouts',
      targetValue: 50,
    ),
    Achievement(
      id: 'gym_legend',
      title: 'Gym Legend',
      description: 'Complete 100 workouts',
      points: 500,
      icon: Icons.emoji_events,
      color: Colors.amber,
      requirement: 'workouts',
      targetValue: 100,
    ),
    Achievement(
      id: 'on_a_roll',
      title: 'On a Roll',
      description: '3 day streak',
      points: 20,
      icon: Icons.trending_up,
      color: Colors.lightBlue,
      requirement: 'streak',
      targetValue: 3,
    ),
    Achievement(
      id: 'weekly_warrior',
      title: 'Weekly Warrior',
      description: '7 day streak',
      points: 100,
      icon: Icons.calendar_view_week,
      color: Colors.purple,
      requirement: 'streak',
      targetValue: 7,
    ),
    Achievement(
      id: 'unstoppable',
      title: 'Unstoppable',
      description: '30 day streak',
      points: 500,
      icon: Icons.flash_on,
      color: Colors.red,
      requirement: 'streak',
      targetValue: 30,
    ),
    Achievement(
      id: 'first_meal',
      title: 'First Bite',
      description: 'Log your first meal',
      points: 5,
      icon: Icons.restaurant,
      color: Colors.green,
      requirement: 'meals',
      targetValue: 1,
    ),
    Achievement(
      id: 'meal_prep_pro',
      title: 'Meal Prep Pro',
      description: 'Log 30 meals',
      points: 100,
      icon: Icons.kitchen,
      color: Colors.teal,
      requirement: 'meals',
      targetValue: 30,
    ),
    Achievement(
      id: 'century_club',
      title: 'Century Club',
      description: '100 minutes total workout time',
      points: 50,
      icon: Icons.timer,
      color: Colors.indigo,
      requirement: 'minutes',
      targetValue: 100,
    ),
    Achievement(
      id: 'marathon_master',
      title: 'Marathon Master',
      description: '1000 minutes total workout time',
      points: 300,
      icon: Icons.directions_run,
      color: Colors.deepOrange,
      requirement: 'minutes',
      targetValue: 1000,
    ),
  ];

  AchievementProvider() {
    _achievements = _defaultAchievements;
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        // print('❌ No user logged in for achievements');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // print('📥 Loading achievements for user: ${user.id}');

      final response = await Supabase.instance.client
          .from('user_achievements')
          .select()
          .eq('user_id', user.id);

      _userAchievements = [];
      _totalPoints = 0;

      // print('📊 Found ${response.length} achievements in database');

      for (var item in response) {
        final achievement = _achievements.firstWhere(
          (a) => a.id == item['achievement_id'],
          orElse: () => Achievement(
            id: item['achievement_id'],
            title: 'Unknown',
            description: '',
            points: item['points'] ?? 0,
            icon: Icons.star,
            color: Colors.grey,
            requirement: '',
            targetValue: 0,
          ),
        );

        _userAchievements.add(UserAchievement(
          achievementId: item['achievement_id'],
          unlockedAt: DateTime.parse(item['unlocked_at']),
          achievement: achievement,
        ));

        _totalPoints += achievement.points;
      }

      // print('✅ Loaded ${_userAchievements.length} achievements');
      // print('💰 Total points: $_totalPoints');
    } catch (e) {
      // print('❌ Error loading achievements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAndUnlockAchievements() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // print('❌ checkAndUnlockAchievements: No user logged in');
      return;
    }

    // print('🏆 checkAndUnlockAchievements called for user: ${user.id}');

    try {
      final workoutResponse = await Supabase.instance.client
          .from('workout_logs')
          .select()
          .eq('user_id', user.id);
      
      final workoutCount = workoutResponse.length;
      // print('📊 Workout count: $workoutCount');

      int totalMinutes = 0;
      for (var log in workoutResponse) {
        totalMinutes += ((log['duration_seconds'] ?? 0) as num) ~/ 60;
      }
      // print('📊 Total minutes: $totalMinutes');

      int streakDays = 0;
      if (workoutResponse.isNotEmpty) {
        final dates = workoutResponse.map((log) => 
          DateTime.parse(log['completed_at']).toLocal()
        ).toList();
        dates.sort((a, b) => b.compareTo(a));
        
        if (dates.isNotEmpty) {
          streakDays = 1;
          for (int i = 0; i < dates.length - 1; i++) {
            final diff = dates[i].difference(dates[i + 1]).inDays;
            if (diff == 1) {
              streakDays++;
            } else {
              break;
            }
          }
        }
      }
      // print('📊 Streak days: $streakDays');

      final mealsResponse = await Supabase.instance.client
          .from('meal_logs')
          .select()
          .eq('user_id', user.id);
      
      final mealsLogged = mealsResponse.length;
      // print('📊 Meals logged: $mealsLogged');

      await checkAchievements(
        workoutsCompleted: workoutCount,
        streakDays: streakDays,
        mealsLogged: mealsLogged,
        totalMinutes: totalMinutes,
      );

      // print('✅ checkAndUnlockAchievements completed successfully');

    } catch (e) {
      // print('❌ Error in checkAndUnlockAchievements: $e');
    }
  }

  Future<void> checkAchievements({
    required int workoutsCompleted,
    required int streakDays,
    required int mealsLogged,
    required int totalMinutes,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // print('❌ checkAchievements: No user logged in');
      return;
    }

    // print('🔍 CHECKING ACHIEVEMENTS for user: ${user.id}');
    // print('   Workouts: $workoutsCompleted');
    // print('   Streak: $streakDays');
    // print('   Meals: $mealsLogged');
    // print('   Minutes: $totalMinutes');

    List<Achievement> newlyUnlocked = [];

    for (var achievement in _achievements) {
      if (_userAchievements.any((ua) => ua.achievementId == achievement.id)) {
        continue;
      }

      bool shouldUnlock = false;

      switch (achievement.requirement) {
        case 'workouts':
          shouldUnlock = workoutsCompleted >= achievement.targetValue;
          break;
        case 'streak':
          shouldUnlock = streakDays >= achievement.targetValue;
          break;
        case 'meals':
          shouldUnlock = mealsLogged >= achievement.targetValue;
          break;
        case 'minutes':
          shouldUnlock = totalMinutes >= achievement.targetValue;
          break;
      }

      if (shouldUnlock) {
        // print('🚀 UNLOCKING: ${achievement.title}');
        await _unlockAchievement(user.id, achievement);
        newlyUnlocked.add(achievement);
      }
    }

    // print('🎉 Newly unlocked: ${newlyUnlocked.length} achievements');

    for (var achievement in newlyUnlocked) {
      if (onAchievementUnlocked != null) {
        // print('🎊 Triggering popup for: ${achievement.title}');
        onAchievementUnlocked!(achievement);
      }
    }
  }

  Future<void> _unlockAchievement(String userId, Achievement achievement) async {
    // print('💾 Attempting to save achievement to database: ${achievement.title}');
    try {
      final response = await Supabase.instance.client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievement.id,
        'unlocked_at': DateTime.now().toIso8601String(),
        'points': achievement.points,
      }).select();

      // print('✅ Database insert successful: $response');

      _userAchievements.add(UserAchievement(
        achievementId: achievement.id,
        unlockedAt: DateTime.now(),
        achievement: achievement,
      ));

      _totalPoints += achievement.points;

      // print('🎉 Achievement unlocked and added locally: ${achievement.title}');
      // print('💰 Total points now: $_totalPoints');
      
      notifyListeners();
      
      if (onAchievementUnlocked != null) {
        onAchievementUnlocked!(achievement);
      }
      
    } catch (e) {
      // print('❌ ERROR unlocking achievement: $e');
      // if (e is PostgrestException) {
      //   print('   Code: ${e.code}');
      //   print('   Message: ${e.message}');
      //   print('   Details: ${e.details}');
      // }
    }
  }

  void resetForTesting() {
    _userAchievements.clear();
    _totalPoints = 0;
    notifyListeners();
  }
}