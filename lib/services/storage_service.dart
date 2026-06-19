// =============================================================================
// services/storage_service.dart
// =============================================================================
// Handles local data persistence using shared_preferences.
// Enhanced with water intake, streak counter, and first-time user persistence.
// =============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

/// Service class for persisting food log data locally on the device.
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _keyPrefix = 'food_log_';
  static const String _goalKey = 'daily_calorie_goal';
  static const String _waterGoalKey = 'daily_water_goal';
  static const String _waterIntakePrefix = 'water_intake_';
  static const String _streakKey = 'daily_streak';
  static const String _lastLogDateKey = 'last_log_date';
  static const String _firstTimeKey = 'is_first_time_user';
  static const String _onboardingKey = 'onboarding_completed';

  // ---------------------------------------------------------------------------
  // Food Log Operations
  // ---------------------------------------------------------------------------

  String _dateKey(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$_keyPrefix$dateStr';
  }

  String _waterDateKey(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$_waterIntakePrefix$dateStr';
  }

  Future<void> saveFoodItems(DateTime date, List<FoodItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(date);
    final jsonList = items.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(key, jsonString);
  }

  Future<List<FoodItem>> loadFoodItems(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(date);
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => FoodItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteFoodItem(DateTime date, String itemId) async {
    final items = await loadFoodItems(date);
    items.removeWhere((item) => item.id == itemId);
    await saveFoodItems(date, items);
  }

  // ---------------------------------------------------------------------------
  // Daily Goal Operations
  // ---------------------------------------------------------------------------

  Future<void> saveDailyGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_goalKey, goal);
  }

  Future<double> loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_goalKey) ?? 2000.0;
  }

  // ---------------------------------------------------------------------------
  // Water Intake Operations
  // ---------------------------------------------------------------------------

  Future<void> saveWaterGoal(double liters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_waterGoalKey, liters);
  }

  Future<double> loadWaterGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_waterGoalKey) ?? 3.0;
  }

  Future<void> saveWaterIntake(DateTime date, int glasses) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _waterDateKey(date);
    await prefs.setInt(key, glasses);
  }

  Future<int> loadWaterIntake(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _waterDateKey(date);
    return prefs.getInt(key) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Streak Operations
  // ---------------------------------------------------------------------------

  Future<void> saveStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, streak);
  }

  Future<int> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> saveLastLogDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await prefs.setString(_lastLogDateKey, dateStr);
  }

  Future<String?> loadLastLogDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLogDateKey);
  }

  // ---------------------------------------------------------------------------
  // First Time User & Onboarding
  // ---------------------------------------------------------------------------

  Future<void> setFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, false);
  }

  Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // ---------------------------------------------------------------------------
  // History Operations
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getHistory({int days = 30}) async {
    final history = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final items = await loadFoodItems(date);

      if (items.isNotEmpty) {
        final totalCalories =
            items.fold<double>(0, (sum, item) => sum + item.calories);
        final totalProtein =
            items.fold<double>(0, (sum, item) => sum + item.protein);
        final totalCarbs =
            items.fold<double>(0, (sum, item) => sum + item.carbs);
        final totalFats =
            items.fold<double>(0, (sum, item) => sum + item.fats);

        history.add({
          'date': date,
          'totalCalories': totalCalories,
          'totalProtein': totalProtein,
          'totalCarbs': totalCarbs,
          'totalFats': totalFats,
          'itemCount': items.length,
        });
      }
    }

    return history;
  }
}
