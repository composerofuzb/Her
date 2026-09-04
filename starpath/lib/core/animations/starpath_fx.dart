import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'animation_event.dart';
import 'haptic_choreographer.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// StarPath FX — the central animation orchestrator.
///
/// Call [StarPathFX.trigger] from anywhere to fire a semantic animation.
/// The engine coordinates full-screen overlay visuals + physical haptic feedback.
class StarPathFX {
  StarPathFX._();

  /// Trigger an animation event with optional contextual data.
  static Future<void> trigger(
    AnimationEvent event, {
    required BuildContext context,
    int? value,
    int? level,
    int? streakDays,
    String? badgeTitle,
    String? badgeEmoji,
    String? badgeDescription,
    String? rewardTitle,
    String? rewardSubtitle,
  }) async {
    switch (event) {
      case AnimationEvent.xpGained:
        await HapticChoreographer.onXpGained();
        if (context.mounted) {
          _showXpBurst(context, value ?? 0);
        }

      case AnimationEvent.levelUp:
        await HapticChoreographer.onLevelUp();
        if (context.mounted) {
          _showLevelUpOverlay(context, level ?? 1);
        }

      case AnimationEvent.streakUpdated:
        if ((streakDays ?? 0) % 7 == 0 && (streakDays ?? 0) > 0) {
          await HapticChoreographer.onStreakMilestone();
        }

      case AnimationEvent.missionComplete:
        await HapticChoreographer.onMissionComplete();

      case AnimationEvent.questComplete:
        await HapticChoreographer.onQuestComplete();
        if (context.mounted) {
          _showXpBurst(context, value ?? 50);
        }

      case AnimationEvent.badgeUnlocked:
        await HapticChoreographer.onBadgeUnlocked();
        if (context.mounted) {
          _showBadgeOverlay(
            context,
            title: badgeTitle ?? 'New Badge!',
            emoji: badgeEmoji ?? '🏆',
            description: badgeDescription ?? 'Achievement unlocked!',
            xp: value ?? 50,
          );
        }

      case AnimationEvent.freezeUsed:
        await HapticChoreographer.onFreezeUsed();
        if (context.mounted) {
          _showFreezeOverlay(context);
        }

      case AnimationEvent.rewardChestOpened:
        await HapticChoreographer.onRewardChestOpen();
        if (context.mounted) {
          _showRewardChestOverlay(
            context,
            title: rewardTitle ?? 'Weekend Screen Time Bonus! 📱',
            subtitle: rewardSubtitle ?? '+2 Hours Phone Time · +\$10',
          );
        }

      case AnimationEvent.streakBroken:
        await HapticChoreographer.onStreakBroken();

      case AnimationEvent.dailyLogSaved:
        await HapticChoreographer.onXpGained();
        if (context.mounted) {
          _showXpBurst(context, value ?? 0);
        }
    }
  }

  // ── Overlay Launchers ──────────────────────────────────────────────────────

