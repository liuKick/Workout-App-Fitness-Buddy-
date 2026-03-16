// lib/features/onboarding/providers/onboarding_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart'; 

class OnboardingProvider extends ChangeNotifier {
  // Personal info
  String? _name;
  String? _gender;
  int? _age;
  double? _weight;
  int? _height;
  
  // Fitness info
  String? _fitnessGoal;
  int? _workoutFrequency;
  String? _fitnessLevel;
  String? _workoutPreference;
  String? _workoutDuration;
  String? _workoutLocation;
  List<String> _availableEquipment = [];
  
  int _currentStep = 0;
  bool _isSaving = false;

  // Getters
  String? get name => _name;
  String? get gender => _gender;
  int? get age => _age;
  double? get weight => _weight;
  int? get height => _height;
  String? get fitnessGoal => _fitnessGoal;
  int? get workoutFrequency => _workoutFrequency;
  String? get fitnessLevel => _fitnessLevel;
  String? get workoutPreference => _workoutPreference;
  String? get workoutDuration => _workoutDuration;
  String? get workoutLocation => _workoutLocation;
  List<String> get availableEquipment => List.unmodifiable(_availableEquipment);
  int get currentStep => _currentStep;
  bool get isSaving => _isSaving;

  // Setters
  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setAge(int age) {
    _age = age;
    notifyListeners();
  }

  void setWeight(double weight) {
    _weight = weight;
    notifyListeners();
  }

  void setHeight(int height) {
    _height = height;
    notifyListeners();
  }

  void setFitnessGoal(String goal) {
    _fitnessGoal = goal;
    notifyListeners();
  }

  void setWorkoutFrequency(int days) {
    _workoutFrequency = days;
    notifyListeners();
  }

  void setFitnessLevel(String level) {
    _fitnessLevel = level;
    notifyListeners();
  }

  void setWorkoutPreference(String preference) {
    _workoutPreference = preference;
    notifyListeners();
  }

  void setWorkoutDuration(String duration) {
    _workoutDuration = duration;
    notifyListeners();
  }

  void setWorkoutLocation(String location) {
    _workoutLocation = location;
    notifyListeners();
  }

  void toggleEquipment(String equipment) {
    if (_availableEquipment.contains(equipment)) {
      _availableEquipment.remove(equipment);
    } else {
      _availableEquipment.add(equipment);
    }
    notifyListeners();
  }

  void setEquipment(List<String> equipment) {
    _availableEquipment = equipment;
    notifyListeners();
  }

  // Navigation
  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  bool get isLastStep => _currentStep == 12;
  bool get isFirstStep => _currentStep == 0;

  // ✅ NEW: Save all onboarding data to Supabase
  Future<bool> saveToDatabase(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) {
      print('❌ Cannot save - user not logged in');
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final userId = authProvider.userId!;
      
      // Prepare data for update
      final Map<String, dynamic> userData = {
        'id': userId,
        'name': _name,
        'gender': _gender,
        'age': _age,
        'weight': _weight,
        'height': _height,
        'fitness_goal': _fitnessGoal,
        'workout_frequency': _workoutFrequency,
        'fitness_level': _fitnessLevel,
        'workout_preference': _workoutPreference,
        'workout_duration': _workoutDuration,
        'workout_location': _workoutLocation,
        'available_equipment': _availableEquipment,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove null values (don't overwrite existing data with null)
      userData.removeWhere((key, value) => value == null);

      // Update profile in database
      await Supabase.instance.client
          .from('profiles')
          .upsert(userData);

      print('✅ Onboarding data saved for user: $userId');
      
      // Also save daily goals based on user data
      await _saveDailyGoals(userId);
      
      return true;
    } catch (e) {
      print('❌ Error saving onboarding data: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ✅ NEW: Calculate and save daily goals
  Future<void> _saveDailyGoals(String userId) async {
    // Simple calculations - you can make these more sophisticated
    int calorieGoal = 2400;
    int proteinGoal = 120;
    int carbsGoal = 250;
    int fatGoal = 70;

    // Adjust based on user data
    if (_weight != null) {
      // Rough estimate: bodyweight in lbs * 15 for maintenance
      double weightInLbs = _weight! * 2.20462;
      calorieGoal = (weightInLbs * 15).round();
      
      // Protein: 1g per lb of bodyweight
      proteinGoal = weightInLbs.round();
      
      // Carbs: 40% of calories / 4
      carbsGoal = ((calorieGoal * 0.4) / 4).round();
      
      // Fat: 30% of calories / 9
      fatGoal = ((calorieGoal * 0.3) / 9).round();
    }

    // Adjust for goal
    if (_fitnessGoal?.toLowerCase().contains('fat loss') == true) {
      calorieGoal = (calorieGoal * 0.8).round(); // 20% deficit
      proteinGoal = (proteinGoal * 1.2).round(); // Higher protein
    } else if (_fitnessGoal?.toLowerCase().contains('muscle') == true) {
      calorieGoal = (calorieGoal * 1.1).round(); // 10% surplus
      proteinGoal = (proteinGoal * 1.1).round(); // Higher protein
    }

    await Supabase.instance.client
        .from('profiles')
        .update({
          'daily_calorie_goal': calorieGoal,
          'daily_protein_goal': proteinGoal,
          'daily_carbs_goal': carbsGoal,
          'daily_fat_goal': fatGoal,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    print('✅ Daily goals saved: $calorieGoal kcal, $proteinGoal g protein');
  }

  // Get user data as map
  Map<String, dynamic> getUserData() {
    return {
      'name': _name,
      'gender': _gender,
      'age': _age,
      'weight': _weight,
      'height': _height,
      'fitnessGoal': _fitnessGoal,
      'workoutFrequency': _workoutFrequency,
      'fitnessLevel': _fitnessLevel,
      'workoutPreference': _workoutPreference,
      'workoutDuration': _workoutDuration,
      'workoutLocation': _workoutLocation,
      'availableEquipment': _availableEquipment,
    };
  }

  // Load user data from database (for when user returns)
  Future<void> loadUserData(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isLoggedIn) return;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', authProvider.userId!)
          .maybeSingle();

      if (response != null) {
        _name = response['name'];
        _gender = response['gender'];
        _age = response['age'];
        _weight = response['weight']?.toDouble();
        _height = response['height'];
        _fitnessGoal = response['fitness_goal'];
        _workoutFrequency = response['workout_frequency'];
        _fitnessLevel = response['fitness_level'];
        _workoutPreference = response['workout_preference'];
        _workoutDuration = response['workout_duration'];
        _workoutLocation = response['workout_location'];
        _availableEquipment = List<String>.from(response['available_equipment'] ?? []);
        
        print('✅ Loaded user data from database');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  void resetOnboarding() {
    _name = null;
    _gender = null;
    _age = null;
    _weight = null;
    _height = null;
    _fitnessGoal = null;
    _workoutFrequency = null;
    _fitnessLevel = null;
    _workoutPreference = null;
    _workoutDuration = null;
    _workoutLocation = null;
    _availableEquipment.clear();
    _currentStep = 0;
    notifyListeners();
  }
}