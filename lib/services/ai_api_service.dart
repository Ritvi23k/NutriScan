// =============================================================================
// services/ai_api_service.dart
// =============================================================================
// AI Vision API integration stub with comprehensive Indian food database.
//
// In production, replace analyzeImage() with a real call to:
//   - Google Gemini Vision API (google_generative_ai package)
//   - OpenAI Vision API (via http package)
//
// The local food database provides offline-first search with 35+ Indian foods.
// =============================================================================

import 'dart:math';

/// Service for AI-powered food analysis and database search.
///
/// Currently uses mock data for offline demo. Replace [analyzeImage] with
/// real API calls when ready for production.
class AIAnalysisService {
  // Singleton
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  final Random _random = Random();

  // ---------------------------------------------------------------------------
  // Indian Food Database (35+ items with accurate macros)
  // ---------------------------------------------------------------------------

  static final List<Map<String, dynamic>> _indianFoodDatabase = [
    // === BREADS ===
    {'name': 'Roti (Chapati)', 'icon': '🫓', 'quantity': '1 piece', 'calories': 104, 'protein': 3.0, 'carbs': 20.0, 'fats': 1.5, 'isIndian': true, 'category': 'bread'},
    {'name': 'Paratha (Plain)', 'icon': '🫓', 'quantity': '1 piece', 'calories': 260, 'protein': 5.0, 'carbs': 36.0, 'fats': 10.0, 'isIndian': true, 'category': 'bread'},
    {'name': 'Naan', 'icon': '🫓', 'quantity': '1 piece', 'calories': 262, 'protein': 9.0, 'carbs': 45.0, 'fats': 5.0, 'isIndian': true, 'category': 'bread'},
    {'name': 'Puri', 'icon': '🫓', 'quantity': '1 piece', 'calories': 120, 'protein': 2.0, 'carbs': 14.0, 'fats': 6.0, 'isIndian': true, 'category': 'bread'},
    {'name': 'Bhature', 'icon': '🫓', 'quantity': '1 piece', 'calories': 300, 'protein': 6.0, 'carbs': 40.0, 'fats': 14.0, 'isIndian': true, 'category': 'bread'},

    // === RICE DISHES ===
    {'name': 'Steamed Rice', 'icon': '🍚', 'quantity': '1 bowl (150g)', 'calories': 195, 'protein': 4.0, 'carbs': 44.0, 'fats': 0.5, 'isIndian': true, 'category': 'rice'},
    {'name': 'Chicken Biryani', 'icon': '🍛', 'quantity': '1 plate', 'calories': 550, 'protein': 28.0, 'carbs': 62.0, 'fats': 18.0, 'isIndian': true, 'category': 'rice'},
    {'name': 'Veg Pulao', 'icon': '🍚', 'quantity': '1 plate', 'calories': 280, 'protein': 6.0, 'carbs': 48.0, 'fats': 8.0, 'isIndian': true, 'category': 'rice'},
    {'name': 'Jeera Rice', 'icon': '🍚', 'quantity': '1 plate', 'calories': 220, 'protein': 5.0, 'carbs': 42.0, 'fats': 4.0, 'isIndian': true, 'category': 'rice'},
    {'name': 'Lemon Rice', 'icon': '🍚', 'quantity': '1 plate', 'calories': 250, 'protein': 5.0, 'carbs': 44.0, 'fats': 7.0, 'isIndian': true, 'category': 'rice'},

    // === DAL & CURRIES ===
    {'name': 'Dal Tadka', 'icon': '🥘', 'quantity': '1 bowl', 'calories': 180, 'protein': 12.0, 'carbs': 24.0, 'fats': 4.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Dal Fry', 'icon': '🥘', 'quantity': '1 bowl', 'calories': 190, 'protein': 12.0, 'carbs': 26.0, 'fats': 5.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Rajma (Kidney Beans)', 'icon': '🥘', 'quantity': '1 bowl', 'calories': 210, 'protein': 14.0, 'carbs': 34.0, 'fats': 3.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Chole (Chickpeas)', 'icon': '🥘', 'quantity': '1 bowl', 'calories': 240, 'protein': 13.0, 'carbs': 35.0, 'fats': 6.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Sambar', 'icon': '🥘', 'quantity': '1 bowl', 'calories': 140, 'protein': 7.0, 'carbs': 22.0, 'fats': 3.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Palak Paneer', 'icon': '🧀', 'quantity': '1 bowl', 'calories': 320, 'protein': 15.0, 'carbs': 10.0, 'fats': 24.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Paneer Butter Masala', 'icon': '🧀', 'quantity': '1 bowl', 'calories': 400, 'protein': 18.0, 'carbs': 14.0, 'fats': 30.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Aloo Gobi', 'icon': '🥔', 'quantity': '1 bowl', 'calories': 180, 'protein': 5.0, 'carbs': 24.0, 'fats': 8.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Bhindi Masala', 'icon': '🥬', 'quantity': '1 bowl', 'calories': 150, 'protein': 4.0, 'carbs': 16.0, 'fats': 8.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Chicken Curry', 'icon': '🍗', 'quantity': '1 bowl', 'calories': 350, 'protein': 30.0, 'carbs': 10.0, 'fats': 22.0, 'isIndian': true, 'category': 'curry'},
    {'name': 'Butter Chicken', 'icon': '🍗', 'quantity': '1 bowl', 'calories': 440, 'protein': 28.0, 'carbs': 12.0, 'fats': 32.0, 'isIndian': true, 'category': 'curry'},

    // === SOUTH INDIAN ===
    {'name': 'Idli', 'icon': '🍘', 'quantity': '2 pieces', 'calories': 130, 'protein': 4.0, 'carbs': 26.0, 'fats': 0.5, 'isIndian': true, 'category': 'south'},
    {'name': 'Masala Dosa', 'icon': '🫓', 'quantity': '1 piece', 'calories': 280, 'protein': 7.0, 'carbs': 42.0, 'fats': 10.0, 'isIndian': true, 'category': 'south'},
    {'name': 'Plain Dosa', 'icon': '🫓', 'quantity': '1 piece', 'calories': 160, 'protein': 4.0, 'carbs': 28.0, 'fats': 4.0, 'isIndian': true, 'category': 'south'},
    {'name': 'Medu Vada', 'icon': '🍩', 'quantity': '2 pieces', 'calories': 260, 'protein': 8.0, 'carbs': 30.0, 'fats': 12.0, 'isIndian': true, 'category': 'south'},
    {'name': 'Uttapam', 'icon': '🫓', 'quantity': '1 piece', 'calories': 220, 'protein': 6.0, 'carbs': 36.0, 'fats': 6.0, 'isIndian': true, 'category': 'south'},
    {'name': 'Upma', 'icon': '🍚', 'quantity': '1 bowl', 'calories': 200, 'protein': 5.0, 'carbs': 34.0, 'fats': 6.0, 'isIndian': true, 'category': 'south'},

    // === SNACKS ===
    {'name': 'Samosa', 'icon': '🥟', 'quantity': '1 piece', 'calories': 250, 'protein': 5.0, 'carbs': 30.0, 'fats': 12.0, 'isIndian': true, 'category': 'snack'},
    {'name': 'Poha', 'icon': '🍚', 'quantity': '1 bowl', 'calories': 250, 'protein': 5.0, 'carbs': 46.0, 'fats': 6.0, 'isIndian': true, 'category': 'snack'},
    {'name': 'Pakora', 'icon': '🍤', 'quantity': '5 pieces', 'calories': 300, 'protein': 6.0, 'carbs': 28.0, 'fats': 18.0, 'isIndian': true, 'category': 'snack'},
    {'name': 'Paneer Tikka', 'icon': '🧀', 'quantity': '6 pieces', 'calories': 320, 'protein': 18.0, 'carbs': 12.0, 'fats': 22.0, 'isIndian': true, 'category': 'snack'},

    // === BEVERAGES ===
    {'name': 'Masala Chai', 'icon': '🍵', 'quantity': '1 cup', 'calories': 120, 'protein': 3.0, 'carbs': 15.0, 'fats': 5.0, 'isIndian': true, 'category': 'beverage'},
    {'name': 'Mango Lassi', 'icon': '🥛', 'quantity': '1 glass', 'calories': 260, 'protein': 6.0, 'carbs': 45.0, 'fats': 6.0, 'isIndian': true, 'category': 'beverage'},
    {'name': 'Buttermilk (Chaas)', 'icon': '🥛', 'quantity': '1 glass', 'calories': 60, 'protein': 3.0, 'carbs': 5.0, 'fats': 3.0, 'isIndian': true, 'category': 'beverage'},

    // === DESSERTS ===
    {'name': 'Gulab Jamun', 'icon': '🍩', 'quantity': '2 pieces', 'calories': 280, 'protein': 4.0, 'carbs': 40.0, 'fats': 12.0, 'isIndian': true, 'category': 'dessert'},
    {'name': 'Rasgulla', 'icon': '🍡', 'quantity': '2 pieces', 'calories': 180, 'protein': 4.0, 'carbs': 36.0, 'fats': 2.0, 'isIndian': true, 'category': 'dessert'},
    {'name': 'Kheer', 'icon': '🍮', 'quantity': '1 bowl', 'calories': 280, 'protein': 8.0, 'carbs': 42.0, 'fats': 10.0, 'isIndian': true, 'category': 'dessert'},

    // === COMMON NON-INDIAN ===
    {'name': 'Banana', 'icon': '🍌', 'quantity': '1 medium', 'calories': 105, 'protein': 1.3, 'carbs': 27.0, 'fats': 0.4, 'isIndian': false, 'category': 'fruit'},
    {'name': 'Apple', 'icon': '🍎', 'quantity': '1 medium', 'calories': 95, 'protein': 0.5, 'carbs': 25.0, 'fats': 0.3, 'isIndian': false, 'category': 'fruit'},
    {'name': 'Boiled Egg', 'icon': '🥚', 'quantity': '1 egg', 'calories': 78, 'protein': 6.0, 'carbs': 0.6, 'fats': 5.0, 'isIndian': false, 'category': 'protein'},
    {'name': 'Greek Yogurt', 'icon': '🫐', 'quantity': '1 cup', 'calories': 180, 'protein': 15.0, 'carbs': 22.0, 'fats': 4.0, 'isIndian': false, 'category': 'dairy'},
    {'name': 'Oatmeal', 'icon': '🥣', 'quantity': '1 bowl', 'calories': 170, 'protein': 6.0, 'carbs': 30.0, 'fats': 3.0, 'isIndian': false, 'category': 'breakfast'},
    {'name': 'Green Salad', 'icon': '🥗', 'quantity': '1 bowl', 'calories': 80, 'protein': 3.0, 'carbs': 12.0, 'fats': 2.0, 'isIndian': false, 'category': 'salad'},
    {'name': 'Grilled Chicken Breast', 'icon': '🍗', 'quantity': '150g', 'calories': 230, 'protein': 35.0, 'carbs': 0.0, 'fats': 9.0, 'isIndian': false, 'category': 'protein'},
    {'name': 'Protein Shake', 'icon': '🥤', 'quantity': '1 glass', 'calories': 200, 'protein': 25.0, 'carbs': 15.0, 'fats': 4.0, 'isIndian': false, 'category': 'beverage'},
  ];

  // Mock AI analysis results (rotated randomly)
  static final List<Map<String, dynamic>> _mockAnalysisResults = [
    {'name': 'Paneer Tikka with Mint Chutney', 'calories': 320, 'protein': 18.0, 'carbs': 12.0, 'fats': 22.0},
    {'name': 'Chicken Biryani (1 plate)', 'calories': 550, 'protein': 28.0, 'carbs': 62.0, 'fats': 18.0},
    {'name': 'Masala Dosa with Sambar', 'calories': 350, 'protein': 10.0, 'carbs': 52.0, 'fats': 12.0},
    {'name': 'Palak Paneer with 2 Roti', 'calories': 530, 'protein': 22.0, 'carbs': 50.0, 'fats': 28.0},
    {'name': 'Chole Bhature', 'calories': 540, 'protein': 19.0, 'carbs': 75.0, 'fats': 20.0},
    {'name': 'Idli (3 pcs) with Chutney', 'calories': 210, 'protein': 6.0, 'carbs': 40.0, 'fats': 2.0},
    {'name': 'Mixed Veg Curry with Rice', 'calories': 420, 'protein': 12.0, 'carbs': 58.0, 'fats': 14.0},
    {'name': 'Dal Fry with Jeera Rice', 'calories': 410, 'protein': 17.0, 'carbs': 68.0, 'fats': 9.0},
  ];

  // ---------------------------------------------------------------------------
  // AI Image Analysis (Mock)
  // ---------------------------------------------------------------------------

  /// Simulates AI-powered food image analysis.
  ///
  /// In production, replace with a real Gemini Vision API call:
  /// ```dart
  /// final model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);
  /// final response = await model.generateContent([
  ///   Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
  /// ]);
  /// ```
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Pick a random mock result
    final result = _mockAnalysisResults[_random.nextInt(_mockAnalysisResults.length)];

    return {
      'name': result['name'],
      'calories': result['calories'],
      'protein': result['protein'],
      'carbs': result['carbs'],
      'fats': result['fats'],
      'confidence': 0.87 + _random.nextDouble() * 0.10,
      'imagePath': imagePath,
    };
  }