  static void _showXpBurst(BuildContext context, int xpValue) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _XpBurstOverlay(
        xp: xpValue,
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void _showLevelUpOverlay(BuildContext context, int newLevel) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _LevelUpExplosionOverlay(
        level: newLevel,
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void _showBadgeOverlay(
    BuildContext context, {
    required String title,
    required String emoji,
    required String description,
    required int xp,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _BadgeCelebrationOverlay(
        title: title,
        emoji: emoji,
        description: description,
        xp: xp,
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void _showFreezeOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _StreakFreezeOverlay(
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static void _showRewardChestOverlay(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _RewardChestCelebrationOverlay(
        title: title,
        subtitle: subtitle,
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

// =============================================================================
// 1. XP BURST OVERLAY
// =============================================================================

class _XpBurstOverlay extends StatelessWidget {
  final int xp;
  final VoidCallback onDone;

  const _XpBurstOverlay({required this.xp, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 180,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.cosmicPurple, Color(0xFF4A44CC)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.starGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.starGold.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '+$xp XP',
                  style: AppTypography.xpCounter.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
              .animate(onComplete: (_) => onDone())
              .fadeIn(duration: 180.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.1, 1.1),
                duration: 250.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .moveY(begin: 0, end: -70, duration: 800.ms, curve: Curves.easeOut)
              .fadeOut(delay: 350.ms, duration: 450.ms),
        ),
      ),
    );
  }
}

// =============================================================================
// 2. LEVEL UP EXPLOSION OVERLAY
// =============================================================================

class _LevelUpExplosionOverlay extends StatefulWidget {
  final int level;
  final VoidCallback onDone;

  const _LevelUpExplosionOverlay({required this.level, required this.onDone});

  @override
  State<_LevelUpExplosionOverlay> createState() => _LevelUpExplosionOverlayState();
}

class _LevelUpExplosionOverlayState extends State<_LevelUpExplosionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _raysCtrl;

  @override
  void initState() {
    super.initState();
    _raysCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _raysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onDone,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating sunburst rays
              AnimatedBuilder(
                animation: _raysCtrl,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _raysCtrl.value * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(450, 450),
                      painter: _RaysPainter(color: AppColors.starGold.withOpacity(0.18)),
                    ),
                  );
                },
              ),

              // Celebration content card
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 76))
                      .animate()
                      .scale(
                        begin: const Offset(0.2, 0.2),
                        end: const Offset(1.3, 1.3),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.3, 1.3),
                        end: const Offset(1.0, 1.0),
                        duration: 200.ms,
                      ),
                  const SizedBox(height: 16),
                  Text(
                    'LEVEL UP!',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.starGold,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: AppColors.starGold.withOpacity(0.8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn().scale(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cosmicPurple,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cosmicPurple.withOpacity(0.6),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Text(
                      'Level ${widget.level}',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 28),
                  Text(
                    'Tap anywhere to continue',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white38),
                  ).animate(delay: 800.ms).fadeIn(),
                ],
              ),
            ],
          ),
        )
            .animate(onComplete: (_) {
              Future.delayed(const Duration(milliseconds: 3500), widget.onDone);
            })
            .fadeIn(duration: 250.ms),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  final Color color;

  _RaysPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const count = 16;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * math.cos(angle - 0.1),
          center.dy + radius * math.sin(angle - 0.1),
        )
        ..lineTo(
          center.dx + radius * math.cos(angle + 0.1),
          center.dy + radius * math.sin(angle + 0.1),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.color != color;
}

// =============================================================================
// 3. BADGE CELEBRATION OVERLAY
// =============================================================================

class _BadgeCelebrationOverlay extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final int xp;
  final VoidCallback onDone;

  const _BadgeCelebrationOverlay({
    required this.title,
    required this.emoji,
    required this.description,
    required this.xp,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDone,
        child: Container(
          color: Colors.black.withOpacity(0.75),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.nebulaCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.starGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.starGold.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 64),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.2, 1.2),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0), duration: 200.ms),
                const SizedBox(height: 16),
                Text(
                  'BADGE UNLOCKED!',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.starGold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.xpGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.xpGreen.withOpacity(0.5)),
                  ),
                  child: Text(
                    '+$xp XP Awarded! ⭐',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.xpGreen),
                  ),
                ),
              ],
            ),
          )
              .animate(onComplete: (_) {
                Future.delayed(const Duration(milliseconds: 3000), onDone);
              })
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 250.ms),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. STREAK FREEZE ACTIVATED OVERLAY
// =============================================================================

class _StreakFreezeOverlay extends StatelessWidget {
  final VoidCallback onDone;

  const _StreakFreezeOverlay({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 24,
      right: 24,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.lightBlueAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.lightBlueAccent.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🧊', style: TextStyle(fontSize: 34)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STREAK FROZEN!',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.lightBlueAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Your streak was saved by a Streak Freeze.',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(onComplete: (_) {
              Future.delayed(const Duration(milliseconds: 2800), onDone);
            })
            .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOut)
            .fadeIn(duration: 250.ms)
            .then(delay: 2400.ms)
            .slideY(begin: 0, end: -1, duration: 300.ms)
            .fadeOut(duration: 250.ms),
      ),
    );
  }
}

// =============================================================================
// 5. REWARD CHEST CELEBRATION OVERLAY
// =============================================================================

class _RewardChestCelebrationOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onDone;

  const _RewardChestCelebrationOverlay({
    required this.title,
    required this.subtitle,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDone,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.nebulaCard,
                  AppColors.cosmicPurple.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.starGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.starGold.withOpacity(0.5),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎁', style: TextStyle(fontSize: 72))
                    .animate()
                    .shake(duration: 600.ms)
                    .then()
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.25, 1.25),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 18),
                Text(
                  'WEEKLY REWARD UNLOCKED!',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.starGold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.xpGreen,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.starGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  onPressed: onDone,
                  child: const Text('Claim Reward 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms).fadeIn(),
        ),
      ),
    );
  }
}
