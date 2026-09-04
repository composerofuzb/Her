import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/score_ring_widget.dart';
import '../../core/widgets/streak_fire_widget.dart';
import '../../core/widgets/xp_bar_widget.dart';
import '../../core/widgets/mission_card_widget.dart';
import '../../core/widgets/star_path_button.dart';

Widget _wrapInTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.deepSpace,
      body: Center(child: Padding(padding: const EdgeInsets.all(20), child: child)),
    ),
  );
}

Widget previewScoreRing() => _wrapInTheme(
      const ScoreRingWidget(score: 88, size: 140),
    );

Widget previewStreakFire() => _wrapInTheme(
      const StreakFireWidget(streakDays: 14),
    );

Widget previewXpBar() => _wrapInTheme(
      const XpBarWidget(currentXp: 750, maxXp: 900, level: 4),
    );

Widget previewMissionCard() => _wrapInTheme(
      const MissionCardWidget(
        emoji: '📚',
        title: 'Complete all homework',
        xpReward: 25,
        completed: false,
      ),
    );

Widget previewStarPathButton() => _wrapInTheme(
      const StarPathButton(label: 'Level Up! 🌟'),
    );
