// lib/features/nutrition/providers/meal_log_provider.dart
import 'package:flutter/material.dart';

class MealLogProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _todayMeals = [];

  List<Map<String, dynamic>> get todayMeals => List.unmodifiable(_todayMeals);

  int get totalCalories => 
      _todayMeals.fold<int>(0, (sum, meal) => sum + (meal['calories'] as int) * (meal['quantity'] as int));
  
  int get totalProtein => 
      _todayMeals.fold<int>(0, (sum, meal) => sum + (meal['protein'] as int) * (meal['quantity'] as int));
  
  int get totalCarbs => 
      _todayMeals.fold<int>(0, (sum, meal) => sum + (meal['carbs'] as int) * (meal['quantity'] as int));
  
  int get totalFat => 
      _todayMeals.fold<int>(0, (sum, meal) => sum + (meal['fat'] as int) * (meal['quantity'] as int));

  void addMeal(Map<String, dynamic> meal) {
    // Check if meal already exists
    int existingIndex = _todayMeals.indexWhere((m) => m['name'] == meal['name']);
    
    if (existingIndex >= 0) {
      // Increment quantity if already exists
      _todayMeals[existingIndex]['quantity'] = (_todayMeals[existingIndex]['quantity'] as int) + 1;
    } else {
      // Add new meal with quantity 1
      final newMeal = Map<String, dynamic>.from(meal);
      newMeal['quantity'] = 1;
      _todayMeals.add(newMeal);
    }
    
    notifyListeners();
  }

  void removeMeal(String mealName) {
    _todayMeals.removeWhere((meal) => meal['name'] == mealName);
    notifyListeners();
  }

  void incrementQuantity(String mealName) {
    int index = _todayMeals.indexWhere((meal) => meal['name'] == mealName);
    if (index >= 0) {
      _todayMeals[index]['quantity'] = (_todayMeals[index]['quantity'] as int) + 1;
      notifyListeners();
    }
  }

  void decrementQuantity(String mealName) {
    int index = _todayMeals.indexWhere((meal) => meal['name'] == mealName);
    if (index >= 0) {
      int newQuantity = (_todayMeals[index]['quantity'] as int) - 1;
      if (newQuantity <= 0) {
        _todayMeals.removeAt(index);
      } else {
        _todayMeals[index]['quantity'] = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearLog() {
    _todayMeals.clear();
    notifyListeners();
  }
}