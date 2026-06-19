// =============================================================================
// providers/calorie_provider.dart
// =============================================================================
// Central state management using the Provider pattern.
// Enhanced with water intake tracking, daily streak counter, and mock data.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';

/// Central state management for the calorie tracking app.
class CalorieProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  // ---------------------------------------------------------------------------
  // State Variables
  // ---------------------------------------------------------------------------

  List<FoodItem> _todaysFoodItems = [];
  List<FoodItem> get todaysFoodItems => List.unmodifiable(_todaysFoodItems);

  double _dailyGoal = 2000.0;
  double get dailyGoal => _dailyGoal;

  /// Standard macro split: 30% Protein, 40% Carbs, 30% Fat.
  double get proteinGoal => (_dailyGoal * 0.30) / 4;
  double get carbsGoal => (_dailyGoal * 0.40) / 4;
  double get fatsGoal => (_dailyGoal * 0.30) / 9;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Water tracking
  int _waterGlasses = 0;
  int get waterGlasses => _waterGlasses;

  double _waterGoal = 3.0; // in liters
  double get waterGoal => _waterGoal;

  double get waterConsumedLiters => _waterGlasses * 0.25; // 250ml per glass
  double get waterProgress =>
      _waterGoal > 0 ? (waterConsumedLiters / _waterGoal).clamp(0.0, 1.0) : 0;

  // Streak
  int _dailyStreak = 0;
  int get dailyStreak => _dailyStreak;

  // First time user
  bool _isFirstTimeUser = true;
  bool get isFirstTimeUser => _isFirstTimeUser;

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  double get totalCalories =>
      _todaysFoodItems.fold(0.0, (sum, item) => sum + item.calories);
  double get totalProtein =>
      _todaysFoodItems.fold(0.0, (sum, item) => sum + item.protein);
  double get totalCarbs =>
      _todaysFoodItems.fold(0.0, (sum, item) => sum + item.carbs);
  double get totalFats =>
      _todaysFoodItems.fold(0.0, (sum, item) => sum + item.fats);
  double get calorieProgress =>
      _dailyGoal > 0 ? totalCalories / _dailyGoal : 0.0;
  double get remainingCalories => _dailyGoal - totalCalories;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dailyGoal = await _storageService.loadDailyGoal();
      _waterGoal = await _storageService.loadWaterGoal();

      final today = DateTime.now();
      _todaysFoodItems = await _storageService.loadFoodItems(today);
      _waterGlasses = await _storageService.loadWaterIntake(today);
      _dailyStreak = await _storageService.loadStreak();
      _isFirstTimeUser = await _storageService.isFirstTimeUser();

      // Update streak
      await _updateStreak();

      // Seed mock data for demo purposes if no history exists
      await _seedMockDataIfNeeded();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Mock Data Seeding — Generates realistic 30-day history for demo
  // ---------------------------------------------------------------------------

  Future<void> _seedMockDataIfNeeded() async {
    final history = await _storageService.getHistory(days: 7);
    if (history.isNotEmpty) return; // Already has data

    final now = DateTime.now();
    final foods = [
      {'name': 'Roti (2 pcs)', 'cal': 240.0, 'p': 6.0, 'c': 50.0, 'f': 2.0},
      {'name': 'Dal Fry (1 bowl)', 'cal': 180.0, 'p': 12.0, 'c': 24.0, 'f': 4.0},
      {'name': 'Paneer Butter Masala', 'cal': 400.0, 'p': 18.0, 'c': 14.0, 'f': 30.0},
      {'name': 'Chicken Biryani', 'cal': 550.0, 'p': 28.0, 'c': 62.0, 'f': 18.0},
      {'name': 'Idli (3 pcs)', 'cal': 195.0, 'p': 6.0, 'c': 39.0, 'f': 1.0},
      {'name': 'Masala Dosa', 'cal': 280.0, 'p': 7.0, 'c': 42.0, 'f': 10.0},
      {'name': 'Poha', 'cal': 250.0, 'p': 5.0, 'c': 46.0, 'f': 6.0},
      {'name': 'Chole Bhature', 'cal': 550.0, 'p': 15.0, 'c': 60.0, 'f': 28.0},
      {'name': 'Greek Yogurt', 'cal': 180.0, 'p': 15.0, 'c': 22.0, 'f': 4.0},
      {'name': 'Banana', 'cal': 105.0, 'p': 1.3, 'c': 27.0, 'f': 0.4},
    ];

    // Seed last 7 days with 2-4 items per day
    for (int i = 1; i <= 7; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final itemCount = 2 + (i % 3); // 2-4 items
      final items = <FoodItem>[];

      for (int j = 0; j < itemCount; j++) {
        final food = foods[(i * 3 + j) % foods.length];
        items.add(FoodItem(
          id: _uuid.v4(),
          name: food['name'] as String,
          calories: food['cal'] as double,
          protein: food['p'] as double,
          carbs: food['c'] as double,
          fats: food['f'] as double,
          loggedAt: date.add(Duration(hours: 8 + j * 4)),
        ));
      }
      await _storageService.saveFoodItems(date, items);
      // Also seed water intake
      await _storageService.saveWaterIntake(date, 6 + (i % 5));
    }

    // Set streak based on seeded data
    _dailyStreak = 5;
    await _storageService.saveStreak(_dailyStreak);
  }

  // ---------------------------------------------------------------------------
  // Streak Management
  // ---------------------------------------------------------------------------

  Future<void> _updateStreak() async {
    final lastLogStr = await _storageService.loadLastLogDate();
    if (lastLogStr == null) return;

    final lastLogDate = DateTime.parse(lastLogStr);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate =
        DateTime(lastLogDate.year, lastLogDate.month, lastLogDate.day);

    final diff = todayDate.difference(lastDate).inDays;
    if (diff > 1) {
      // Streak broken
      _dailyStreak = 0;
      await _storageService.saveStreak(0);
    }
  }

  Future<void> _recordLogDate() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final lastLogStr = await _storageService.loadLastLogDate();
    if (lastLogStr != null) {
      final lastLogDate = DateTime.parse(lastLogStr);
      final lastDate =
          DateTime(lastLogDate.year, lastLogDate.month, lastLogDate.day);
      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 1) {
        _dailyStreak++;
      } else if (diff > 1) {
        _dailyStreak = 1;
      }
      // diff == 0 means same day, no change needed
    } else {
      _dailyStreak = 1;
    }

    await _storageService.saveStreak(_dailyStreak);
    await _storageService.saveLastLogDate(todayDate);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Food Item Management
  // ---------------------------------------------------------------------------

  Future<void> addFoodItem({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    String? imagePath,
    bool isAIScanned = false,
  }) async {
    final foodItem = FoodItem(
      id: _uuid.v4(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      loggedAt: DateTime.now(),
      imagePath: imagePath,
      isAIScanned: isAIScanned,
    );

    _todaysFoodItems.add(foodItem);
    notifyListeners();

    await _saveTodaysItems();
    await _recordLogDate();
  }

  Future<void> removeFoodItem(String id) async {
    _todaysFoodItems.removeWhere((item) => item.id == id);
    notifyListeners();
    await _saveTodaysItems();
  }

  void setAnalyzing(bool value) {
    _isAnalyzing = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Water Intake Management
  // ---------------------------------------------------------------------------

  Future<void> addWater({int glasses = 1}) async {
    _waterGlasses += glasses;
    notifyListeners();

    final today = DateTime.now();
    await _storageService.saveWaterIntake(today, _waterGlasses);
  }

  Future<void> removeWater() async {
    if (_waterGlasses > 0) {
      _waterGlasses--;
      notifyListeners();

      final today = DateTime.now();
      await _storageService.saveWaterIntake(today, _waterGlasses);
    }
  }

  // ---------------------------------------------------------------------------
  // Daily Goal Management
  // ---------------------------------------------------------------------------

  Future<void> updateDailyGoal(double newGoal) async {
    _dailyGoal = newGoal;
    notifyListeners();
    await _storageService.saveDailyGoal(newGoal);
  }

  Future<void> updateWaterGoal(double newGoal) async {
    _waterGoal = newGoal;
    notifyListeners();
    await _storageService.saveWaterGoal(newGoal);
  }

  // ---------------------------------------------------------------------------
  // First Time User
  // ---------------------------------------------------------------------------

  Future<void> completeFirstTimeSetup({
    required double calorieGoal,
    required double waterGoal,
  }) async {
    _dailyGoal = calorieGoal;
    _waterGoal = waterGoal;
    _isFirstTimeUser = false;
    notifyListeners();

    await _storageService.saveDailyGoal(calorieGoal);
    await _storageService.saveWaterGoal(waterGoal);
    await _storageService.setFirstTimeComplete();
  }

  // ---------------------------------------------------------------------------
  // History & Weekly Data
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getHistory({int days = 30}) async {
    return _storageService.getHistory(days: days);
  }

  Future<List<Map<String, dynamic>>> getWeeklyData() async {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final items = await _storageService.loadFoodItems(date);
      final totalCalories =
          items.fold<double>(0, (sum, item) => sum + item.calories);

      result.add({
        'date': date,
        'calories': totalCalories,
        'label': weekDays[date.weekday - 1],
      });
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  Future<void> _saveTodaysItems() async {
    try {
      final today = DateTime.now();
      await _storageService.saveFoodItems(today, _todaysFoodItems);
    } catch (e) {
      _errorMessage = 'Failed to save data: $e';
      notifyListeners();
    }
  }
}
