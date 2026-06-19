// =============================================================================
// models/models.dart
// =============================================================================
// Barrel file for all data models. Re-exports FoodItem and defines DailyLog.
// =============================================================================

export 'food_item.dart';

/// Represents a single day's diet log with meals, water, and calorie target.
class DailyLog {
  final DateTime date;
  final List<dynamic> meals; // Uses FoodItem from food_item.dart
  final double waterLiters;
  final double targetCalories;

  DailyLog({
    required this.date,
    this.meals = const [],
    this.waterLiters = 0.0,
    this.targetCalories = 2000,
  });

  DailyLog copyWith({
    DateTime? date,
    List<dynamic>? meals,
    double? waterLiters,
    double? targetCalories,
  }) {
    return DailyLog(
      date: date ?? this.date,
      meals: meals ?? this.meals,
      waterLiters: waterLiters ?? this.waterLiters,
      targetCalories: targetCalories ?? this.targetCalories,
    );
  }
}
