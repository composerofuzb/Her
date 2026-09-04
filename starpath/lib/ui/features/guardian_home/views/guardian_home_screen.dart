import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/star_path_button.dart';
import '../view_models/guardian_home_view_model.dart';
import 'stats_section.dart';
import 'screen_time_card.dart';
import 'ml_insights_card.dart';
import '../../auth/views/qr_pairing_dialog.dart';

class GuardianHomeScreen extends ConsumerWidget {
  const GuardianHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guardianHomeViewModelProvider);
    final sister = state.sister;
    final sisterName = sister?.displayName.isNotEmpty == true ? sister!.displayName : 'Maya';
    final todayLog = state.todayLog;
    final recentLogs = state.logs;

    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text('🛡️ ', style: TextStyle(fontSize: 22)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guardian Portal', style: AppTypography.titleMedium),
                Text('Tracking $sisterName', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: AppColors.starGold),
            tooltip: 'Pair Sister Phone',
            onPressed: () => QrPairingDialog.show(
              context,
              sisterName: sisterName,
              sisterEmail: 'sister@starpath.app',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            tooltip: 'Settings',
            onPressed: () => context.push('/guardian/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white38),
            tooltip: 'Sign Out',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Reminder banner if today not logged
              if (todayLog == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.starGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.starGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('📝', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s log is pending',
                              style: AppTypography.titleMedium.copyWith(color: AppColors.starGold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Enter today\'s marks to keep $sisterName\'s streak alive!',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.starGold,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => context.push('/guardian/log'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Stats and Chart Section
              StatsSection(
                todayScore: todayLog?.score,
                weeklyScore: state.weeklyScore,
                tier: state.tier,
                streakDays: sister?.streakDays ?? 0,
                recentLogs: recentLogs,
              ),

              const SizedBox(height: 20),

              // Screen Time Card (Android UsageStats integration)
              const ScreenTimeCard(),

              const SizedBox(height: 20),

              // Machine Learning Insights Card
              MlInsightsCard(insights: state.insights),

              const SizedBox(height: 24),

              // Recent entries list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Daily Logs', style: AppTypography.titleMedium),
                  TextButton(
                    onPressed: () => context.push('/guardian/log'),
                    child: const Text('+ New Log', style: TextStyle(color: AppColors.cosmicPurpleLight)),
                  ),

                ],
              ),
              const SizedBox(height: 8),

              if (recentLogs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.nebulaCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 10),
                        Text('No logs recorded yet', style: AppTypography.bodyMedium),
                        const SizedBox(height: 14),
                        StarPathButton(
                          label: 'Log First Day',
                          onPressed: () => context.push('/guardian/log'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentLogs.map((log) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.nebulaCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.forScore(log.score).withOpacity(0.15),
                            border: Border.all(color: AppColors.forScore(log.score)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${log.score}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.forScore(log.score),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.date, style: AppTypography.titleMedium),
                              Text(
                                'Behavior: ${log.behavior} · +${log.xpAwarded} XP',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white24),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cosmicPurple,
        icon: const Icon(Icons.edit_calendar, color: Colors.white),
        label: const Text('Log Performance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => context.push('/guardian/log'),
      ),
    );
  }
}
