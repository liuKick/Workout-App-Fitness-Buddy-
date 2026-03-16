// lib/features/workouts/providers/workout_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _workouts = [];
  List<Map<String, dynamic>> _recommendedWorkouts = [];
  Map<String, dynamic>? _currentWorkout;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get exercises => _exercises;
  List<Map<String, dynamic>> get workouts => _workouts;
  List<Map<String, dynamic>> get recommendedWorkouts => _recommendedWorkouts;
  Map<String, dynamic>? get currentWorkout => _currentWorkout;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all exercises
  Future<void> loadExercises() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await Supabase.instance.client
          .from('exercises')
          .select()
          .order('name');
      
      _exercises = List<Map<String, dynamic>>.from(response);
      // print('✅ Loaded ${_exercises.length} exercises');
    } catch (e) {
      _errorMessage = 'Error loading exercises: $e';
      // print('❌ Error loading exercises: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all workouts
Future<void> loadWorkouts() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();
  
  try {
    final response = await Supabase.instance.client
        .from('workouts')
        .select('''
          *,
          workout_exercises (
            *,
            exercises (*)
          )
        ''')
        .eq('is_active', true);
    
    _workouts = List<Map<String, dynamic>>.from(response);
    // print('✅ Loaded ${_workouts.length} workouts');
    
    // DEBUG: Print all workout IDs and titles
    // for (var w in _workouts) {
    //   print('📋 Workout: ${w['title']} (ID: ${w['id']})');
    // }
  } catch (e) {
    _errorMessage = 'Error loading workouts: $e';
    // print('❌ Error loading workouts: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Get workouts based on user level and goals
  Future<void> getRecommendedWorkouts({
    required String userLevel,
    required List<String> userGoals,
    required List<String> userEquipment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await Supabase.instance.client
          .from('workouts')
          .select('''
            *,
            workout_exercises (
              *,
              exercises (*)
            )
          ''')
          .eq('level', userLevel)
          .overlaps('primary_goal', userGoals)
          .eq('is_active', true);
      
      // Filter by equipment (client-side for simplicity)
      _recommendedWorkouts = List<Map<String, dynamic>>.from(response)
          .where((workout) {
            final required = List<String>.from(workout['equipment_required'] ?? []);
            if (required.isEmpty || (required.length == 1 && required.first == 'none')) {
              return true;
            }
            return required.every((item) => userEquipment.contains(item));
          }).toList();
      
      // print('✅ Found ${_recommendedWorkouts.length} recommended workouts');
    } catch (e) {
      _errorMessage = 'Error getting recommendations: $e';
      // print('❌ Error getting recommendations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get workout by ID
  Future<void> getWorkoutById(int workoutId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentWorkout = null;
    notifyListeners();
    
    try {
      // print('🔍 Fetching workout with ID: $workoutId');
      
      final response = await Supabase.instance.client
          .from('workouts')
          .select('''
            *,
            workout_exercises (
              *,
              exercises (*)
            )
          ''')
          .eq('id', workoutId)
          .maybeSingle();
      
      if (response == null) {
        _errorMessage = 'Workout not found';
        // print('❌ Workout not found with ID: $workoutId');
      } else {
        _currentWorkout = response;
        
        // Debug prints
        // print('✅ Loaded workout: ${_currentWorkout?['title']}');
        // print('📦 Full workout data: $_currentWorkout');
        
        // final exercises = _currentWorkout?['workout_exercises'];
        // print('📊 Exercises raw type: ${exercises.runtimeType}');
        // print('📊 Exercises value: $exercises');
        
        // if (exercises != null) {
        //   if (exercises is List) {
        //     print('✅ Exercises is a List with ${exercises.length} items');
        //     if (exercises.isNotEmpty) {
        //       print('First exercise item: ${exercises[0]}');
        //       final firstExercise = exercises[0];
        //       if (firstExercise is Map) {
        //         print('First exercise keys: ${firstExercise.keys}');
        //         if (firstExercise.containsKey('exercises')) {
        //           print('Nested exercises data: ${firstExercise['exercises']}');
        //         }
        //       }
        //     }
        //   } else {
        //     print('❌ Exercises is NOT a List: ${exercises.runtimeType}');
        //   }
        // } else {
        //   print('❌ Exercises is null');
        // }
      }
    } catch (e) {
      _errorMessage = 'Error loading workout: $e';
      // print('❌ Error loading workout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}