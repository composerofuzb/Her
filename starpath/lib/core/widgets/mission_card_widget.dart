import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A gamified mission card with completion state animation
class MissionCardWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final int xpReward;
  final bool completed;
  final VoidCallback? onTap;

  const MissionCardWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.xpReward,
    required this.completed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.cosmicPurple.withOpacity(0.15)
            : AppColors.nebulaCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completed
              ? AppColors.cosmicPurple.withOpacity(0.5)
              : Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Completion checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? AppColors.xpGreen
                      : Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: completed ? AppColors.xpGreen : Colors.white24,
                    width: 2,
                  ),
                ),
                child: completed
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              )
                  .animate(target: completed ? 1 : 0)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(width: 12),

              // Emoji
              Text(emoji, style: const TextStyle(fontSize: 20)),

              const SizedBox(width: 10),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: completed ? Colors.white54 : Colors.white,
                    decoration: completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Colors.white38,
                  ),
                ),
              ),

              // XP reward badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.xpGreen.withOpacity(0.2)
                      : AppColors.starGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: completed
                        ? AppColors.xpGreen.withOpacity(0.5)
                        : AppColors.starGold.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '+$xpReward XP',
                  style: AppTypography.labelLarge.copyWith(
                    color: completed ? AppColors.xpGreen : AppColors.starGold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
