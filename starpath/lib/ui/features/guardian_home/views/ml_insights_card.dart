import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/use_cases/ml_insights_engine.dart';

class MlInsightsCard extends StatelessWidget {
  final List<MlInsight> insights;

  const MlInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🧠 ', style: TextStyle(fontSize: 20)),
            Text('Smart Insights & Predictions', style: AppTypography.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.nebulaCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _borderColor(insight.type),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              insight.title,
                              style: AppTypography.titleMedium.copyWith(fontSize: 14),
                            ),
                          ),
                          if (insight.metric != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _borderColor(insight.type).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                insight.metric!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _borderColor(insight.type),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.body,
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _borderColor(InsightType type) {
    switch (type) {
      case InsightType.warning:
        return Colors.orangeAccent;
      case InsightType.praise:
        return AppColors.xpGreen;
      case InsightType.prediction:
        return AppColors.starGold;
      case InsightType.recommendation:
        return AppColors.cosmicPurpleLight;
    }
  }
}
