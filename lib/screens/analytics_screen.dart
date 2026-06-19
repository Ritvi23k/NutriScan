// =============================================================================
// screens/analytics_screen.dart
// =============================================================================
// Full analytics dashboard with:
//   1. Interactive 7-day bar chart (fl_chart)
//   2. Macro distribution pie chart (fl_chart)
//   3. 30-day history log with color-coded indicators
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/calorie_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  int _touchedBarIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final provider = context.read<CalorieProvider>();
    final weekly = await provider.getWeeklyData();
    final history = await provider.getHistory(days: 30);

    if (mounted) {
      setState(() {
        _weeklyData = weekly;
        _history = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalorieProvider>();

    return SafeArea(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryMint),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your nutrition insights & history',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 7-Day Bar Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildWeeklyBarChart(provider.dailyGoal),
                  ),
                ),

                // Macro Distribution Pie Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildMacroPieChart(),
                  ),
                ),

                // 30-Day History Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.accentBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '30-Day History',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_history.length} days',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 30-Day History List
                if (_history.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyHistory())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildHistoryCard(_history[index], provider.dailyGoal),
                        childCount: _history.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7-Day Bar Chart
  // ---------------------------------------------------------------------------
  Widget _buildWeeklyBarChart(double dailyGoal) {
    final maxCalories = _weeklyData.fold<double>(
      dailyGoal * 1.2,
      (max, d) => (d['calories'] as num).toDouble() > max
          ? (d['calories'] as num).toDouble()
          : max,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.accentPurple.withOpacity(0.15),
                    AppTheme.primaryMint.withOpacity(0.1),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppTheme.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7-Day Calorie Intake',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        )),
                    Text('vs your ${dailyGoal.toInt()} kcal goal',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCalories * 1.15,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        AppTheme.textPrimary.withOpacity(0.9),
                    // tooltipRoundedRadius: 12, (removed for compatibility)
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final cal = rod.toY.toInt();
                      return BarTooltipItem(
                        '$cal kcal',
                        GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      if (response != null &&
                          response.spot != null &&
                          event is! FlPointerExitEvent) {
                        _touchedBarIndex =
                            response.spot!.touchedBarGroupIndex;
                      } else {
                        _touchedBarIndex = -1;
                      }
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _weeklyData.length) {
                          final label =
                              _weeklyData[index]['label'] as String;
                          final isToday =
                              index == _weeklyData.length - 1;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isToday
                                    ? AppTheme.primaryMint
                                    : AppTheme.textTertiary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: dailyGoal,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textTertiary.withOpacity(0.2),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    _weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final calories =
                      (data['calories'] as num).toDouble();
                  final isOverGoal = calories > dailyGoal;
                  final isToday = index == _weeklyData.length - 1;
                  final isTouched = index == _touchedBarIndex;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: calories,
                        width: isTouched ? 20 : 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isOverGoal
                              ? [
                                  AppTheme.secondaryCoral
                                      .withOpacity(0.6),
                                  AppTheme.secondaryCoral,
                                ]
                              : isToday
                                  ? [
                                      AppTheme.primaryMint
                                          .withOpacity(0.7),
                                      AppTheme.primaryMint,
                                    ]
                                  : [
                                      AppTheme.primaryMint
                                          .withOpacity(0.4),
                                      AppTheme.primaryMint
                                          .withOpacity(0.7),
                                    ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppTheme.primaryMint, 'Within Goal'),
              const SizedBox(width: 20),
              _legendDot(AppTheme.secondaryCoral, 'Over Goal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Macro Distribution Pie Chart
  // ---------------------------------------------------------------------------
  Widget _buildMacroPieChart() {
    double totalProtein = 0, totalCarbs = 0, totalFats = 0;

    for (final entry in _history.take(7)) {
      totalProtein += (entry['totalProtein'] as num).toDouble();
      totalCarbs += (entry['totalCarbs'] as num).toDouble();
      totalFats += (entry['totalFats'] as num).toDouble();
    }

    final provider = context.read<CalorieProvider>();
    totalProtein += provider.totalProtein;
    totalCarbs += provider.totalCarbs;
    totalFats += provider.totalFats;

    final total = totalProtein + totalCarbs + totalFats;
    final proteinPct = total > 0 ? (totalProtein / total * 100) : 33.0;
    final carbsPct = total > 0 ? (totalCarbs / total * 100) : 34.0;
    final fatsPct = total > 0 ? (totalFats / total * 100) : 33.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.accentBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Macro Distribution',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      )),
                  Text('Weekly average breakdown',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 32,
                    sections: [
                      PieChartSectionData(
                        color: AppTheme.proteinColor,
                        value: proteinPct,
                        title: '${proteinPct.toInt()}%',
                        radius: 36,
                        titleStyle: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: AppTheme.carbsColor,
                        value: carbsPct,
                        title: '${carbsPct.toInt()}%',
                        radius: 36,
                        titleStyle: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: AppTheme.fatsColor,
                        value: fatsPct,
                        title: '${fatsPct.toInt()}%',
                        radius: 36,
                        titleStyle: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _macroPieLegend('Protein', '${totalProtein.toInt()}g',
                        AppTheme.proteinColor, Icons.fitness_center_rounded),
                    const SizedBox(height: 14),
                    _macroPieLegend('Carbs', '${totalCarbs.toInt()}g',
                        AppTheme.carbsColor, Icons.grain_rounded),
                    const SizedBox(height: 14),
                    _macroPieLegend('Fats', '${totalFats.toInt()}g',
                        AppTheme.fatsColor, Icons.water_drop_rounded),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroPieLegend(
      String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                )),
            Text(value,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                )),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Empty History State
  // ---------------------------------------------------------------------------
  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.history_rounded,
                size: 40, color: AppTheme.accentPurple),
          ),
          const SizedBox(height: 20),
          Text('No history yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 8),
          Text('Start logging your meals and your\nhistory will appear here!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // History Card with color-coded status
  // ---------------------------------------------------------------------------
  Widget _buildHistoryCard(Map<String, dynamic> entry, double dailyGoal) {
    final date = entry['date'] as DateTime;
    final totalCalories = entry['totalCalories'] as double;
    final itemCount = entry['itemCount'] as int;

    final dateFormat = DateFormat('EEEE, MMM d');
    final isToday = _isToday(date);
    final isYesterday = _isYesterday(date);
    final progress = (totalCalories / dailyGoal).clamp(0.0, 1.0);

    final ratio = totalCalories / dailyGoal;
    Color statusColor;
    String statusLabel;
    if (ratio <= 0.9) {
      statusColor = AppTheme.statusGreen;
      statusLabel = 'Under';
    } else if (ratio <= 1.1) {
      statusColor = AppTheme.statusYellow;
      statusLabel = 'On Track';
    } else {
      statusColor = AppTheme.statusRed;
      statusLabel = 'Over';
    }

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today';
    } else if (isYesterday) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = dateFormat.format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(statusLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${totalCalories.toInt()} kcal',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        )),
                    Text(' / ${dailyGoal.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textTertiary,
                        )),
                    const Spacer(),
                    Text('$itemCount items',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 6,
                  percent: progress,
                  barRadius: const Radius.circular(3),
                  progressColor: statusColor,
                  backgroundColor: statusColor.withOpacity(0.12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
