import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/mission_card_widget.dart';
import '../../../../domain/models/mission.dart';

class MissionsSection extends StatelessWidget {
  final List<Mission> missions;

  const MissionsSection({super.key, required this.missions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('🎯 Daily Missions', style: AppTypography.headlineSmall),
            Text(
              '${missions.where((m) => m.completed).length}/${missions.length} Done',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...missions.asMap().entries.map((entry) {
          final idx = entry.key;
          final mission = entry.value;
          return MissionCardWidget(
            emoji: mission.emoji,
            title: mission.title,
            xpReward: mission.xpReward,
            completed: mission.completed,
          ).animate(delay: (idx * 50).ms).fadeIn().slideY(begin: 0.1, end: 0);
        }),
      ],
    );
  }
}
