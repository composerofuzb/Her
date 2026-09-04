import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/star_path_button.dart';
import '../../../../domain/models/user.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/auth_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _sisterNameCtrl = TextEditingController(text: 'Maya');
  final _currencyCtrl = TextEditingController(text: '\$');
  final List<String> _subjects = ['Math', 'Science', 'English', 'History', 'PE'];
  final _newSubjectCtrl = TextEditingController();
  final _sisterEmailCtrl = TextEditingController(text: 'sister@starpath.app');
  final _sisterPasswordCtrl = TextEditingController(text: 'sister123');
  bool _isLoading = false;

  @override
  void dispose() {
    _sisterNameCtrl.dispose();
    _currencyCtrl.dispose();
    _newSubjectCtrl.dispose();
    _sisterEmailCtrl.dispose();
    _sisterPasswordCtrl.dispose();
    super.dispose();
  }

  void _addSubject() {
    final name = _newSubjectCtrl.text.trim();
    if (name.isNotEmpty && !_subjects.contains(name)) {
      setState(() {
        _subjects.add(name);
        _newSubjectCtrl.clear();
      });
    }
  }

  void _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      final userRepo = ref.read(userRepositoryProvider);
      final authRepo = ref.read(authRepositoryProvider);

      final sisterUid = 'sister_${DateTime.now().millisecondsSinceEpoch}';
      final guardianUid = authRepo.currentUid ?? 'guardian_${DateTime.now().millisecondsSinceEpoch}';

      final sister = User(
        uid: sisterUid,
        displayName: _sisterNameCtrl.text.trim(),
        role: 'sister',
        linkedUid: guardianUid,
        xp: 100,
        level: 1,
        streakDays: 0,
        avatarStage: 0,
      );

      final guardian = User(
        uid: guardianUid,
        displayName: 'Guardian',
        role: 'guardian',
        linkedUid: sisterUid,
      );

      await userRepo.createUser(sister, subjects: _subjects, currencySymbol: _currencyCtrl.text.trim());
      await userRepo.createUser(guardian);

      if (mounted) {
        context.go('/guardian');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _step--),
              )
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.go('/login'),
              ),
        title: Text('Guardian Setup (${_step + 1}/3)', style: AppTypography.titleMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_step + 1) / 3.0,
                backgroundColor: Colors.white10,
                color: AppColors.cosmicPurple,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStep(),
                ),
              ),

              StarPathButton(
                label: _step == 2 ? 'Complete Setup 🚀' : 'Next Step →',
                isLoading: _isLoading,
                onPressed: () {
                  if (_step < 2) {
                    setState(() => _step++);
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who are you setting this up for?', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text('Enter your sister\'s name and preferred currency symbol for rewards.', style: AppTypography.bodySmall),
            const SizedBox(height: 24),

            TextField(
              controller: _sisterNameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Sister\'s Name',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: AppColors.nebulaCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _currencyCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Currency Symbol (\$, €, £, etc.)',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: AppColors.nebulaCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('School Subjects', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text('What subjects should she track marks & homework for?', style: AppTypography.bodySmall),
            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subjects.map((sub) {
                return Chip(
                  backgroundColor: AppColors.nebulaCard,
                  deleteIconColor: Colors.redAccent,
                  label: Text(sub, style: const TextStyle(color: Colors.white)),
                  onDeleted: _subjects.length > 1
                      ? () => setState(() => _subjects.remove(sub))
                      : null,
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newSubjectCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add subject (e.g. Art)...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: AppColors.nebulaCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: _addSubject,
                ),
              ],
            ),
          ],
        );

      case 2:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Sister\'s Login', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text('She will use these credentials on her phone to see her gamified adventure.', style: AppTypography.bodySmall),
            const SizedBox(height: 24),

            TextField(
              controller: _sisterEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Sister\'s Email',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: AppColors.nebulaCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _sisterPasswordCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Sister\'s Password',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: AppColors.nebulaCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        );
    }
  }
}
