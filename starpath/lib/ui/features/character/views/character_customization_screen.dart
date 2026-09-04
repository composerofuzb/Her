import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/star_path_button.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/character_customization.dart';
import '../../../../domain/models/developmental_stage.dart';
import '../../../../domain/use_cases/developmental_stage_engine.dart';
import '../../../../core/animations/haptic_choreographer.dart';
import '../widgets/living_character_widget.dart';

class CharacterCustomizationScreen extends ConsumerStatefulWidget {
  const CharacterCustomizationScreen({super.key});

  @override
  ConsumerState<CharacterCustomizationScreen> createState() =>
      _CharacterCustomizationScreenState();
}

class _CharacterCustomizationScreenState
    extends ConsumerState<CharacterCustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CharacterCustomization _workingCustomization;
  PerformanceMood _previewMood = PerformanceMood.radiantCosmic;
  bool _initialized = false;
  bool _isSaving = false;

  final List<WardrobeCategory> _categories = [
    WardrobeCategory.skinTone,
    WardrobeCategory.hairStyle,
    WardrobeCategory.hairColor,
    WardrobeCategory.outfit,
    WardrobeCategory.accessory,
    WardrobeCategory.aura,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sisterUser = ref.watch(sisterUserProvider).value;
    final userLevel = sisterUser?.level ?? 1;
    final userXp = sisterUser?.xp ?? 0;
    final userStreak = sisterUser?.streakDays ?? 0;
    final sisterName = sisterUser?.displayName.isNotEmpty == true
        ? sisterUser!.displayName
        : 'Maya';

    final stage = sisterUser != null
        ? DevelopmentalStageEngine.resolveStage(sister: sisterUser)
        : DevelopmentalStage.middleSchool;

    if (!_initialized && sisterUser != null) {
      _workingCustomization = sisterUser.character;
      _previewMood = _workingCustomization.evaluateMood(
        todayScore: 90,
        streakDays: userStreak,
      );
      _initialized = true;
    } else if (!_initialized) {
      _workingCustomization = const CharacterCustomization();
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Customize Character',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Reset to default',
            onPressed: () {
              setState(() {
                _workingCustomization = const CharacterCustomization();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Preview Card with Live Animated Character
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.nebulaCard,
                    _previewMood.primaryAuraColor.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _previewMood.primaryAuraColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: stage.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: stage.primaryColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          '${stage.emoji} ${stage.title} (${stage.ageRangeDescription})',
                          style: TextStyle(
                            color: stage.secondaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Level $userLevel · $userXp XP',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.starGold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Living Animated Character
                  LivingCharacterWidget(
                    character: _workingCustomization,
                    mood: _previewMood,
                    stage: stage,
                    sisterName: sisterName,
                    width: 150,
                    height: 170,
                  ),

                  const SizedBox(height: 8),

                  // Mood Preview Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _moodChip('✨ Radiant', PerformanceMood.radiantCosmic),
                      const SizedBox(width: 6),
                      _moodChip('🔥 Streak', PerformanceMood.energizedStreak),
                      const SizedBox(width: 6),
                      _moodChip('📖 Scholar', PerformanceMood.steadyScholar),
                      const SizedBox(width: 6),
                      _moodChip('☕ Rest', PerformanceMood.restingRecharge),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar for Wardrobe Categories
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.nebulaDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.starGold,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.starGold,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: '🎨 Skin'),
                  Tab(text: '💇 Hair Style'),
                  Tab(text: '🌈 Hair Color'),
                  Tab(text: '👗 Outfits'),
                  Tab(text: '👓 Accessories'),
                  Tab(text: '✨ Cosmic Aura'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab Views for Selection
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _buildCategoryGrid(
                    category: category,
                    userLevel: userLevel,
                    userXp: userXp,
                    userStreak: userStreak,
                    stage: stage,
                  );
                }).toList(),
              ),
            ),

            // Save & Equip Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.nebulaDark,
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: StarPathButton(
                label: _isSaving ? 'Equipping...' : 'Equip Look & Save ✨',
                icon: Icons.check_circle_outline,
                isPrimary: true,
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        try {
                          final uid = sisterUser?.uid;
                          if (uid != null) {
                            await ref
                                .read(userRepositoryProvider)
                                .updateCharacter(uid, _workingCustomization);
                          }
                          await HapticChoreographer.onMissionComplete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 New character look equipped successfully!'),
                                backgroundColor: AppColors.xpGreenDark,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save: $e'),
                                backgroundColor: AppColors.scoreRed,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodChip(String label, PerformanceMood mood) {
    final isSelected = _previewMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() => _previewMood = mood);
        HapticChoreographer.onXpGained();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? mood.primaryAuraColor.withOpacity(0.3) : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? mood.primaryAuraColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid({
    required WardrobeCategory category,
    required int userLevel,
    required int userXp,
    required int userStreak,
    required DevelopmentalStage stage,
  }) {
    final items = WardrobeCatalog.getByCategory(category);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.35,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isUnlocked = item.isUnlocked(
          userLevel: userLevel,
          userXp: userXp,
          userStreak: userStreak,
          currentStage: stage,
        );
        final isSelected = _isItemSelected(category, item.id);

        return GestureDetector(
          onTap: () {
            if (!isUnlocked) {
              _showLockDialog(context, item);
              return;
            }
            HapticChoreographer.onXpGained();
            setState(() {
              _applyItem(category, item.id);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.cosmicPurple.withOpacity(0.25)
                  : AppColors.nebulaCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.starGold
                    : (isUnlocked ? Colors.white12 : Colors.white.withOpacity(0.04)),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.primaryColor != null)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: item.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30),
                        ),
                      )
                    else
                      Text(item.emoji, style: const TextStyle(fontSize: 22)),
                    if (!isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, size: 10, color: Colors.white70),
                            const SizedBox(width: 2),
                            Text(
                              'Lv ${item.requiredLevel}',
                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    else if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.starGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.starGold, width: 0.8),
                        ),
                        child: const Text(
                          'Equipped',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.starGold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.white : Colors.white38,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUnlocked ? Colors.white60 : Colors.white24,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isItemSelected(WardrobeCategory category, String id) {
    switch (category) {
      case WardrobeCategory.skinTone:
        return _workingCustomization.skinToneId == id;
      case WardrobeCategory.hairStyle:
        return _workingCustomization.hairStyleId == id;
      case WardrobeCategory.hairColor:
        return _workingCustomization.hairColorId == id;
      case WardrobeCategory.outfit:
        return _workingCustomization.outfitId == id;
      case WardrobeCategory.accessory:
        return _workingCustomization.accessoryId == id;
      case WardrobeCategory.aura:
        return _workingCustomization.auraId == id;
    }
  }

  void _applyItem(WardrobeCategory category, String id) {
    switch (category) {
      case WardrobeCategory.skinTone:
        _workingCustomization = _workingCustomization.copyWith(skinToneId: id);
        break;
      case WardrobeCategory.hairStyle:
        _workingCustomization = _workingCustomization.copyWith(hairStyleId: id);
        break;
      case WardrobeCategory.hairColor:
        _workingCustomization = _workingCustomization.copyWith(hairColorId: id);
        break;
      case WardrobeCategory.outfit:
        _workingCustomization = _workingCustomization.copyWith(outfitId: id);
        break;
      case WardrobeCategory.accessory:
        _workingCustomization = _workingCustomization.copyWith(accessoryId: id);
        break;
      case WardrobeCategory.aura:
        _workingCustomization = _workingCustomization.copyWith(auraId: id);
        break;
    }
  }

  void _showLockDialog(BuildContext context, WardrobeItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: AppColors.starGold, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name, style: AppTypography.titleMedium)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: AppTypography.bodySmall),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock Requirement:',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.starGold)),
                  const SizedBox(height: 4),
                  if (item.requiredLevel > 1)
                    Text('• Reach Level ${item.requiredLevel} by logging daily scores',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  if (item.requiredStreak > 0)
                    Text('• Achieve a ${item.requiredStreak}-day consecutive streak',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  if (item.minimumStage != null)
                    Text('• Unlocks in ${item.minimumStage!.stageName}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text(
                    '⭐ 100% free — earned solely through daily consistency!',
                    style: TextStyle(color: AppColors.xpGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
