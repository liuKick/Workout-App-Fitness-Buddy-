// lib/core/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  // Unit preferences
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  
  // Notification preferences
  bool _workoutReminders = false;
  bool _mealReminders = false;
  
  // Language preference
  String _language = 'English';
  Locale _locale = const Locale('en'); // ✅ initialize with default, not late
  
  // Privacy preference
  bool _dataSharing = false;

  // Getters
  String get weightUnit => _weightUnit;
  String get heightUnit => _heightUnit;
  bool get workoutReminders => _workoutReminders;
  bool get mealReminders => _mealReminders;
  String get language => _language;
  Locale get locale => _locale; // ✅ safe, always initialized
  bool get dataSharing => _dataSharing;

  // Constructor - load saved settings
  SettingsProvider() {
    _loadSettings(); // async but locale already has default
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _weightUnit = prefs.getString('weightUnit') ?? 'kg';
    _heightUnit = prefs.getString('heightUnit') ?? 'cm';
    _workoutReminders = prefs.getBool('workoutReminders') ?? false;
    _mealReminders = prefs.getBool('mealReminders') ?? false;
    _language = prefs.getString('language') ?? 'English';
    _dataSharing = prefs.getBool('dataSharing') ?? false;
    
    // ✅ set locale based on loaded language
    _locale = _mapLanguageToLocale(_language);
    
    // Reschedule any notifications that should be active
    if (_workoutReminders) {
      await _scheduleWorkoutReminders();
    }
    if (_mealReminders) {
      await _scheduleMealReminders();
    }
    
    notifyListeners();
  }

  // helper to convert language string to Locale
  Locale _mapLanguageToLocale(String language) {
    switch (language) {
      case 'Spanish':
        return const Locale('es');
      case 'French':
        return const Locale('fr');
      default:
        return const Locale('en');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('weightUnit', _weightUnit);
    await prefs.setString('heightUnit', _heightUnit);
    await prefs.setBool('workoutReminders', _workoutReminders);
    await prefs.setBool('mealReminders', _mealReminders);
    await prefs.setString('language', _language);
    await prefs.setBool('dataSharing', _dataSharing);
  }

  // Schedule workout reminders
  Future<void> _scheduleWorkoutReminders() async {
    await NotificationService().scheduleDailyNotification(
      id: 1,
      title: '💪 Time to Workout!',
      body: 'Your workout is waiting. Let\'s crush it today!',
      hour: 8,
      minute: 0,
    );
    await NotificationService().scheduleWeeklyNotification(
      id: 10,
      title: '📅 Weekly Workout Plan',
      body: 'Check out your workout schedule for the week ahead!',
      daysOfWeek: [7],
      hour: 19,
      minute: 0,
    );
  }

  // Schedule meal reminders
  Future<void> _scheduleMealReminders() async {
    await NotificationService().scheduleDailyNotification(
      id: 2,
      title: '🥣 Time for Breakfast!',
      body: 'Don\'t skip the most important meal of the day!',
      hour: 8,
      minute: 0,
    );
    await NotificationService().scheduleDailyNotification(
      id: 3,
      title: '🥗 Lunch Time!',
      body: 'Fuel your body with a healthy meal.',
      hour: 12,
      minute: 0,
    );
    await NotificationService().scheduleDailyNotification(
      id: 4,
      title: '🍽️ Dinner Time!',
      body: 'Enjoy your evening meal.',
      hour: 19,
      minute: 0,
    );
  }

  // Cancel workout reminders
  Future<void> _cancelWorkoutReminders() async {
    await NotificationService().cancelNotification(1);
    await NotificationService().cancelNotification(10);
  }

  // Cancel meal reminders
  Future<void> _cancelMealReminders() async {
    await NotificationService().cancelNotification(2);
    await NotificationService().cancelNotification(3);
    await NotificationService().cancelNotification(4);
  }

  // Setters
  Future<void> setWorkoutReminders(bool value) async {
    _workoutReminders = value;
    await _saveSettings();
    if (value) {
      await _scheduleWorkoutReminders();
    } else {
      await _cancelWorkoutReminders();
    }
    notifyListeners();
  }

  Future<void> setMealReminders(bool value) async {
    _mealReminders = value;
    await _saveSettings();
    if (value) {
      await _scheduleMealReminders();
    } else {
      await _cancelMealReminders();
    }
    notifyListeners();
  }

  Future<void> setWeightUnit(String unit) async {
    _weightUnit = unit;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setHeightUnit(String unit) async {
    _heightUnit = unit;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    _locale = _mapLanguageToLocale(language);
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDataSharing(bool value) async {
    _dataSharing = value;
    await _saveSettings();
    notifyListeners();
  }

  // Unit conversion methods
  String formatWeight(double weightInKg) {
    if (_weightUnit == 'kg') {
      return '${weightInKg.toStringAsFixed(1)} kg';
    } else {
      double weightInLbs = weightInKg * 2.20462;
      return '${weightInLbs.toStringAsFixed(1)} lb';
    }
  }

  String formatHeight(int heightInCm) {
    if (_heightUnit == 'cm') {
      return '$heightInCm cm';
    } else {
      int totalInches = (heightInCm / 2.54).round();
      int feet = totalInches ~/ 12;
      int inches = totalInches % 12;
      return "$feet'$inches\"";
    }
  }

  double getWeightValue(double weightInKg) {
    if (_weightUnit == 'kg') {
      return weightInKg;
    } else {
      return weightInKg * 2.20462;
    }
  }

  int getHeightValue(int heightInCm) {
    if (_heightUnit == 'cm') {
      return heightInCm;
    } else {
      return (heightInCm / 2.54).round();
    }
  }
}