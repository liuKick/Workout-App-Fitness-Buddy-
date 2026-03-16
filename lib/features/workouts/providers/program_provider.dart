// lib/features/workouts/providers/program_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../achievements/providers/achievement_provider.dart';

class ProgramProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _programs = [];
  List<Map<String, dynamic>> _recommendedPrograms = [];
  Map<String, dynamic>? _currentProgram;
  Map<String, dynamic>? _userProgress;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get programs => _programs;
  List<Map<String, dynamic>> get recommendedPrograms => _recommendedPrograms;
  Map<String, dynamic>? get currentProgram => _currentProgram;
  Map<String, dynamic>? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all programs
  Future<void> loadPrograms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('programs')
          .select('''
            *,
            program_weeks (
              *,
              program_workouts (
                *,
                workouts (*)
              )
            )
          ''')
          .eq('is_active', true)
          .order('level');
      _programs = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _errorMessage = 'Error loading programs: $e';
      _programs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get personalized recommendations
  Future<void> getRecommendedPrograms({
    required String userLevel,
    required String userGoal,
    required List<String> userEquipment,
    required int userFrequency,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_programs.isEmpty) await loadPrograms();
      _recommendedPrograms = _programs.where((program) {
        final programLevel = program['level']?.toString().toLowerCase() ?? '';
        final userLevelLower = userLevel.toLowerCase();
        bool levelMatch = false;
        if (userLevelLower == 'beginner') {
          levelMatch = programLevel == 'beginner';
        } else if (userLevelLower == 'intermediate') {
          levelMatch = programLevel == 'intermediate' || programLevel == 'beginner';
        } else if (userLevelLower == 'advanced') {
          levelMatch = programLevel == 'advanced' || programLevel == 'intermediate';
        } else {
          levelMatch = true;
        }
        if (!levelMatch) return false;
        final goals = program['goals'] as List? ?? [];
        final goalMatch = goals.any((g) => 
          g.toString().toLowerCase().contains(userGoal.toLowerCase()));
        if (!goalMatch) return false;
        final required = List<String>.from(program['equipment_needed'] ?? []);
        if (required.isNotEmpty && !required.every((item) => userEquipment.contains(item))) {
          if (!(required.length == 1 && required.first == 'none')) return false;
        }
        final minFreq = program['min_frequency'] ?? 3;
        final maxFreq = program['max_frequency'] ?? 3;
        if (userFrequency < minFreq || userFrequency > maxFreq) return false;
        return true;
      }).toList();
      if (_recommendedPrograms.isEmpty && _programs.isNotEmpty) {
        _recommendedPrograms = List.from(_programs);
      }
    } catch (e) {
      _errorMessage = 'Error getting recommendations: $e';
      if (_programs.isNotEmpty) {
        _recommendedPrograms = List.from(_programs);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a program by ID without modifying shared currentProgram
  Future<Map<String, dynamic>?> fetchProgramById(int programId) async {
    try {
      final response = await Supabase.instance.client
          .from('programs')
          .select('''
            *,
            program_weeks (
              *,
              program_workouts (
                *,
                workouts (*)
              )
            )
          ''')
          .eq('id', programId)
          .maybeSingle();
      return response;
    } catch (e) {
      // Silent fail – return null
      return null;
    }
  }

  // Keep original for compatibility but detail screen won't use it
  Future<void> getProgramDetails(int programId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('programs')
          .select('''
            *,
            program_weeks (
              *,
              program_workouts (
                *,
                workouts (*)
              )
            )
          ''')
          .eq('id', programId)
          .maybeSingle();
      if (response == null) {
        _errorMessage = 'Program not found';
      } else {
        _currentProgram = response;
      }
    } catch (e) {
      _errorMessage = 'Error loading program details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enroll in program
  Future<void> enrollInProgram(int programId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final existing = await Supabase.instance.client
          .from('user_programs')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();
      if (existing != null) {
        await Supabase.instance.client
            .from('user_programs')
            .update({'status': 'switched'})
            .eq('id', existing['id']);
      }
      await Supabase.instance.client
          .from('user_programs')
          .insert({
            'user_id': user.id,
            'program_id': programId,
            'start_date': DateTime.now().toIso8601String(),
            'current_week': 1,
            'current_day': 1,
            'completed_workouts': [],
            'completed_weeks': [],
            'status': 'active',
          });
      await loadUserProgress();
    } catch (e) {
      _errorMessage = 'Error enrolling in program: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user progress
  Future<void> loadUserProgress() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final response = await Supabase.instance.client
          .from('user_programs')
          .select('''
            *,
            programs (
              *,
              program_weeks (
                *,
                program_workouts (
                  *,
                  workouts (*)
                )
              )
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();
      _userProgress = response;
    } catch (e) {
      _errorMessage = 'Error loading user progress: $e';
    }
    notifyListeners();
  }

  // Get today's workout
  Map<String, dynamic>? getTodaysWorkout() {
    if (_userProgress == null) return null;
    try {
      final program = _userProgress!['programs'];
      final currentWeek = _userProgress!['current_week'];
      final currentDay = _userProgress!['current_day'];
      final weeks = List<Map<String, dynamic>>.from(program['program_weeks'] ?? []);
      if (weeks.isEmpty) return null;
      final week = weeks.firstWhere(
        (w) => w['week_number'] == currentWeek,
        orElse: () => weeks.first,
      );
      final workouts = List<Map<String, dynamic>>.from(week['program_workouts'] ?? []);
      if (workouts.isEmpty) return null;
      final todaysWorkout = workouts.firstWhere(
        (w) => w['day_number'] == currentDay,
        orElse: () => workouts.first,
      );
      return todaysWorkout?['workouts'];
    } catch (e) {
      return null;
    }
  }

  /// Complete a workout and advance program progress if it's today's scheduled workout.
  /// Returns true if the operation succeeded (including logging), false on error.
Future<bool> completeWorkout(
  BuildContext context,
  int workoutId, 
  int duration, 
  int calories
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    _errorMessage = 'User not authenticated';
    debugPrint('❌ completeWorkout: $_errorMessage');
    return false;
  }
  if (_userProgress == null) {
    _errorMessage = 'No active program progress found';
    debugPrint('❌ completeWorkout: $_errorMessage');
    return false;
  }

  _isLoading = true;
  notifyListeners();

  try {
    // Always log the workout
    await Supabase.instance.client
        .from('workout_logs')
        .insert({
          'user_id': user.id,
          'user_program_id': _userProgress!['id'],
          'workout_id': workoutId,
          'week_number': _userProgress!['current_week'],
          'day_number': _userProgress!['current_day'],
          'duration_seconds': duration,
          'calories_burned': calories,
          'completed_at': DateTime.now().toIso8601String(),
        });

    // Check achievements (fire and forget)
    try {
      final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
      await achievementProvider.checkAndUnlockAchievements();
    } catch (e) {
      // ignore
    }

    // --- Guard: Only advance program if this workout is today's scheduled workout ---
    final todaysWorkout = getTodaysWorkout();
    final isTodayScheduled = todaysWorkout != null && todaysWorkout['id'] == workoutId;

    if (!isTodayScheduled) {
      // Workout logged but no program advancement – still a success.
      debugPrint('ℹ️ completeWorkout: Workout not today\'s scheduled workout – logging only');
      await loadUserProgress();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // --- Program advancement logic (only for today's workout) ---
    final completedWorkout = {
      'workout_id': workoutId,
      'week': _userProgress!['current_week'],
      'day': _userProgress!['current_day'],
    };
    final updatedCompleted = List<Map<String, dynamic>>.from(_userProgress!['completed_workouts'] ?? [])
      ..add(completedWorkout);

    final program = _userProgress!['programs'];
    final weeks = List<Map<String, dynamic>>.from(program['program_weeks'] ?? []);
    if (weeks.isEmpty) {
      debugPrint('⚠️ completeWorkout: Program has no weeks – logging only');
      await loadUserProgress();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    final currentWeekData = weeks.firstWhere(
      (w) => w['week_number'] == _userProgress!['current_week'],
      orElse: () => weeks.first,
    );
    final weekWorkouts = List<Map<String, dynamic>>.from(currentWeekData['program_workouts'] ?? []);
    final workoutsThisWeek = weekWorkouts.where((w) => w['workouts'] != null).length;
    final completedThisWeek = updatedCompleted.where((cw) => cw['week'] == _userProgress!['current_week']).length;

    bool weekComplete = completedThisWeek >= workoutsThisWeek;

    Map<String, dynamic> updates = {
      'completed_workouts': updatedCompleted,
      'current_day': _userProgress!['current_day'] + 1,
    };

    if (weekComplete) {
      final completedWeeks = List<int>.from(_userProgress!['completed_weeks'] ?? [])
        ..add(_userProgress!['current_week']);
      updates.addAll({
        'completed_weeks': completedWeeks,
        'current_week': _userProgress!['current_week'] + 1,
        'current_day': 1,
      });
    }

    // Check if program is finished
    if (_userProgress!['current_week'] > program['duration_weeks']) {
      updates['status'] = 'completed';
    }

    await Supabase.instance.client
        .from('user_programs')
        .update(updates)
        .eq('id', _userProgress!['id']);

    await loadUserProgress();

    return true;
  } catch (e) {
    _errorMessage = 'Error completing workout: $e';
    debugPrint('❌ completeWorkout error: $e');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  bool isWorkoutCompleted(int week, int day, int workoutId) {
    if (_userProgress == null) return false;
    final completedWorkouts = List<Map<String, dynamic>>.from(_userProgress!['completed_workouts'] ?? []);
    return completedWorkouts.any((cw) => 
      cw['week'] == week && 
      cw['day'] == day && 
      cw['workout_id'] == workoutId
    );
  }

  Future<void> switchProgram(int newProgramId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      if (_userProgress != null) {
        await Supabase.instance.client
            .from('user_programs')
            .update({'status': 'switched'})
            .eq('id', _userProgress!['id']);
      }
      await enrollInProgram(newProgramId);
    } catch (e) {
      _errorMessage = 'Error switching program: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getWeekSchedule(int weekNumber) {
    if (_currentProgram == null) return [];
    try {
      final weeks = List<Map<String, dynamic>>.from(_currentProgram!['program_weeks'] ?? []);
      if (weeks.isEmpty) return [];
      final week = weeks.firstWhere(
        (w) => w['week_number'] == weekNumber,
        orElse: () => weeks.first,
      );
      final workouts = List<Map<String, dynamic>>.from(week['program_workouts'] ?? []);
      return workouts..sort((a, b) => (a['day_number'] ?? 0).compareTo(b['day_number'] ?? 0));
    } catch (e) {
      return [];
    }
  }

  double getProgramProgress() {
    if (_userProgress == null) return 0;
    final program = _userProgress!['programs'];
    final totalWeeks = program['duration_weeks'] ?? 1;
    final currentWeek = _userProgress!['current_week'] - 1;
    return (currentWeek / totalWeeks).clamp(0, 1);
  }

  bool isTodaysWorkoutCompleted() {
    if (_userProgress == null) return false;
    final todaysWorkout = getTodaysWorkout();
    if (todaysWorkout == null) return false;
    final currentWeek = _userProgress!['current_week'];
    final currentDay = _userProgress!['current_day'];
    final workoutId = todaysWorkout['id'];
    return isWorkoutCompleted(currentWeek, currentDay, workoutId);
  }
}