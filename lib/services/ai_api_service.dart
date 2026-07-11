// =============================================================================
// services/ai_api_service.dart
// =============================================================================
// AI Vision API integration using Google Gemini for food image analysis.
//
// Uses the `google_generative_ai` package to send food photos to
// Gemini's vision model and get back nutritional information.
//
// The local food database provides offline-first search with 35+ Indian foods.
// =============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/api_keys.dart';

/// Service for AI-powered food analysis and database search.
///
/// Uses Google Gemini Vision API for image analysis and a local
/// database for food search.
class AIAnalysisService {
  // Singleton
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  /// Lazily initialized Gemini model.
  GenerativeModel? _model;

  GenerativeModel get _geminiModel {
    _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: ApiKeys.geminiApiKey,
    );
    return _model!;
  }

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

  // ---------------------------------------------------------------------------
  // AI Image Analysis (Gemini Vision)
  // ---------------------------------------------------------------------------

  /// The prompt sent to Gemini to analyze food images.
  static const String _analysisPrompt = '''
Analyze this food image and identify the food items visible.
Provide your response as a valid JSON object with these exact keys:
{
  "name": "Name of the food (include quantity if visible, e.g. '2 Roti with Dal')",
  "calories": <total estimated calories as a number>,
  "protein": <grams of protein as a number>,
  "carbs": <grams of carbohydrates as a number>,
  "fats": <grams of fat as a number>
}

Rules:
- If multiple food items are visible, combine them into one entry with totals.
- Use realistic nutritional estimates based on standard serving sizes.
- For Indian foods, use typical restaurant/homemade portion sizes.
- Return ONLY the JSON object, no markdown, no explanation, no code fences.
''';

  /// Analyzes a food image using Gemini Vision API.
  ///
  /// Accepts [imageBytes] (the raw image data) and [mimeType] (e.g. 'image/jpeg').
  /// This works on all platforms including Flutter Web.
  ///
  /// Returns a Map with keys: name, calories, protein, carbs, fats, confidence.
  /// Throws an exception if the API call fails or the response can't be parsed.
  Future<Map<String, dynamic>> analyzeImage(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) async {
    // Validate API key
    if (ApiKeys.geminiApiKey == 'PASTE_YOUR_GEMINI_API_KEY_HERE' ||
        ApiKeys.geminiApiKey.isEmpty) {
      throw Exception(
        'Gemini API key not configured. '
        'Open lib/config/api_keys.dart and paste your key.',
      );
    }

    // Send to Gemini Vision
    final content = Content.multi([
      TextPart(_analysisPrompt),
      DataPart(mimeType, imageBytes),
    ]);

    final response = await _geminiModel.generateContent([content]);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    // Parse JSON from response (strip any accidental markdown fences)
    final cleaned = responseText
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
        'Failed to parse Gemini response as JSON.\n'
        'Raw response: $responseText',
      );
    }

    // Validate required fields exist
    final requiredKeys = ['name', 'calories', 'protein', 'carbs', 'fats'];
    for (final key in requiredKeys) {
      if (!parsed.containsKey(key)) {
        throw Exception('Gemini response missing required field: "$key"');
      }
    }

    return {
      'name': parsed['name'] as String,
      'calories': (parsed['calories'] as num).toDouble(),
      'protein': (parsed['protein'] as num).toDouble(),
      'carbs': (parsed['carbs'] as num).toDouble(),
      'fats': (parsed['fats'] as num).toDouble(),
      'confidence': 0.92, // Gemini doesn't return confidence; use a fixed value
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
