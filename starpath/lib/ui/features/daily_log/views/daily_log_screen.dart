import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/star_path_button.dart';
import '../../../../core/animations/starpath_fx.dart';
import '../../../../core/animations/animation_event.dart';
import '../../../../domain/models/developmental_stage.dart';
import '../view_models/daily_log_view_model.dart';
import 'subject_row_widget.dart';

class DailyLogScreen extends ConsumerWidget {
  const DailyLogScreen({super.key});

  static const _behaviorOptions = [
    ('excellent', '😄 Excellent'),
    ('good', '🙂 Good'),
    ('neutral', '😐 Neutral'),
    ('poor', '😟 Poor'),
    ('bad', '😠 Bad'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyLogViewModelProvider);
    final vm = ref.read(dailyLogViewModelProvider.notifier);
    final stage = state.stage;

    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Daily Performance Log', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Score Preview Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forScore(state.calculatedScore).withOpacity(0.2),
                      AppColors.nebulaCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.forScore(state.calculatedScore).withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(stage.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${stage.title.toUpperCase()} · LIVE SCORE',
                              style: AppTypography.labelLarge.copyWith(color: stage.secondaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${state.calculatedScore}',
                              style: AppTypography.displayMedium.copyWith(
                                color: AppColors.forScore(state.calculatedScore),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(' / 100', style: AppTypography.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.starGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.starGold.withOpacity(0.4)),
                      ),
                      child: Text(
                        '+${state.calculatedXp} XP ⭐',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.starGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Date Picker Field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.nebulaCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.starGold, size: 18),
                        const SizedBox(width: 10),
                        Text(state.date, style: AppTypography.titleMedium),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2025),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          final dateStr =
                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          vm.updateDate(dateStr);
                        }
                      },
                      child: const Text('Change Date', style: TextStyle(color: AppColors.cosmicPurpleLight)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Subjects List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('📚 Subjects & Coursework', style: AppTypography.titleMedium),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16, color: AppColors.starGold),
                    label: const Text(
                      'Add Lesson',
                      style: TextStyle(color: AppColors.starGold, fontSize: 12),
                    ),
                    onPressed: () => _showAddSubjectDialog(context, vm),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...state.subjects.entries.map((entry) {
                return SubjectRowWidget(
                  subjectName: entry.key,
                  data: entry.value,
                  onChanged: (updated) => vm.updateSubject(entry.key, updated),
                );
              }),

              const SizedBox(height: 20),

              // Behavior Selection
              Text('😊 Overall Behavior', style: AppTypography.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _behaviorOptions.map((opt) {
                  final isSelected = state.behavior == opt.$1;
                  return ChoiceChip(
                    label: Text(opt.$2),
                    selected: isSelected,
                    selectedColor: AppColors.cosmicPurple,
                    backgroundColor: AppColors.nebulaCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => vm.updateBehavior(opt.$1),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Bonus Extras Checkbox List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${stage.emoji} ${stage.stageName} Growth (+25 pts)',
                    style: AppTypography.titleMedium,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16, color: AppColors.starGold),
                    label: const Text(
                      'Add Activity',
                      style: TextStyle(color: AppColors.starGold, fontSize: 12),
                    ),
                    onPressed: () => _showAddActivityDialog(context, vm),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...state.availableExtras.map((extra) {
                final isChecked = state.extras.contains(extra);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(extra, style: AppTypography.bodyMedium),
                  value: isChecked,
                  activeColor: AppColors.xpGreen,
                  checkColor: Colors.black,
                  onChanged: (_) => vm.toggleExtra(extra),
                );
              }),

              const SizedBox(height: 16),

              // Notes
              TextField(
                onChanged: vm.updateNotes,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: AppColors.nebulaCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              StarPathButton(
                label: 'Save & Award ${state.calculatedXp} XP 🚀',
                isLoading: state.isSaving,
                onPressed: () async {
                  final log = await vm.submitLog();
                  if (context.mounted) {
                    await StarPathFX.trigger(
                      AnimationEvent.dailyLogSaved,
                      context: context,
                      value: log.xpAwarded,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, DailyLogViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Subject or Extra Lesson'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Violin, Robotics, Coding, AP Art',
            labelText: 'Lesson / Subject Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                vm.addSubject(text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add Lesson'),
          ),
        ],
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context, DailyLogViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Growth Activity'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Chess Club, Math Olympiad Prep',
            labelText: 'Activity Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                vm.addExtraActivity(text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add Activity'),
          ),
        ],
      ),
    );
  }
}
