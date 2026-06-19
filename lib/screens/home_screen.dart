// =============================================================================
// screens/home_screen.dart
// =============================================================================
// Main dashboard with: personal greeting + streak counter, calorie ring,
// macro bars, water tracker, food log, and bottom navigation.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calorie_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_list_item.dart';
import 'camera_upload_screen.dart';
import 'manual_entry_screen.dart';
import 'food_search_screen.dart';
import 'analytics_screen.dart';
import 'sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalorieProvider>().initialize();
    });

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DashboardBody(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      floatingActionButton: _currentIndex == 0
          ? ScaleTransition(
              scale: _fabScaleAnimation,
              child: FloatingActionButton.extended(
                onPressed: () => _showLogFoodSheet(context),
                icon: const Icon(Icons.camera_alt_rounded, size: 24),
                label: Text(
                  'Log Food',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                elevation: 6,
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }

  void _showLogFoodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Log Your Food',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                )),
            const SizedBox(height: 8),
            Text('Choose how you want to add your meal',
                style: GoogleFonts.outfit(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            _LogOptionTile(
              icon: Icons.camera_alt_rounded,
              iconColor: AppTheme.primaryMint,
              title: 'Scan with AI',
              subtitle: 'Take a photo — auto-scans instantly',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    _createSlideRoute(const CameraUploadScreen()));
              },
            ),
            const SizedBox(height: 12),
            _LogOptionTile(
              icon: Icons.search_rounded,
              iconColor: AppTheme.accentBlue,
              title: 'Search Food',
              subtitle: 'Browse Indian & international foods',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context, _createSlideRoute(const FoodSearchScreen()));
              },
            ),
            const SizedBox(height: 12),
            _LogOptionTile(
              icon: Icons.edit_rounded,
              iconColor: AppTheme.accentPurple,
              title: 'Enter Manually',
              subtitle: 'Type in food name and calories',
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context, _createSlideRoute(const ManualEntryScreen()));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
            parent: animation, curve: Curves.easeOutCubic));
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// =============================================================================
// _LogOptionTile
// =============================================================================
class _LogOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LogOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardGrey,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _DashboardBody — Main dashboard content
// =============================================================================
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<CalorieProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryMint),
          );
        }

        return SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with greeting + streak
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(context),
                  ),
                ),
              ),

              // Calorie progress card
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildCalorieCard(context, provider),
                  ),
                ),
              ),

              // Macro breakdown row
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildMacroRow(provider),
                  ),
                ),
              ),

              // Water intake tracker
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildWaterTracker(context, provider),
                  ),
                ),
              ),

              // Today's logs header
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's Log",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            )),
                        Text('${provider.todaysFoodItems.length} items',
                            style: GoogleFonts.outfit(
                                fontSize: 14, color: AppTheme.textTertiary)),
                      ],
                    ),
                  ),
                ),
              ),

              // Food item cards
              if (provider.todaysFoodItems.isEmpty)
                SliverToBoxAdapter(
                  child: AnimatedListItem(
                    index: 5,
                    child: _buildEmptyState(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = provider.todaysFoodItems[index];
                        return AnimatedListItem(
                          index: 5 + index,
                          staggerDelayMs: 60,
                          child: _buildFoodItemCard(context, item, provider),
                        );
                      },
                      childCount: provider.todaysFoodItems.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  static Widget _buildHeader(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final calorieProvider = context.watch<CalorieProvider>();
    final firstName = authProvider.isSignedIn
        ? authProvider.userName.split(' ').first
        : 'there';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, $firstName! 👋',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (calorieProvider.dailyStreak > 0) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.streakBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '${calorieProvider.dailyStreak} Days',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.streakColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (authProvider.isSignedIn)
          GestureDetector(
            onTap: () => _showProfileSheet(context, authProvider),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryMint, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryMint.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(authProvider.userInitials,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
      ],
    );
  }

  static void _showProfileSheet(
      BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryMint, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(authProvider.userInitials,
                    style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Text(authProvider.userName,
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(authProvider.userEmail,
                style: GoogleFonts.outfit(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const SignInScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text('Sign Out',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.secondaryCoral,
                  side: BorderSide(
                      color: AppTheme.secondaryCoral.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Calorie Progress Card
  // ---------------------------------------------------------------------------
  static Widget _buildCalorieCard(
      BuildContext context, CalorieProvider provider) {
    final progress = provider.calorieProgress.clamp(0.0, 1.0);
    final isOverGoal = provider.totalCalories > provider.dailyGoal;
    final progressColor =
        isOverGoal ? AppTheme.secondaryCoral : AppTheme.primaryMint;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surfaceWhite,
            AppTheme.primaryMint.withOpacity(0.04)
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMint.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 68,
            lineWidth: 12,
            percent: progress,
            animation: true,
            animationDuration: 1200,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: progressColor,
            backgroundColor: AppTheme.cardGrey,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: provider.totalCalories),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(value.toInt().toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ));
                  },
                ),
                Text('kcal',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textTertiary,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isOverGoal ? 'Over Goal!' : 'Remaining',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isOverGoal
                          ? AppTheme.secondaryCoral
                          : AppTheme.textSecondary,
                    )),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween:
                      Tween(begin: 0, end: provider.remainingCalories.abs()),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text('${value.toInt()} kcal',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isOverGoal
                              ? AppTheme.secondaryCoral
                              : AppTheme.textPrimary,
                        ));
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint,
                          borderRadius: BorderRadius.circular(4),
                        )),
                    const SizedBox(width: 6),
                    Text('Goal: ${provider.dailyGoal.toInt()} kcal',
                        style: GoogleFonts.outfit(
                            fontSize: 13, color: AppTheme.textTertiary)),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showEditGoalDialog(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded,
                            size: 14, color: AppTheme.primaryMint),
                        const SizedBox(width: 6),
                        Text('Edit Goal',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryMint,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _showEditGoalDialog(
      BuildContext context, CalorieProvider provider) {
    final controller =
        TextEditingController(text: provider.dailyGoal.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Edit Daily Goal',
            style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set your daily calorie target',
                style: GoogleFonts.outfit(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'e.g. 2000', suffixText: 'kcal'),
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    GoogleFonts.outfit(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                provider.updateDailyGoal(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Macro Breakdown Row
  // ---------------------------------------------------------------------------
  static Widget _buildMacroRow(CalorieProvider provider) {
    return Row(
      children: [
        Expanded(
            child: _MacroCard(
          label: 'Protein',
          value: provider.totalProtein,
          goal: provider.proteinGoal,
          unit: 'g',
          color: AppTheme.proteinColor,
          icon: Icons.fitness_center_rounded,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _MacroCard(
          label: 'Carbs',
          value: provider.totalCarbs,
          goal: provider.carbsGoal,
          unit: 'g',
          color: AppTheme.carbsColor,
          icon: Icons.grain_rounded,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _MacroCard(
          label: 'Fats',
          value: provider.totalFats,
          goal: provider.fatsGoal,
          unit: 'g',
          color: AppTheme.fatsColor,
          icon: Icons.water_drop_rounded,
        )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Water Intake Tracker
  // ---------------------------------------------------------------------------
  static Widget _buildWaterTracker(
      BuildContext context, CalorieProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.waterColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.waterColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop_rounded,
                    color: AppTheme.waterColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Water Intake',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        )),
                    Text(
                      '${provider.waterConsumedLiters.toStringAsFixed(1)}L / ${provider.waterGoal.toStringAsFixed(1)}L',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              Text('${provider.waterGlasses}',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.waterColor,
                  )),
              const Text(' 🥤', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 14),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8,
            percent: provider.waterProgress,
            animation: true,
            animationDuration: 800,
            barRadius: const Radius.circular(4),
            progressColor: AppTheme.waterColor,
            backgroundColor: AppTheme.waterColor.withOpacity(0.12),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _WaterButton(
                label: '-1',
                onTap: () => provider.removeWater(),
              ),
              const SizedBox(width: 12),
              _WaterButton(
                label: '+1 Glass (250ml)',
                onTap: () => provider.addWater(glasses: 1),
                isPrimary: true,
              ),
              const SizedBox(width: 12),
              _WaterButton(
                label: '+2 (500ml)',
                onTap: () => provider.addWater(glasses: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------
  static Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardGrey, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryMint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.restaurant_rounded,
                size: 36, color: AppTheme.primaryMint),
          ),
          const SizedBox(height: 16),
          Text('No meals logged yet',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 8),
          Text(
              'Tap the "Log Food" button below to\nscan your first meal with AI!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Food Item Card
  // ---------------------------------------------------------------------------
  static Widget _buildFoodItemCard(
      BuildContext context, dynamic item, CalorieProvider provider) {
    final foodIcons = {
      'roti': '🫓', 'chapati': '🫓', 'naan': '🫓', 'paratha': '🫓',
      'puri': '🫓', 'dal': '🥘', 'paneer': '🧀', 'palak': '🥬',
      'chicken': '🍗', 'biryani': '🍛', 'idli': '🍘', 'dosa': '🫓',
      'vada': '🍩', 'upma': '🍚', 'uttapam': '🫓', 'samosa': '🥟',
      'poha': '🍚', 'chole': '🥘', 'bhature': '🫓', 'rajma': '🥘',
      'aloo': '🥔', 'bhindi': '🥬', 'chai': '🍵', 'lassi': '🥛',
      'mango': '🥭', 'gulab': '🍩', 'rasgulla': '🍡', 'kheer': '🍮',
      'salad': '🥗', 'pizza': '🍕', 'burger': '🍔', 'egg': '🥚',
      'rice': '🍚', 'banana': '🍌', 'apple': '🍎', 'yogurt': '🫐',
      'oatmeal': '🥣', 'latte': '☕', 'coffee': '☕', 'protein': '🥤',
      'coconut': '🥥', 'nut': '🥜', 'butter': '🧈', 'pulao': '🍚',
      'pav': '🍞', 'tikka': '🍛', 'masala': '🍛',
    };

    String icon = '🍽️';
    final nameLower = item.name.toLowerCase();
    for (final entry in foodIcons.entries) {
      if (nameLower.contains(entry.key)) {
        icon = entry.value;
        break;
      }
    }

    final timeFormat = DateFormat('h:mm a');

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.removeFoodItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${item.name} removed', style: GoogleFonts.outfit()),
            backgroundColor: AppTheme.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppTheme.primaryMint,
              onPressed: () {
                provider.addFoodItem(
                  name: item.name,
                  calories: item.calories,
                  protein: item.protein,
                  carbs: item.carbs,
                  fats: item.fats,
                  imagePath: item.imagePath,
                  isAIScanned: item.isAIScanned,
                );
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.secondaryCoral.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded,
            color: AppTheme.secondaryCoral),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.cardGrey,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(item.name,
                            style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    if (item.isAIScanned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 12,
                                  color: AppTheme.primaryMint),
                              const SizedBox(width: 4),
                              Text('AI',
                                  style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryMint)),
                            ]),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('${item.calories.toInt()} kcal',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryMint)),
                    const SizedBox(width: 12),
                    Text('P:${item.protein.toInt()}g',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.proteinColor)),
                    const SizedBox(width: 8),
                    Text('C:${item.carbs.toInt()}g',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: AppTheme.carbsColor)),
                    const SizedBox(width: 8),
                    Text('F:${item.fats.toInt()}g',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: AppTheme.fatsColor)),
                    const Spacer(),
                    Text(timeFormat.format(item.loggedAt),
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textTertiary)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _WaterButton
// =============================================================================
class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _WaterButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isPrimary ? 2 : 1,
      child: Material(
        color: isPrimary
            ? AppTheme.waterColor.withOpacity(0.12)
            : AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(label,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPrimary
                        ? AppTheme.waterColor
                        : AppTheme.textSecondary,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _MacroCard
// =============================================================================
class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary)),
          ]),
          const SizedBox(height: 8),
          Text('${value.toInt()}$unit',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 6,
            percent: progress,
            animation: true,
            animationDuration: 1000,
            barRadius: const Radius.circular(3),
            progressColor: color,
            backgroundColor: color.withOpacity(0.12),
          ),
          const SizedBox(height: 4),
          Text('/ ${goal.toInt()}$unit',
              style: GoogleFonts.outfit(
                  fontSize: 11, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}
