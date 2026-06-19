// =============================================================================
// screens/manual_entry_screen.dart
// =============================================================================
// A fallback screen for manually entering food information.
// Users can type in the food name, calories, and optionally macros.
//
// This is useful when:
//   - The user doesn't want to take a photo
//   - The AI scanner isn't available
//   - The user wants to log a specific known food
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  // ---------------------------------------------------------------------------
  // Form Controllers
  // ---------------------------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();

  /// Whether to show the optional macro fields.
  bool _showMacros = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Form Submission
  // ---------------------------------------------------------------------------

  /// Validates the form and adds the food item to the daily log.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final calories = double.parse(_caloriesController.text);
    final protein =
        _proteinController.text.isNotEmpty
            ? double.parse(_proteinController.text)
            : 0.0;
    final carbs =
        _carbsController.text.isNotEmpty
            ? double.parse(_carbsController.text)
            : 0.0;
    final fats =
        _fatsController.text.isNotEmpty
            ? double.parse(_fatsController.text)
            : 0.0;

    await context.read<CalorieProvider>().addFoodItem(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      isAIScanned: false,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text('$name added to your log!', style: GoogleFonts.outfit()),
            ],
          ),
          backgroundColor: AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Build Method
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manual Entry',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header illustration
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentBlue.withOpacity(0.08),
                        AppTheme.accentPurple.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 30,
                          color: AppTheme.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Food Details',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add calories and optional macro info',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------------------------------------------------------
                // Food Name Field
                // ---------------------------------------------------------------
                _buildLabel('Food Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Grilled Chicken Breast',
                    prefixIcon: Icon(
                      Icons.restaurant_rounded,
                      color: AppTheme.primaryMint,
                    ),
                  ),
                  style: GoogleFonts.outfit(fontSize: 15),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ---------------------------------------------------------------
                // Calories Field
                // ---------------------------------------------------------------
                _buildLabel('Calories'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 350',
                    suffixText: 'kcal',
                    prefixIcon: Icon(
                      Icons.local_fire_department_rounded,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter calories';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ---------------------------------------------------------------
                // Optional Macros Toggle
                // ---------------------------------------------------------------
                GestureDetector(
                  onTap: () => setState(() => _showMacros = !_showMacros),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardGrey,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showMacros
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Add Macro Details (Optional)',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------------------------------------------------------
                // Macro Fields (Animated)
                // ---------------------------------------------------------------
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Protein
                        _buildMacroField(
                          controller: _proteinController,
                          label: 'Protein',
                          icon: Icons.fitness_center_rounded,
                          iconColor: AppTheme.proteinColor,
                        ),
                        const SizedBox(height: 14),

                        // Carbs
                        _buildMacroField(
                          controller: _carbsController,
                          label: 'Carbs',
                          icon: Icons.grain_rounded,
                          iconColor: AppTheme.carbsColor,
                        ),
                        const SizedBox(height: 14),

                        // Fats
                        _buildMacroField(
                          controller: _fatsController,
                          label: 'Fats',
                          icon: Icons.water_drop_rounded,
                          iconColor: AppTheme.fatsColor,
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _showMacros
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

                const SizedBox(height: 32),

                // ---------------------------------------------------------------
                // Submit Button
                // ---------------------------------------------------------------
                ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: Text(
                    'Add to Log',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Widgets
  // ---------------------------------------------------------------------------

  /// Builds a styled label for form fields.
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  /// Builds a macro nutrient input field.
  Widget _buildMacroField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: '$label in grams',
        suffixText: 'g',
        prefixIcon: Icon(icon, color: iconColor),
        labelText: label,
      ),
      style: GoogleFonts.outfit(fontSize: 15),
    );
  }
}
