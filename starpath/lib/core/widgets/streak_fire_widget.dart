import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated streak flame widget that grows with streak count
class StreakFireWidget extends StatelessWidget {
  final int streakDays;

  const StreakFireWidget({super.key, required this.streakDays});

  String get _emoji {
    if (streakDays >= 30) return '🔥';
    if (streakDays >= 14) return '🔥';
    if (streakDays >= 7) return '🔥';
    return '🔥';
  }

  double get _flameSize {
    if (streakDays >= 30) return 52;
    if (streakDays >= 14) return 44;
    if (streakDays >= 7) return 38;
    return 32;
  }

  Color get _flameColor => AppColors.forStreak(streakDays);

  Duration get _pulseDuration {
    if (streakDays >= 14) return const Duration(milliseconds: 700);
    if (streakDays >= 7) return const Duration(milliseconds: 900);
    return const Duration(milliseconds: 1200);
  }

  @override
  Widget build(BuildContext context) {
    final Widget flame = Text(
      _emoji,
      style: TextStyle(fontSize: _flameSize),
    );

    final Widget animatedFlame;

    if (streakDays >= 30) {
      // Epic multi-color shimmer
      animatedFlame = flame
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 500.ms,
            color: Colors.purpleAccent.withOpacity(0.6),
          )
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05),
            duration: _pulseDuration,
            curve: Curves.easeInOut,
          );
    } else if (streakDays >= 14) {
      // Large red flame with shimmer
      animatedFlame = flame
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 600.ms,
            color: AppColors.flameOrange.withOpacity(0.5),
          )
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05),
            duration: _pulseDuration,
            curve: Curves.easeInOut,
          );
    } else if (streakDays >= 7) {
      // Medium orange flame
      animatedFlame = flame
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05),
            duration: _pulseDuration,
            curve: Curves.easeInOut,
          );
    } else {
      // Small yellow flame
      animatedFlame = flame
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1.08, 1.08),
            duration: _pulseDuration,
            curve: Curves.easeInOut,
          );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        animatedFlame,
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$streakDays-DAY STREAK',
              style: AppTypography.headlineSmall.copyWith(
                color: _flameColor,
                letterSpacing: 1,
              ),
            ),
            if (streakDays >= 7)
              Text(
                _milestoneLabel,
                style: AppTypography.bodySmall.copyWith(
                  color: _flameColor.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String get _milestoneLabel {
    if (streakDays >= 30) return '🏆 Month Warrior!';
    if (streakDays >= 14) return '🌟 Two Weeks Strong!';
    if (streakDays >= 7) return '⚡ One Week Done!';
    return '';
  }
}
