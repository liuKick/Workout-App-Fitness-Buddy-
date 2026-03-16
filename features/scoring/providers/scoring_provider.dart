// lib/features/scoring/providers/scoring_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../health/providers/health_provider.dart';
import '../../nutrition/providers/meal_log_provider.dart';

class ActivityLog {
  final String id;
  final DateTime timestamp;
  final String type; // 'workout', 'meal', 'weight', 'streak'
  final String title;
  final int points;
  final Map<String, dynamic> details;

  ActivityLog({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.title,
    required this.points,
    required this.details,
  });
}

class ScoringProvider extends ChangeNotifier {
  List<ActivityLog> _activityLogs = [];
  int _totalPoints = 0;
  bool _isLoading = false;

  // Points breakdown by category
  int _workoutPoints = 0;
  int _mealPoints = 0;
  int _streakPoints = 0;
  int _achievementPoints = 0;

  // Getters
  List<ActivityLog> get activityLogs => _activityLogs;
  int get totalPoints => _totalPoints;
  int get workoutPoints => _workoutPoints;
  int get mealPoints => _mealPoints;
  int get streakPoints => _streakPoints;
  int get achievementPoints => _achievementPoints;
  bool get isLoading => _isLoading;

  // Load all activity logs from database
  Future<void> loadActivityLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('activity_logs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _activityLogs = [];
      _totalPoints = 0;
      _workoutPoints = 0;
      _mealPoints = 0;
      _streakPoints = 0;
      _achievementPoints = 0;

      for (var item in response) {
        final points = (item['points'] as num?)?.toInt() ?? 0;

        final log = ActivityLog(
          id: item['id'].toString(),
          timestamp: DateTime.parse(item['created_at']),
          type: item['type'] ?? '',
          title: item['title'] ?? '',
          points: points,
          details: item['details'] ?? {},
        );

        _activityLogs.add(log);
        _totalPoints += points;

        switch (item['type']) {
          case 'workout':
            _workoutPoints += points;
            break;
          case 'meal':
            _mealPoints += points;
            break;
          case 'streak':
            _streakPoints += points;
            break;
          case 'achievement':
            _achievementPoints += points;
            break;
        }
      }

      // print('✅ Loaded ${_activityLogs.length} activity logs');
    } catch (e) {
      // debugPrint('Error loading activity logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Log a workout activity
  Future<void> logWorkoutActivity({
    required String workoutName,
    required int durationMinutes,
    required BuildContext context,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    int points = 10 + durationMinutes;

    try {
      await Supabase.instance.client.from('activity_logs').insert({
        'user_id': user.id,
        'type': 'workout',
        'title': 'Completed: $workoutName',
        'points': points,
        'details': {'duration': durationMinutes, 'workout_name': workoutName},
        'created_at': DateTime.now().toIso8601String(),
      });

      _workoutPoints += points;
      _totalPoints += points;

      _activityLogs.insert(
        0,
        ActivityLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: 'workout',
          title: 'Completed: $workoutName',
          points: points,
          details: {'duration': durationMinutes, 'workout_name': workoutName},
        ),
      );

      notifyListeners();
    } catch (e) {
      // debugPrint('Error logging workout activity: $e');
    }
  }

  // Log a meal activity
  Future<void> logMealActivity({
    required String mealName,
    required int calories,
    required BuildContext context,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    int points = 5;

    try {
      await Supabase.instance.client.from('activity_logs').insert({
        'user_id': user.id,
        'type': 'meal',
        'title': 'Logged: $mealName',
        'points': points,
        'details': {'calories': calories, 'meal_name': mealName},
        'created_at': DateTime.now().toIso8601String(),
      });

      _mealPoints += points;
      _totalPoints += points;

      _activityLogs.insert(
        0,
        ActivityLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: 'meal',
          title: 'Logged: $mealName',
          points: points,
          details: {'calories': calories, 'meal_name': mealName},
        ),
      );

      notifyListeners();
    } catch (e) {
      // debugPrint('Error logging meal activity: $e');
    }
  }

  // Log streak achievement
  Future<void> logStreakActivity({
    required int streakDays,
    required BuildContext context,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    int points = streakDays >= 3 ? (streakDays - 2) * 5 : 0;
    if (points <= 0) return;

    try {
      await Supabase.instance.client.from('activity_logs').insert({
        'user_id': user.id,
        'type': 'streak',
        'title': '$streakDays Day Streak!',
        'points': points,
        'details': {'streak_days': streakDays},
        'created_at': DateTime.now().toIso8601String(),
      });

      _streakPoints += points;
      _totalPoints += points;

      _activityLogs.insert(
        0,
        ActivityLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: 'streak',
          title: '$streakDays Day Streak!',
          points: points,
          details: {'streak_days': streakDays},
        ),
      );

      notifyListeners();
    } catch (e) {
      // debugPrint('Error logging streak activity: $e');
    }
  }

  // Get activity logs for a specific date range
  List<ActivityLog> getLogsForDate(DateTime date) {
    return _activityLogs.where((log) {
      return log.timestamp.year == date.year &&
          log.timestamp.month == date.month &&
          log.timestamp.day == date.day;
    }).toList();
  }

  // Get weekly points summary
  Map<String, int> getWeeklyPoints() {
    Map<String, int> weeklyPoints = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLogs = getLogsForDate(date);
      final total = dayLogs.fold(0, (sum, log) => sum + log.points);

      final dayName = _getDayName(date.weekday);
      weeklyPoints[dayName] = total;
    }

    return weeklyPoints;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // Get points history for charts
  List<Map<String, dynamic>> getPointsHistory(int days) {
    List<Map<String, dynamic>> history = [];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLogs = getLogsForDate(date);
      final total = dayLogs.fold(0, (sum, log) => sum + log.points);

      history.add({
        'date': date,
        'points': total,
        'day': '${date.month}/${date.day}',
      });
    }

    return history;
  }
}