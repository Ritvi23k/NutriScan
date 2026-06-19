// =============================================================================
// screens/food_search_screen.dart
// =============================================================================
// Searchable food database with Indian food priority and quantity display.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calorie_provider.dart';
import '../services/ai_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_list_item.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AIAnalysisService _aiService = AIAnalysisService();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _popularItems = [];
  bool _hasSearched = false;
  int _resultKey = 0;

  @override
  void initState() {
    super.initState();
    _popularItems = _aiService.getPopularItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() { _searchResults = []; _hasSearched = false; });
      return;
    }
    final results = _aiService.searchFood(query);
    setState(() { _searchResults = results; _hasSearched = true; _resultKey++; });
  }

  void _showFoodDetailSheet(Map<String, dynamic> food) {
    final name = food['name'] as String;
    final calories = (food['calories'] as num).toDouble();
    final protein = (food['protein'] as num).toDouble();
    final carbs = (food['carbs'] as num).toDouble();
    final fats = (food['fats'] as num).toDouble();
    final icon = food['icon'] as String;
    final quantity = food['quantity'] as String? ?? '1 serving';
    final isIndian = food['isIndian'] as bool? ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icon + Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 40)),
                  ),
                ),
                if (isIndian)
                  Positioned(
                    top: -6, right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('🇮🇳', style: const TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name, style: GoogleFonts.outfit(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Serving: $quantity', style: GoogleFonts.outfit(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              )),
            ),
            const SizedBox(height: 24),

            // Calorie highlight
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.primaryMint.withOpacity(0.08),
                  AppTheme.primaryMint.withOpacity(0.03),
                ]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                    color: AppTheme.accentOrange, size: 28),
                  const SizedBox(width: 10),
                  Text('${calories.toInt()}', style: GoogleFonts.outfit(
                    fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                  const SizedBox(width: 6),
                  Text('kcal', style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Macros
            Row(children: [
              _MacroPill(label: 'Protein', value: protein,
                color: AppTheme.proteinColor, icon: Icons.fitness_center_rounded),
              const SizedBox(width: 10),
              _MacroPill(label: 'Carbs', value: carbs,
                color: AppTheme.carbsColor, icon: Icons.grain_rounded),
              const SizedBox(width: 10),
              _MacroPill(label: 'Fats', value: fats,
                color: AppTheme.fatsColor, icon: Icons.water_drop_rounded),
            ]),
            const SizedBox(height: 28),

            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<CalorieProvider>().addFoodItem(
                    name: name, calories: calories, protein: protein,
                    carbs: carbs, fats: fats, isAIScanned: false,
                  );
                  if (mounted) {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(children: [
                          const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text('$name added to your log!',
                            style: GoogleFonts.outfit()),
                        ]),
                        backgroundColor: AppTheme.primaryDark,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text('Add to My Log', style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Food',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryMint.withOpacity(0.08),
                      blurRadius: 20, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _performSearch,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search for a food item...',
                    prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.primaryMint),
                    suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                            color: AppTheme.textTertiary),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                    filled: true, fillColor: AppTheme.surfaceWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: AppTheme.primaryMint.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryMint, width: 2),
                    ),
                  ),
                  style: GoogleFonts.outfit(fontSize: 15),
                ),
              ),
            ),
            Expanded(
              child: _hasSearched
                ? _searchResults.isEmpty ? _buildNoResults() : _buildSearchResults()
                : _buildPopularItems(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItems() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(children: [
              Icon(Icons.trending_up_rounded, size: 18, color: AppTheme.accentOrange),
              const SizedBox(width: 8),
              Text('Popular Indian Foods', style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return AnimatedListItem(
                  index: index,
                  child: _buildFoodCard(_popularItems[index]),
                );
              },
              childCount: _popularItems.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      key: ValueKey(_resultKey),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${_searchResults.length} result${_searchResults.length != 1 ? 's' : ''} found',
              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textTertiary),
            ),
          );
        }
        return AnimatedListItem(
          key: ValueKey('$_resultKey-${index - 1}'),
          index: index - 1,
          child: _buildFoodCard(_searchResults[index - 1]),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.search_off_rounded,
              size: 36, color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 16),
          Text('No results found', style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Try searching for "roti", "dal", or "biryani"',
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    final name = food['name'] as String;
    final calories = (food['calories'] as num).toDouble();
    final protein = (food['protein'] as num).toDouble();
    final carbs = (food['carbs'] as num).toDouble();
    final fats = (food['fats'] as num).toDouble();
    final icon = food['icon'] as String;
    final quantity = food['quantity'] as String? ?? '1 serving';
    final isIndian = food['isIndian'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showFoodDetailSheet(food),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardGrey, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(name, style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (isIndian)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('🇮🇳',
                              style: const TextStyle(fontSize: 10)),
                          ),
                      ]),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                        Text('${calories.toInt()} kcal', style: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppTheme.primaryMint)),
                        Text('· $quantity', style: GoogleFonts.outfit(
                          fontSize: 12, color: AppTheme.textTertiary)),
                        Text('P:${protein.toInt()}g', style: GoogleFonts.outfit(
                          fontSize: 11, color: AppTheme.proteinColor)),
                        Text('C:${carbs.toInt()}g', style: GoogleFonts.outfit(
                          fontSize: 11, color: AppTheme.carbsColor)),
                        Text('F:${fats.toInt()}g', style: GoogleFonts.outfit(
                          fontSize: 11, color: AppTheme.fatsColor)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded,
                    color: AppTheme.primaryMint, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _MacroPill({
    required this.label, required this.value,
    required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text('${value.toInt()}g', style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.outfit(
            fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}
