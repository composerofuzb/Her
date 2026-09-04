import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/animations/starpath_fx.dart';
import '../../../../core/animations/animation_event.dart';
import '../../../../data/models/achievement_model.dart';
import '../../../../data/repositories/achievement_repository.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedAchievementsProvider).value ?? [];
    final unlockedIds = unlocked.map((a) => a.badgeId).toSet();
    const badges = BadgeCatalog.badges;


    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Badges & Trophies', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unlocked: ${unlocked.length}/${badges.length}',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.starGold),
                  ),
                  Text(
                    'Total XP: ${unlocked.fold<int>(0, (sum, b) => sum + b.xpAwarded)} XP ⭐',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  // Default unlocked for demo if list empty
                  final isUnlocked = unlockedIds.contains(badge.id) ||
                      (unlocked.isEmpty && ['first_flame', 'scholar'].contains(badge.id));

                  return GestureDetector(
                    onTap: () {
                      if (isUnlocked) {
                        StarPathFX.trigger(
                          AnimationEvent.badgeUnlocked,
                          context: context,
                          badgeTitle: badge.title,
                          badgeEmoji: badge.emoji,
                          badgeDescription: badge.description,
                          value: 50,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🔒 Locked: ${badge.description}'),
                            backgroundColor: AppColors.nebulaCard,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.nebulaCard
                            : AppColors.nebulaDark.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUnlocked
                              ? AppColors.starGold.withOpacity(0.5)
                              : Colors.white.withOpacity(0.05),
                          width: isUnlocked ? 1.5 : 1,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: AppColors.starGold.withOpacity(0.12),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            badge.emoji,
                            style: TextStyle(
                              fontSize: 42,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            badge.title,
                            style: AppTypography.titleMedium.copyWith(
                              color: isUnlocked ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge.description,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: isUnlocked ? Colors.white60 : Colors.white24,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? AppColors.xpGreen.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isUnlocked ? 'Unlocked ✅' : 'Locked 🔒',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? AppColors.xpGreen : Colors.white38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
