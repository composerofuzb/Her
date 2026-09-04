import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated score ring widget using CustomPainter.
/// Draws an arc from 0° to score/100 * 360° with color gradient.
class ScoreRingWidget extends StatefulWidget {
  final int? score; // null = not logged yet
  final bool animate;
  final double size;

  const ScoreRingWidget({
    super.key,
    this.score,
    this.animate = true,
    this.size = 140,
  });

  @override
  State<ScoreRingWidget> createState() => _ScoreRingWidgetState();
}

class _ScoreRingWidgetState extends State<ScoreRingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final target = (widget.score ?? 0) / 100.0;
    _anim = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.animate) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ScoreRingWidget old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      final target = (widget.score ?? 0) / 100.0;
      _anim = Tween<double>(begin: 0, end: target).animate(
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
    final score = widget.score;
    final tier = score != null ? AppColors.forScore(score) : Colors.white24;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ScoreRingPainter(
              progress: _anim.value,
              color: tier,
              score: score,
            ),
            child: Center(
              child: score != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: AppTypography.scoreDisplay.copyWith(
                            fontSize: widget.size * 0.3,
                            color: tier,
                          ),
                        ),
                        Text(
                          _tierLabel(score),
                          style: AppTypography.bodySmall.copyWith(
                            color: tier.withOpacity(0.8),
                            fontSize: widget.size * 0.09,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '--',
                          style: AppTypography.scoreDisplay.copyWith(
                            fontSize: widget.size * 0.3,
                            color: Colors.white38,
                          ),
                        ),
                        Text(
                          'Not logged',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white38,
                            fontSize: widget.size * 0.09,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  String _tierLabel(int score) {
    if (score >= 90) return '🥇 Excellent';
    if (score >= 75) return '🥈 Great';
    if (score >= 60) return '🥉 Good';
    if (score >= 45) return '📘 Fair';
    return '📉 Needs Work';
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int? score;

  _ScoreRingPainter({
    required this.progress,
    required this.color,
    this.score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    const strokeWidth = 10.0;

    // Background track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Filled arc
    if (progress > 0) {
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Add glow shadow
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      const startAngle = -math.pi / 2; // Start at top
      final sweepAngle = 2 * math.pi * progress;


      final rect = Rect.fromCircle(center: center, radius: radius);

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.color != color;
}
