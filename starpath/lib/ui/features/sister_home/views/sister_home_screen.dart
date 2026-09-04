import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/xp_bar_widget.dart';
import '../../../../core/widgets/score_ring_widget.dart';
import '../../../../core/animations/starpath_fx.dart';
import '../../../../core/animations/animation_event.dart';
import '../../../../domain/models/character_customization.dart';
import '../../../../domain/models/developmental_stage.dart';
import '../../../../domain/use_cases/developmental_stage_engine.dart';
import '../../character/widgets/living_character_widget.dart';
import 'ai_coach_card.dart';
import '../view_models/sister_home_view_model.dart';
import 'streak_section.dart';
import 'missions_section.dart';
import 'quests_section.dart';
import '../../../../core/performance/performance_mode.dart';

class SisterHomeScreen extends ConsumerWidget {
  const SisterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sisterHomeViewModelProvider);
    final vm = ref.read(sisterHomeViewModelProvider.notifier);
    final sister = state.sister;
    final todayLog = state.todayLog;

    final displayName = sister?.displayName.isNotEmpty == true ? sister!.displayName : 'Maya';
    final currentXp = sister?.xp ?? 750;
    final level = sister?.level ?? 4;
    final maxXp = sister?.xpForNextLevel ?? 900;
    final streakDays = sister?.streakDays ?? 14;
    final streakFreezes = sister?.streakFreezes ?? 1;
    final levelTitle = sister?.levelTitle ?? 'Rising Star';
    final todayScore = todayLog?.score ?? 88;

    // Developmental Stage & Character computation
    final character = sister?.character ?? const CharacterCustomization();
    final stage = sister != null
        ? DevelopmentalStageEngine.resolveStage(sister: sister)
        : DevelopmentalStage.middleSchool;
    final birthDate = DateTime.tryParse(sister?.birthDate ?? '2014-01-12') ??
        DevelopmentalStageEngine.defaultBirthDate;
    final currentAge = sister?.simulatedAge ??
        DevelopmentalStageEngine.calculateAge(birthDate);
    final daysToBday = DevelopmentalStageEngine.daysUntilBirthday(birthDate);
    final mood = character.evaluateMood(
      todayScore: todayScore,
      streakDays: streakDays,
    );

    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Check for new achievements
            final newlyEarned = await vm.checkForNewAchievements();
            if (context.mounted && newlyEarned.isNotEmpty) {
              final badge = newlyEarned.first;
              await StarPathFX.trigger(
                AnimationEvent.badgeUnlocked,
                context: context,
                badgeTitle: badge.title,
                badgeEmoji: badge.emoji,
                badgeDescription: badge.description,
                value: 50,
              );
            } else if (context.mounted) {
              await StarPathFX.trigger(
                AnimationEvent.xpGained,
                context: context,
                value: 10,
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back,', style: AppTypography.bodySmall),
                        Text(
                          '$displayName! 👋',
                          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final current = ref.read(performanceModeProvider).isLiteMode;
                            ref.read(performanceModeProvider.notifier).setLiteMode(!current);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(!current
                                    ? '⚡ Redmi 7 Lite Mode: Active (Smooth & Low-RAM)'
                                    : '✨ Normal Mode: Active'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: !current ? AppColors.xpGreenDark : AppColors.cosmicPurple,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: ref.watch(performanceModeProvider).isLiteMode
                                  ? AppColors.xpGreen.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: ref.watch(performanceModeProvider).isLiteMode
                                    ? AppColors.xpGreen
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '⚡',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ref.watch(performanceModeProvider).isLiteMode
                                        ? AppColors.xpGreen
                                        : Colors.white54,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Lite',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ref.watch(performanceModeProvider).isLiteMode
                                        ? AppColors.xpGreen
                                        : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.palette_outlined, color: AppColors.starGold, size: 24),
                          tooltip: 'Customize Character',
                          onPressed: () => context.push('/sister/character'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_events_outlined, color: AppColors.starGold, size: 26),
                          tooltip: 'Achievements',
                          onPressed: () => context.push('/sister/achievements'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white38, size: 20),
                          tooltip: 'Sign Out',
                          onPressed: () => context.go('/login'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Animated Living Vector Character & Level Badge
                Center(
                  child: Column(
                    children: [
                      // Developmental Stage & Birthday Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: stage.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: stage.primaryColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(stage.emoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              '${stage.title} · Age $currentAge',
                              style: TextStyle(
                                color: stage.secondaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (daysToBday <= 30) ...[
                              const SizedBox(width: 8),
                              Text(
                                '🎂 ${daysToBday == 0 ? "Birthday Today!" : "$daysToBday d to Jan 12!"}',
                                style: const TextStyle(
                                  color: AppColors.starGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Living Character Vector Widget
                      LivingCharacterWidget(
                        character: character,
                        mood: mood,
                        stage: stage,
                        sisterName: displayName,
                        width: 170,
                        height: 195,
                      ),

                      const SizedBox(height: 6),

                      // Level & Wardrobe Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.starGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.starGold.withOpacity(0.4)),
                            ),
                            child: Text(
                              'Level $level · $levelTitle',
                              style: AppTypography.labelLarge.copyWith(color: AppColors.starGold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.checkroom, size: 14, color: Colors.white70),
                            label: const Text('Wardrobe', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            onPressed: () => context.push('/sister/character'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 20),

                // XP Progress Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.nebulaCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: XpBarWidget(
                    currentXp: currentXp,
                    maxXp: maxXp,
                    level: level,
                  ),
                ),

                const SizedBox(height: 16),

                // Streak Flame Section
                StreakSection(
                  streakDays: streakDays,
                  streakFreezes: streakFreezes,
                ),

                const SizedBox(height: 20),

                // Sunday Reward Chest Mystery Box
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cosmicPurple.withOpacity(0.25),
                        AppColors.nebulaCard,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.starGold.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 36))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.ms),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekend Reward Chest',
                              style: AppTypography.titleMedium.copyWith(color: AppColors.starGold),
                            ),
                            Text(
                              'Earn extra phone screen time & pocket money!',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.starGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          StarPathFX.trigger(
                            AnimationEvent.rewardChestOpened,
                            context: context,
                            rewardTitle: '🥇 Excellent Week Achievement!',
                            rewardSubtitle: '+2 Hours Weekend Screen Time 📱 · +\$10',
                          );
                        },
                        child: const Text('Open 🔓', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Today's Performance Card with ScoreRing
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.nebulaCard,
                        AppColors.cosmicPurple.withOpacity(0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Text('TODAY\'S PERFORMANCE', style: AppTypography.labelLarge.copyWith(color: Colors.white54)),
                      const SizedBox(height: 16),
                      ScoreRingWidget(
                        score: todayScore,
                        size: 150,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Keep up the great work to earn weekend rewards! 📱',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // AI Companion Coach (Multi-Provider Resilience)
                AiCoachCard(
                  sister: sister,
                  todayLog: todayLog,
                  stage: stage,
                ),

                const SizedBox(height: 24),

                // Daily Missions List

                MissionsSection(missions: state.missions),

                const SizedBox(height: 24),

                // Weekly Quests Section
                QuestsSection(quests: state.weeklyQuests),

                const SizedBox(height: 24),

                // FX Celebration & Gamification Engine Triggers
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.nebulaDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✨ Gamification Engine Triggers',
                          style: AppTypography.labelLarge.copyWith(color: Colors.white60)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            avatar: const Text('⭐'),
                            label: const Text('+100 XP Burst'),
                            onPressed: () => StarPathFX.trigger(
                              AnimationEvent.xpGained,
                              context: context,
                              value: 100,
                            ),
                          ),
                          ActionChip(
                            avatar: const Text('🌟'),
                            label: const Text('Level Up Explosion!'),
                            onPressed: () => StarPathFX.trigger(
                              AnimationEvent.levelUp,
                              context: context,
                              level: level + 1,
                            ),
                          ),
                          ActionChip(
                            avatar: const Text('🧊'),
                            label: const Text('Use Streak Freeze'),
                            onPressed: () async {
                              final success = await vm.useStreakFreeze();
                              if (context.mounted && success) {
                                StarPathFX.trigger(
                                  AnimationEvent.freezeUsed,
                                  context: context,
                                );
                              }
                            },
                          ),
                          ActionChip(
                            avatar: const Text('🏆'),
                            label: const Text('Unlock Badge'),
                            onPressed: () => StarPathFX.trigger(
                              AnimationEvent.badgeUnlocked,
                              context: context,
                              badgeTitle: 'Scholar',
                              badgeEmoji: '📚',
                              badgeDescription: '5 consecutive days with 80+ score',
                              value: 50,
                            ),
                          ),
                          ActionChip(
                            avatar: const Text('🎁'),
                            label: const Text('Reward Chest'),
                            onPressed: () => StarPathFX.trigger(
                              AnimationEvent.rewardChestOpened,
                              context: context,
                              rewardTitle: 'Weekend Reward!',
                              rewardSubtitle: '+1 Hour Phone Time 📱',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
