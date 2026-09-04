import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/star_path_button.dart';
import '../../../../core/performance/performance_mode.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/auth_repository.dart';

import '../../../../domain/models/developmental_stage.dart';
import '../../../../domain/use_cases/developmental_stage_engine.dart';
import '../../../../data/repositories/ai_provider_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _copyFamilyLinkInstructions(BuildContext context, String sisterName) {
    const instructions = '''
📱 Google Family Link Instructions
─────────────────────────────────
1. Open Google Family Link on your phone
2. Tap on your child's profile
3. Go to "Screen time" → "Daily limit"
4. Edit the weekend (Sat & Sun) limit according to this week's StarPath tier:
   • 🥇 Excellent (90-100): Add +2 hours
   • 🥈 Great (75-89): Add +1 hour
   • 🥉 Good (60-74): Add +30 mins
   • 😐 Fair (45-59): No change
   • 📉 Needs Work (<45): Reduce 30 mins
5. Tap Save.
''';

    Clipboard.setData(const ClipboardData(text: instructions));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied Family Link instructions to clipboard! 📋'),
        backgroundColor: AppColors.cosmicPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sister = ref.watch(sisterUserProvider).value;
    final sisterName = sister?.displayName.isNotEmpty == true ? sister!.displayName : 'Maya';
    final perfState = ref.watch(performanceModeProvider);
    final perfNotifier = ref.read(performanceModeProvider.notifier);
    final aiProviders = ref.watch(aiProvidersStateProvider);

    final stage = sister != null
        ? DevelopmentalStageEngine.resolveStage(sister: sister)
        : DevelopmentalStage.middleSchool;
    final birthDate = DateTime.tryParse(sister?.birthDate ?? '2014-01-12') ??
        DevelopmentalStageEngine.defaultBirthDate;
    final currentAge = sister?.simulatedAge ??
        DevelopmentalStageEngine.calculateAge(birthDate);

    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings & Optimization', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sister Profile Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.nebulaCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Text(sister?.avatarEmoji ?? '⭐', style: const TextStyle(fontSize: 38)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sisterName, style: AppTypography.titleLarge),
                          Text(
                            'Level ${sister?.level ?? 1} · ${sister?.levelTitle ?? "Seedling"}',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: AppColors.starGold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.palette_outlined, size: 16, color: AppColors.starGold),
                      label: const Text('Wardrobe', style: TextStyle(color: AppColors.starGold, fontSize: 12)),
                      onPressed: () => context.push('/guardian/character'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🎓 Developmental Stage Engine (Ages 12 to 22+ / University)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stage.primaryColor.withOpacity(0.2),
                      AppColors.nebulaCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: stage.primaryColor.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(stage.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Developmental Companion Engine',
                            style: AppTypography.titleMedium.copyWith(color: stage.secondaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Born January 12, 2014 (Turning 12 on Jan 12). StarPath adapts its UI theme, psychology models, and feature complexity across ages 12 to 22+ until university completion.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Stage: ${stage.title} (${stage.ageRangeDescription})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stage.psychologyFramework,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Simulate Growth Horizon (Preview UI & Psychology):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text('Age 12 (Middle)'),
                          selected: currentAge == 12,
                          onSelected: (sel) {
                            if (sister != null) {
                              ref.read(userRepositoryProvider).updateSimulatedAge(
                                    sister.uid,
                                    sel ? 12 : null,
                                  );
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Age 16 (High School)'),
                          selected: currentAge == 16,
                          onSelected: (sel) {
                            if (sister != null) {
                              ref.read(userRepositoryProvider).updateSimulatedAge(
                                    sister.uid,
                                    sel ? 16 : null,
                                  );
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Age 20 (University)'),
                          selected: currentAge == 20,
                          onSelected: (sel) {
                            if (sister != null) {
                              ref.read(userRepositoryProvider).updateSimulatedAge(
                                    sister.uid,
                                    sel ? 20 : null,
                                  );
                            }
                          },
                        ),
                        if (sister?.simulatedAge != null)
                          ActionChip(
                            avatar: const Icon(Icons.close, size: 12),
                            label: const Text('Reset Age'),
                            onPressed: () {
                              ref.read(userRepositoryProvider).updateSimulatedAge(sister!.uid, null);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🤖 Multi-Provider AI Fallback Hub Entry Point
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cosmicPurple.withOpacity(0.18),
                      AppColors.nebulaCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cosmicPurple.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🤖', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text('AI Free-Tier Resilience', style: AppTypography.titleMedium),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.xpGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${aiProviders.where((p) => p.isEnabled).length} Active',
                            style: const TextStyle(
                              color: AppColors.xpGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage free-tier API keys for Google Gemini, Groq, Mistral, and OpenRouter with automatic 429 rate-limit cascading.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cosmicPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Configure Providers & Test Fallback'),
                      onPressed: () => context.push('/guardian/ai-providers'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),


              // 🚀 Redmi 7 / Low-RAM Hardware Optimization Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      perfState.isLiteMode ? AppColors.xpGreen.withOpacity(0.18) : AppColors.nebulaCard,
                      AppColors.nebulaCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: perfState.isLiteMode
                        ? AppColors.xpGreen.withOpacity(0.6)
                        : AppColors.cosmicPurple.withOpacity(0.3),
                    width: 1.5,
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
                            const Text('⚡', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              'Redmi 7 Lite Mode',
                              style: AppTypography.titleMedium.copyWith(
                                color: perfState.isLiteMode ? AppColors.xpGreen : Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: perfState.isLiteMode,
                          activeColor: AppColors.xpGreen,
                          onChanged: (val) {
                            perfNotifier.setLiteMode(val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  val
                                      ? '🚀 Lite Mode Enabled: Background blurs disabled, RAM clamped to 16MB!'
                                      : '✨ Normal Mode Restored',
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: val ? AppColors.xpGreenDark : AppColors.cosmicPurple,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tuned specifically for 2GB RAM / 16GB Storage devices. Reduces memory usage, disables expensive GPU blur shaders, and eliminates background CPU repaints.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _perfBadge('RAM Clamped: 16MB', perfState.isLiteMode),
                        const SizedBox(width: 8),
                        _perfBadge('60 FPS Locked', perfState.isLiteMode),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reward Tiers Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.nebulaCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏆 Weekly Reward Tiers', style: AppTypography.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Configured incentives applied at weekend',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    _tierRow('🥇 Excellent (90-100)', '+2 hrs phone · +\$10', AppColors.tierGold),
                    _tierRow('🥈 Great (75-89)', '+1 hr phone · +\$5', AppColors.tierSilver),
                    _tierRow('🥉 Good (60-74)', '+30 min phone · +\$2', AppColors.tierBronze),
                    _tierRow('😐 Fair (45-59)', 'Standard limit · \$0', Colors.white60),
                    _tierRow('📉 Needs Work (<45)', '-30 min phone · \$0', AppColors.scoreRed),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Family Link Helper Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cosmicPurple.withOpacity(0.2),
                      AppColors.nebulaCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cosmicPurple.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📱', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text('Google Family Link', style: AppTypography.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quick instructions for adjusting your sister\'s phone screen time in Google Family Link.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.starGold,
                        side: const BorderSide(color: AppColors.starGold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Family Link Guide'),
                      onPressed: () => _copyFamilyLinkInstructions(context, sisterName),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Sign out button
              StarPathButton(
                label: 'Sign Out',
                isPrimary: false,
                icon: Icons.logout,
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _perfBadge(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.xpGreen.withOpacity(0.2) : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? AppColors.xpGreen.withOpacity(0.5) : Colors.white12,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? AppColors.xpGreen : Colors.white60,
        ),
      ),
    );
  }

  Widget _tierRow(String title, String reward, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodyMedium),
          Text(
            reward,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
