import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/performance/performance_mode.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/character_customization.dart';
import '../../../../domain/models/developmental_stage.dart';
import '../../../../domain/use_cases/psychological_offline_coaching.dart';
import '../../../../core/animations/haptic_choreographer.dart';

/// Interactive vector-rendered living animated character widget.
/// Dynamically mirrors her performance, developmental stage, and wardrobe.
/// Respects Redmi 7 Lite Mode by omitting GPU blur shaders and clamping animations.
class LivingCharacterWidget extends ConsumerStatefulWidget {
  final CharacterCustomization character;
  final PerformanceMood mood;
  final DevelopmentalStage stage;
  final String sisterName;
  final double width;
  final double height;
  final bool showSpeechBubble;
  final VoidCallback? onTap;

  const LivingCharacterWidget({
    super.key,
    required this.character,
    required this.mood,
    this.stage = DevelopmentalStage.middleSchool,
    this.sisterName = 'Maya',
    this.width = 160,
    this.height = 200,
    this.showSpeechBubble = true,
    this.onTap,
  });

  @override
  ConsumerState<LivingCharacterWidget> createState() => _LivingCharacterWidgetState();
}

class _LivingCharacterWidgetState extends ConsumerState<LivingCharacterWidget>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _blinkController;
  late final AnimationController _auraController;

  String? _activeQuote;
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _blinkController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticChoreographer.onXpGained();
    final quotes = PsychologicalOfflineCoachingEngine.getCharacterQuotes(
      stage: widget.stage,
      sisterName: widget.sisterName,
    );
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % quotes.length;
      _activeQuote = quotes[_quoteIndex];
    });

    widget.onTap?.call();
  }

  void _syncAnimationState(bool isLite) {
    if (isLite) {
      if (_breathController.isAnimating) _breathController.stop();
      if (_blinkController.isAnimating) _blinkController.stop();
      if (_auraController.isAnimating) _auraController.stop();
    } else {
      if (!_breathController.isAnimating) _breathController.repeat(reverse: true);
      if (!_blinkController.isAnimating) _blinkController.repeat();
      if (!_auraController.isAnimating) _auraController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfState = ref.watch(performanceModeProvider);
    final isLite = perfState.isLiteMode;
    _syncAnimationState(isLite);

    final characterCanvas = SizedBox(
      width: widget.width,
      height: widget.height,
      child: isLite
          ? CustomPaint(
              painter: _CharacterCanvasPainter(
                customization: widget.character,
                mood: widget.mood,
                stage: widget.stage,
                breathOffset: 0.0,
                auraScale: 1.0,
                isBlinking: false,
                isLiteMode: true,
              ),
            )
          : AnimatedBuilder(
              animation: Listenable.merge(
                  [_breathController, _blinkController, _auraController]),
              builder: (context, child) {
                final breathOffset =
                    math.sin(_breathController.value * math.pi) * 3.0;
                final auraScale = 0.95 + (_auraController.value * 0.1);
                final isBlinking = _blinkController.value > 0.93;

                return CustomPaint(
                  painter: _CharacterCanvasPainter(
                    customization: widget.character,
                    mood: widget.mood,
                    stage: widget.stage,
                    breathOffset: breathOffset,
                    auraScale: auraScale,
                    isBlinking: isBlinking,
                    isLiteMode: false,
                  ),
                );
              },
            ),
    );

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional animated interactive speech bubble
          if (widget.showSpeechBubble && _activeQuote != null)
            _buildSpeechBubble(isLite),

          // Character Vector Canvas
          characterCanvas,
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(bool isLite) {
    final bubble = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      constraints: BoxConstraints(maxWidth: widget.width * 1.5),
      decoration: BoxDecoration(
        color: AppColors.nebulaCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.mood.primaryAuraColor.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: isLite
            ? null
            : [
                BoxShadow(
                  color: widget.mood.primaryAuraColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Text(
        _activeQuote!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (isLite) {
      return bubble;
    }

    return bubble
        .animate(key: ValueKey(_activeQuote))
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}

class _CharacterCanvasPainter extends CustomPainter {
  final CharacterCustomization customization;
  final PerformanceMood mood;
  final DevelopmentalStage stage;
  final double breathOffset;
  final double auraScale;
  final bool isBlinking;
  final bool isLiteMode;

  _CharacterCanvasPainter({
    required this.customization,
    required this.mood,
    required this.stage,
    required this.breathOffset,
    required this.auraScale,
    required this.isBlinking,
    required this.isLiteMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + breathOffset;

    // Resolve Colors from Catalog
    final skinItem = WardrobeCatalog.findItem(customization.skinToneId);
    final skinColor = skinItem?.primaryColor ?? const Color(0xFFF0C097);

    final hairColorItem = WardrobeCatalog.findItem(customization.hairColorId);
    final hairColor = hairColorItem?.primaryColor ?? const Color(0xFF1E1E28);

    final outfitItem = WardrobeCatalog.findItem(customization.outfitId);
    final outfitPrimary = outfitItem?.primaryColor ?? stage.primaryColor;
    final outfitSecondary = outfitItem?.secondaryColor ?? stage.secondaryColor;

    // 1. Cosmic Performance Aura (Behind character)
    _drawAura(canvas, cx, cy, size);

    // 2. Body & Outfit
    _drawBody(canvas, cx, cy, size, outfitPrimary, outfitSecondary);

    // 3. Head & Neck
    _drawHeadAndNeck(canvas, cx, cy, size, skinColor);

    // 4. Facial Expression (Reflecting Mood)
    _drawFace(canvas, cx, cy, size);

    // 5. Hair Style
    _drawHair(canvas, cx, cy, size, hairColor);

    // 6. Accessories
    _drawAccessories(canvas, cx, cy, size);
  }

  void _drawAura(Canvas canvas, double cx, double cy, Size size) {
    final auraRadius = (size.width * 0.44) * auraScale;

    // In Lite Mode, render a crisp non-blurred vector ring instead of Gaussian shaders
    if (isLiteMode) {
      final ringPaint = Paint()
        ..color = mood.primaryAuraColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(cx, cy), auraRadius, ringPaint);
      return;
    }

    final gradient = RadialGradient(
      colors: [
        mood.primaryAuraColor.withOpacity(0.35),
        mood.secondaryAuraColor.withOpacity(0.15),
        Colors.transparent,
      ],
      stops: const [0.5, 0.85, 1.0],
    );

    final auraPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: auraRadius),
      );

    canvas.drawCircle(Offset(cx, cy), auraRadius, auraPaint);

    // Star sparkle particles for high performance
    if (mood == PerformanceMood.radiantCosmic || mood == PerformanceMood.energizedStreak) {
      final starPaint = Paint()..color = mood.secondaryAuraColor;
      for (int i = 0; i < 4; i++) {
        final angle = (i * math.pi / 2) + (auraScale * math.pi);
        final px = cx + math.cos(angle) * (auraRadius * 0.85);
        final py = cy + math.sin(angle) * (auraRadius * 0.85);
        canvas.drawCircle(Offset(px, py), 2.5, starPaint);
      }
    }
  }

  void _drawBody(
    Canvas canvas,
    double cx,
    double cy,
    Size size,
    Color primaryColor,
    Color secondaryColor,
  ) {
    final bodyPaint = Paint()..color = primaryColor;
    final accentPaint = Paint()..color = secondaryColor;

    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + 50),
      width: 58,
      height: 48,
    );
    final rRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(16));
    canvas.drawRRect(rRect, bodyPaint);

    // Collar / Lapel stripe
    final collarPath = Path()
      ..moveTo(cx - 14, cy + 28)
      ..lineTo(cx, cy + 42)
      ..lineTo(cx + 14, cy + 28);
    final collarPaint = Paint()
      ..color = accentPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(collarPath, collarPaint);

    // Arms based on mood
    final armPaint = Paint()
      ..color = primaryColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    if (mood == PerformanceMood.radiantCosmic) {
      // Triumphant raised arms
      canvas.drawLine(Offset(cx - 26, cy + 38), Offset(cx - 40, cy + 20), armPaint);
      canvas.drawLine(Offset(cx + 26, cy + 38), Offset(cx + 40, cy + 20), armPaint);
    } else {
      // Relaxed / steady arms
      canvas.drawLine(Offset(cx - 26, cy + 38), Offset(cx - 30, cy + 62), armPaint);
      canvas.drawLine(Offset(cx + 26, cy + 38), Offset(cx + 30, cy + 62), armPaint);
    }
  }

  void _drawHeadAndNeck(Canvas canvas, double cx, double cy, Size size, Color skinColor) {
    final skinPaint = Paint()..color = skinColor;

    // Neck
    final neckRect = Rect.fromCenter(
      center: Offset(cx, cy + 24),
      width: 16,
      height: 14,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, const Radius.circular(4)), skinPaint);

    // Head
    canvas.drawCircle(Offset(cx, cy - 2), 34, skinPaint);

    // Rosy Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF8A80).withOpacity(0.4);
    canvas.drawCircle(Offset(cx - 18, cy + 6), 5, cheekPaint);
    canvas.drawCircle(Offset(cx + 18, cy + 6), 5, cheekPaint);
  }

  void _drawFace(Canvas canvas, double cx, double cy, Size size) {
    final eyePaint = Paint()
      ..color = const Color(0xFF1A1A24)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mouthPaint = Paint()
      ..color = const Color(0xFFC2185B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1. Eyes
    if (isBlinking || mood == PerformanceMood.restingRecharge) {
      // Closed peaceful / blinking eyes
      final leftEyePath = Path()
        ..moveTo(cx - 16, cy - 2)
        ..quadraticBezierTo(cx - 11, cy + 2, cx - 6, cy - 2);
      final rightEyePath = Path()
        ..moveTo(cx + 6, cy - 2)
        ..quadraticBezierTo(cx + 11, cy + 2, cx + 16, cy - 2);
      canvas.drawPath(leftEyePath, eyePaint);
      canvas.drawPath(rightEyePath, eyePaint);
    } else if (mood == PerformanceMood.radiantCosmic) {
      // Happy curved arch eyes
      final leftEyePath = Path()
        ..moveTo(cx - 16, cy - 1)
        ..quadraticBezierTo(cx - 11, cy - 6, cx - 6, cy - 1);
      final rightEyePath = Path()
        ..moveTo(cx + 6, cy - 1)
        ..quadraticBezierTo(cx + 11, cy - 6, cx + 16, cy - 1);
      canvas.drawPath(leftEyePath, eyePaint);
      canvas.drawPath(rightEyePath, eyePaint);
    } else {
      // Normal open eyes with catchlight
      final pupilPaint = Paint()..color = const Color(0xFF1E1E28);
      canvas.drawCircle(Offset(cx - 11, cy - 3), 4, pupilPaint);
      canvas.drawCircle(Offset(cx + 11, cy - 3), 4, pupilPaint);

      final shinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(cx - 12, cy - 4.5), 1.5, shinePaint);
      canvas.drawCircle(Offset(cx + 10, cy - 4.5), 1.5, shinePaint);
    }

    // 2. Smile
    if (mood == PerformanceMood.radiantCosmic || mood == PerformanceMood.energizedStreak) {
      // Broad cheerful smile
      final smilePath = Path()
        ..moveTo(cx - 8, cy + 10)
        ..quadraticBezierTo(cx, cy + 17, cx + 8, cy + 10);
      canvas.drawPath(smilePath, mouthPaint);
    } else {
      // Pleasant calm smile
      final gentleSmile = Path()
        ..moveTo(cx - 6, cy + 12)
        ..quadraticBezierTo(cx, cy + 15, cx + 6, cy + 12);
      canvas.drawPath(gentleSmile, gentSmilePaint(mouthPaint));
    }
  }



  Paint gentSmilePaint(Paint base) => Paint()
    ..color = base.color
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  void _drawHair(Canvas canvas, double cx, double cy, Size size, Color hairColor) {
    final hairPaint = Paint()..color = hairColor;

    switch (customization.hairStyleId) {
      case 'twinBuns':
        // Left & Right high space buns
        canvas.drawCircle(Offset(cx - 32, cy - 26), 14, hairPaint);
        canvas.drawCircle(Offset(cx + 32, cy - 26), 14, hairPaint);
        // Front bangs
        final bangPath = Path()
          ..moveTo(cx - 34, cy - 20)
          ..quadraticBezierTo(cx, cy - 40, cx + 34, cy - 20)
          ..quadraticBezierTo(cx + 16, cy - 14, cx, cy - 18)
          ..quadraticBezierTo(cx - 16, cy - 14, cx - 34, cy - 20);
        canvas.drawPath(bangPath, hairPaint);
        break;

      case 'ponytail':
        // High swinging ponytail on right
        canvas.drawCircle(Offset(cx + 28, cy - 28), 16, hairPaint);
        final tailPath = Path()
          ..moveTo(cx + 28, cy - 28)
          ..quadraticBezierTo(cx + 46, cy - 10, cx + 36, cy + 20)
          ..quadraticBezierTo(cx + 24, cy - 5, cx + 28, cy - 28);
        canvas.drawPath(tailPath, hairPaint);
        // Bangs
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy - 8), radius: 35),
          math.pi,
          math.pi,
          true,
          hairPaint,
        );
        break;

      case 'longWavy':
        // Flowing locks on both sides
        final wavePath = Path()
          ..moveTo(cx - 34, cy - 10)
          ..quadraticBezierTo(cx - 44, cy + 20, cx - 32, cy + 50)
          ..quadraticBezierTo(cx - 20, cy + 30, cx - 30, cy + 10)
          ..close();
        canvas.drawPath(wavePath, hairPaint);

        final rightWave = Path()
          ..moveTo(cx + 34, cy - 10)
          ..quadraticBezierTo(cx + 44, cy + 20, cx + 32, cy + 50)
          ..quadraticBezierTo(cx + 20, cy + 30, cx + 30, cy + 10)
          ..close();
        canvas.drawPath(rightWave, hairPaint);

        // Top hair dome
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy - 6), radius: 36),
          math.pi * 0.95,
          math.pi * 1.1,
          true,
          hairPaint,
        );
        break;

      case 'pixie':
      case 'bob':
      default:
        // Sleek modern bob
        final bobPath = Path()
          ..moveTo(cx - 36, cy + 14)
          ..lineTo(cx - 36, cy - 14)
          ..quadraticBezierTo(cx, cy - 42, cx + 36, cy - 14)
          ..lineTo(cx + 36, cy + 14)
          ..quadraticBezierTo(cx + 26, cy - 10, cx, cy - 14)
          ..quadraticBezierTo(cx - 26, cy - 10, cx - 36, cy + 14);
        canvas.drawPath(bobPath, hairPaint);
        break;
    }
  }

  void _drawAccessories(Canvas canvas, double cx, double cy, Size size) {
    switch (customization.accessoryId) {
      case 'starPin':
        // Golden star pinned in hair
        final starPaint = Paint()..color = const Color(0xFFFFD700);
        _drawMiniStar(canvas, Offset(cx + 22, cy - 24), 7, starPaint);
        break;

      case 'glasses':
        // Chic round study glasses
        final glassPaint = Paint()
          ..color = const Color(0xFF424242)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(Offset(cx - 11, cy - 2), 8, glassPaint);
        canvas.drawCircle(Offset(cx + 11, cy - 2), 8, glassPaint);
        canvas.drawLine(Offset(cx - 3, cy - 2), Offset(cx + 3, cy - 2), glassPaint);
        break;

      case 'catHeadphones':
        // Over-ear headphones with cat ears
        final phonePaint = Paint()
          ..color = const Color(0xFFFF4081)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;
        // Headband
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy - 4), radius: 37),
          math.pi * 1.05,
          math.pi * 0.9,
          false,
          phonePaint,
        );
        // Earcups
        final earCupPaint = Paint()..color = const Color(0xFF00E5FF);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx - 35, cy - 2), width: 8, height: 16),
            const Radius.circular(4),
          ),
          earCupPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx + 35, cy - 2), width: 8, height: 16),
            const Radius.circular(4),
          ),
          earCupPaint,
        );
        break;

      case 'graduationCap':
        // Mortarboard cap
        final capPaint = Paint()..color = const Color(0xFF1E1B4B);
        final capPath = Path()
          ..moveTo(cx, cy - 46)
          ..lineTo(cx + 26, cy - 36)
          ..lineTo(cx, cy - 26)
          ..lineTo(cx - 26, cy - 36)
          ..close();
        canvas.drawPath(capPath, capPaint);
        // Tassel
        final tasselPaint = Paint()
          ..color = const Color(0xFFFFD700)
          ..strokeWidth = 2;
        canvas.drawLine(Offset(cx, cy - 36), Offset(cx + 18, cy - 22), tasselPaint);
        break;

      default:
        break;
    }
  }

  void _drawMiniStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final double innerRadius = radius * 0.45;
    for (int i = 0; i < 5; i++) {
      final double outerAngle = (i * 72 - 90) * math.pi / 180;
      final double innerAngle = ((i * 72 + 36) - 90) * math.pi / 180;

      final double ox = center.dx + radius * math.cos(outerAngle);
      final double oy = center.dy + radius * math.sin(outerAngle);
      final double ix = center.dx + innerRadius * math.cos(innerAngle);
      final double iy = center.dy + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CharacterCanvasPainter oldDelegate) {
    return oldDelegate.customization != customization ||
        oldDelegate.mood != mood ||
        oldDelegate.stage != stage ||
        oldDelegate.breathOffset != breathOffset ||
        oldDelegate.auraScale != auraScale ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.isLiteMode != isLiteMode;
  }
}
