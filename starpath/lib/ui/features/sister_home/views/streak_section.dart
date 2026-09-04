import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/streak_fire_widget.dart';

class StreakSection extends StatelessWidget {
  final int streakDays;
  final int streakFreezes;

  const StreakSection({
    super.key,
    required this.streakDays,
    required this.streakFreezes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.nebulaCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: streakDays > 0 ? AppColors.flameOrange.withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreakFireWidget(streakDays: streakDays),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Text('🧊', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$streakFreezes Freeze',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.lightBlueAccent,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
