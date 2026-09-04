import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated XP progress bar widget
class XpBarWidget extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final int level;
  final bool animate;

  const XpBarWidget({
    super.key,
    required this.currentXp,
    required this.maxXp,
    required this.level,
    this.animate = true,
  });

  double get progress => maxXp > 0 ? (currentXp / maxXp).clamp(0.0, 1.0) : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.starGold,
              ),
            ),
            Text(
              '$currentXp / $maxXp XP',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Background track
              Container(
                height: 12,
                color: AppColors.nebulaDark,
              ),
              // Filled portion
              if (animate)
                _AnimatedFill(progress: progress)
              else
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.cosmicPurple, AppColors.starGold],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedFill extends StatefulWidget {
  final double progress;

  const _AnimatedFill({required this.progress});

  @override
  State<_AnimatedFill> createState() => _AnimatedFillState();
}

class _AnimatedFillState extends State<_AnimatedFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedFill old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _anim = Tween<double>(begin: _anim.value, end: widget.progress).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      );
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => FractionallySizedBox(
        widthFactor: _anim.value,
        child: child,
      ),
      child: Container(
        height: 12,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.cosmicPurple, AppColors.starGold],
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 1500.ms,
            color: Colors.white.withOpacity(0.3),
          ),
    );
  }
}
