import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/services/screen_time_service.dart';

class ScreenTimeCard extends ConsumerWidget {
  const ScreenTimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenTimeAsync = ref.watch(screenTimeDataProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.nebulaCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: screenTimeAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: AppColors.cosmicPurple),
          ),
        ),
        error: (err, _) => Center(
          child: Text('Screen time unavailable: $err', style: AppTypography.bodySmall),
        ),
        data: (data) {
          final totalHours = data.totalMinutes ~/ 60;
          final totalRemainingMins = data.totalMinutes % 60;
          final sortedApps = data.apps.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('📱', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text('Today\'s Screen Time', style: AppTypography.titleMedium),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cosmicPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${totalHours}h ${totalRemainingMins}m',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.cosmicPurpleLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (!data.hasPermission) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.starGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.starGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.starGold, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing simulated usage. Grant Android Usage Access to sync live phone data.',
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => ref.read(screenTimeServiceProvider).requestPermission(),
                        child: const Text('Enable', style: TextStyle(color: AppColors.starGold, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Top apps breakdown
              ...sortedApps.take(4).map((entry) {
                final parsed = ScreenTimeData.parsePackage(entry.key);
                final appMins = entry.value;
                final fraction = data.totalMinutes > 0 ? (appMins / data.totalMinutes).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(parsed.emoji, style: const TextStyle(fontSize: 15)),
                              const SizedBox(width: 8),
                              Text(parsed.name, style: AppTypography.bodyMedium),
                            ],
                          ),
                          Text(
                            '${appMins}m',
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 5,
                          backgroundColor: Colors.white10,
                          color: _colorForCategory(parsed.category),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Gaming':
        return Colors.orangeAccent;
      case 'Entertainment':
        return Colors.redAccent;
      case 'Education':
        return AppColors.xpGreen;
      case 'Social':
        return Colors.pinkAccent;
      default:
        return AppColors.cosmicPurple;
    }
  }
}
