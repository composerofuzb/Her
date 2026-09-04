import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/repositories/ai_provider_repository.dart';
import '../../../../domain/models/ai_provider_config.dart';
import '../../../../domain/models/developmental_stage.dart';
import '../../../../domain/models/user.dart';
import '../../../../domain/models/daily_log.dart';
import '../../../../domain/use_cases/psychological_offline_coaching.dart';
import '../../../../core/animations/haptic_choreographer.dart';

class AiCoachCard extends ConsumerStatefulWidget {
  final User? sister;
  final DailyLog? todayLog;
  final DevelopmentalStage stage;

  const AiCoachCard({
    super.key,
    required this.sister,
    required this.todayLog,
    required this.stage,
  });

  @override
  ConsumerState<AiCoachCard> createState() => _AiCoachCardState();
}

class _AiCoachCardState extends ConsumerState<AiCoachCard> {
  bool _isLoading = false;
  AiCoachingResult? _coachingResult;

  @override
  void initState() {
    super.initState();
    _loadInitialAdvice();
  }

  void _loadInitialAdvice() {
    final sisterName = widget.sister?.displayName.isNotEmpty == true
        ? widget.sister!.displayName
        : 'Maya';
    final score = widget.todayLog?.score ?? 88;
    final streak = widget.sister?.streakDays ?? 14;

    // Generate initial offline coaching advice immediately so there is never an empty state
    final initialText = PsychologicalOfflineCoachingEngine.generateCoaching(
      sisterName: sisterName,
      stage: widget.stage,
      score: score,
      streakDays: streak,
    );

    _coachingResult = AiCoachingResult(
      text: initialText,
      providerName: 'Psychological Companion Engine',
      providerId: 'initial',
      wasOfflineFallback: true,
      latencyMs: 1,
      auditTrail: ['Initialized with stage-grounded psychological guidance.'],
    );
  }

  Future<void> _fetchFreshCoaching() async {
    setState(() => _isLoading = true);
    HapticChoreographer.onXpGained();

    final sisterName = widget.sister?.displayName.isNotEmpty == true
        ? widget.sister!.displayName
        : 'Maya';
    final score = widget.todayLog?.score ?? 88;
    final streak = widget.sister?.streakDays ?? 14;

    String? topSubject;
    String? focusSubject;
    if (widget.todayLog?.subjects.isNotEmpty == true) {
      final sortedEntries = widget.todayLog!.subjects.entries.toList()
        ..sort((a, b) => b.value.mark.compareTo(a.value.mark));
      topSubject = sortedEntries.first.key;
      focusSubject = sortedEntries.last.key;
    }

    try {
      final repo = ref.read(aiProviderRepositoryProvider);
      final result = await repo.requestCoaching(
        sisterName: sisterName,
        stage: widget.stage,
        score: score,
        streakDays: streak,
        topSubject: topSubject,
        focusSubject: focusSubject,
        extrasCount: widget.todayLog?.extras.length ?? 0,
      );

      setState(() {
        _coachingResult = result;
      });
      ref.read(lastAiCoachingResultProvider.notifier).state = result;
    } catch (e) {
      // Graceful fallback
      final fallback = PsychologicalOfflineCoachingEngine.generateCoaching(
        sisterName: sisterName,
        stage: widget.stage,
        score: score,
        streakDays: streak,
      );
      setState(() {
        _coachingResult = AiCoachingResult(
          text: fallback,
          providerName: 'Psychological Offline Engine',
          providerId: 'offline-catch',
          wasOfflineFallback: true,
          latencyMs: 1,
          auditTrail: ['Error caught: $e', 'Fallback engaged successfully.'],
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _coachingResult;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.stage.primaryColor.withOpacity(0.18),
            AppColors.nebulaCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.stage.secondaryColor.withOpacity(0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(widget.stage.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.stage.title} AI Coach',
                    style: AppTypography.titleSmall.copyWith(
                      color: widget.stage.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.starGold,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 20, color: Colors.white70),
                tooltip: 'Ask AI Coach for fresh insight',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _isLoading ? null : _fetchFreshCoaching,
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (result != null) ...[
            Text(
              result.text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Colors.white,
              ),
            ).animate(key: ValueKey(result.text)).fadeIn(duration: 300.ms),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      result.wasOfflineFallback ? Icons.offline_bolt : Icons.auto_awesome,
                      size: 12,
                      color: result.wasOfflineFallback
                          ? AppColors.xpGreen
                          : AppColors.starGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.providerName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: result.wasOfflineFallback
                            ? AppColors.xpGreen
                            : AppColors.starGold,
                      ),
                    ),
                  ],
                ),
                Text(
                  result.latencyMs > 0 ? '${result.latencyMs}ms' : 'Instant',
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
