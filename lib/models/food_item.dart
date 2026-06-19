// =============================================================================
// models/food_item.dart
// =============================================================================
// This file defines the [FoodItem] data model used throughout the app.
// Each FoodItem represents a single food entry logged by the user,
// whether scanned via the AI camera feature or entered manually.
// =============================================================================

/// Represents a single food item logged by the user.
///
/// Contains nutritional information (calories, protein, carbs, fats),
/// the food name, a unique ID, and the timestamp of when it was logged.
class FoodItem {
  /// Unique identifier for this food item (generated via UUID).
  final String id;

  /// The name of the food (e.g., "Grilled Chicken Salad").
  final String name;

  /// Total calories in kcal.
  final double calories;

  /// Protein content in grams.
  final double protein;

  /// Carbohydrate content in grams.
  final double carbs;

  /// Fat content in grams.
  final double fats;

  /// The timestamp when this food item was logged.
  final DateTime loggedAt;

  /// Optional: path to the image file used for AI scanning.
  /// Will be null if the food was entered manually.
  final String? imagePath;

  /// Whether this item was scanned via AI or entered manually.
  final bool isAIScanned;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.loggedAt,
    this.imagePath,
    this.isAIScanned = false,
  });

  // ---------------------------------------------------------------------------
  // JSON Serialization
  // ---------------------------------------------------------------------------
  // These methods allow us to convert FoodItem to/from JSON for local storage
  // using shared_preferences.

  /// Converts this [FoodItem] to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'loggedAt': loggedAt.toIso8601String(),
      'imagePath': imagePath,
      'isAIScanned': isAIScanned,
    };
  }

  /// Creates a [FoodItem] from a JSON map.
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      imagePath: json['imagePath'] as String?,
      isAIScanned: json['isAIScanned'] as bool? ?? false,
    );
  }

  /// Creates a copy of this FoodItem with optional field overrides.
  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    DateTime? loggedAt,
    String? imagePath,
    bool? isAIScanned,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      loggedAt: loggedAt ?? this.loggedAt,
      imagePath: imagePath ?? this.imagePath,
      isAIScanned: isAIScanned ?? this.isAIScanned,
    );
  }

  @override
  String toString() {
    return 'FoodItem(name: $name, calories: $calories, protein: $protein, '
        'carbs: $carbs, fats: $fats)';
  }
}
