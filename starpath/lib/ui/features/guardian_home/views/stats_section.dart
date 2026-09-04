import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/daily_log.dart';

class StatsSection extends StatelessWidget {
  final int? todayScore;
  final int weeklyScore;
  final ({String label, String emoji}) tier;
  final int streakDays;
  final List<DailyLog> recentLogs;

  const StatsSection({
    super.key,
    required this.todayScore,
    required this.weeklyScore,
    required this.tier,
    required this.streakDays,
    required this.recentLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 3 Stat cards row
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'TODAY',
                value: todayScore != null ? '$todayScore' : '--',
                subtitle: todayScore != null ? 'Score' : 'Not logged',
                color: todayScore != null ? AppColors.forScore(todayScore!) : Colors.white38,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                title: 'THIS WEEK',
                value: '$weeklyScore',
                subtitle: '${tier.emoji} ${tier.label}',
                color: AppColors.forScore(weeklyScore),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                title: 'STREAK',
                value: '$streakDays',
                subtitle: 'Days 🔥',
                color: AppColors.flameOrange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 7-day fl_chart BarChart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.nebulaCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('7-Day Trend', style: AppTypography.titleMedium),
              const SizedBox(height: 4),
              Text('Recent performance scores', style: AppTypography.bodySmall),
              const SizedBox(height: 24),
              SizedBox(
                height: 150,
                child: recentLogs.isEmpty
                    ? Center(
                        child: Text('No daily logs yet', style: AppTypography.bodySmall),
                      )
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < recentLogs.length) {
                                    final date = recentLogs[idx].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        date.substring(date.length - 2),
                                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: recentLogs.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final log = entry.value;
                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: log.score.toDouble(),
                                  color: AppColors.forScore(log.score),
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.nebulaCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelLarge.copyWith(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white60,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
