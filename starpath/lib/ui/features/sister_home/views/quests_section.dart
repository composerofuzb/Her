import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/weekly_quest.dart';

class QuestsSection extends StatelessWidget {
  final List<WeeklyQuest> quests;

  const QuestsSection({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('⚔️ Weekly Quests', style: AppTypography.headlineSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cosmicPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cosmicPurple.withOpacity(0.4)),
              ),
              child: Text(
                '${quests.where((q) => q.completed).length}/${quests.length} Completed',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cosmicPurpleLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...quests.asMap().entries.map((entry) {
          final idx = entry.key;
          final quest = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: quest.completed
                  ? AppColors.cosmicPurple.withOpacity(0.15)
                  : AppColors.nebulaCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: quest.completed
                    ? AppColors.starGold.withOpacity(0.5)
                    : Colors.white.withOpacity(0.06),
                width: quest.completed ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quest.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(quest.title, style: AppTypography.titleMedium),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: quest.completed
                                      ? AppColors.xpGreen.withOpacity(0.2)
                                      : AppColors.starGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+${quest.xpReward} XP',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: quest.completed ? AppColors.xpGreen : AppColors.starGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(quest.description, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quest Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: quest.progressFraction,
                          backgroundColor: Colors.white10,
                          color: quest.completed ? AppColors.xpGreen : AppColors.cosmicPurple,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${quest.currentProgress} / ${quest.targetProgress}',
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: (idx * 60).ms).fadeIn().slideY(begin: 0.1, end: 0);
        }),
      ],
    );
  }
}