  // ---------------------------------------------------------------------------
  // Food Search (Local Database)
  // ---------------------------------------------------------------------------

  /// Searches the local food database. Indian foods are prioritized.
  List<Map<String, dynamic>> searchFood(String query) {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();

    // Score-based search: exact match > starts with > contains
    final scored = <MapEntry<int, Map<String, dynamic>>>[];

    for (final food in _indianFoodDatabase) {
      final name = (food['name'] as String).toLowerCase();
      final category = (food['category'] as String).toLowerCase();

      int score = 0;
      if (name == normalizedQuery) {
        score = 100;
      } else if (name.startsWith(normalizedQuery)) {
        score = 80;
      } else if (name.contains(normalizedQuery)) {
        score = 60;
      } else if (category.contains(normalizedQuery)) {
        score = 40;
      }

      // Boost Indian foods
      if (score > 0 && food['isIndian'] == true) {
        score += 10;
      }

      if (score > 0) {
        scored.add(MapEntry(score, food));
      }
    }

    // Sort by score descending
    scored.sort((a, b) => b.key.compareTo(a.key));

    return scored.map((e) => e.value).toList();
  }

  // ---------------------------------------------------------------------------
  // Popular Items
  // ---------------------------------------------------------------------------

  /// Returns popular Indian food items for the browse/search screen.
  List<Map<String, dynamic>> getPopularItems() {
    return _indianFoodDatabase
        .where((food) => food['isIndian'] == true)
        .take(15)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // All Items (for future use)
  // ---------------------------------------------------------------------------

  /// Returns the full food database.
  List<Map<String, dynamic>> getAllFoodItems() {
    return List.unmodifiable(_indianFoodDatabase);
  }
}
