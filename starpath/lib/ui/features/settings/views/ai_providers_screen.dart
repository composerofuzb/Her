import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/repositories/ai_provider_repository.dart';
import '../../../../domain/models/ai_provider_config.dart';
import '../../../../domain/models/developmental_stage.dart';


class AiProvidersScreen extends ConsumerStatefulWidget {
  const AiProvidersScreen({super.key});

  @override
  ConsumerState<AiProvidersScreen> createState() => _AiProvidersScreenState();
}

class _AiProvidersScreenState extends ConsumerState<AiProvidersScreen> {
  bool _isTestingCascade = false;
  List<String>? _cascadeLogs;

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(aiProvidersStateProvider);
    final notifier = ref.read(aiProvidersStateProvider.notifier);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.deepSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('AI Free-Tier Fallback Hub', style: AppTypography.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.white70),
            tooltip: 'Reset to Defaults',
            onPressed: () => _confirmReset(context, notifier),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header explanatory card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cosmicPurple.withOpacity(0.25),
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
                        const Text('🤖', style: TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Multi-Provider Resilience Manager',
                            style: AppTypography.titleMedium.copyWith(color: AppColors.starGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure your free API keys from Google, Groq, Mistral, and OpenRouter. If an active API hits its free rate limit (HTTP 429), StarPath\'s circuit breaker automatically cascades to the next available provider with zero interruption.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statusBadge('Auto-Cooldown 60s', AppColors.xpGreen),
                        const SizedBox(width: 8),
                        _statusBadge('Cascading Fallback', AppColors.cosmicPurple),
                        const SizedBox(width: 8),
                        _statusBadge('Offline Ready', AppColors.starGold),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Cascade Simulation / Test Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.nebulaCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚡ Live Resilience Verification', style: AppTypography.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Simulate a coaching query through the cascading circuit breaker to verify health across all configured tiers.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.starGold,
                        side: const BorderSide(color: AppColors.starGold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isTestingCascade
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.starGold),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(_isTestingCascade ? 'Testing Cascade...' : 'Test Fallback Cascade'),
                      onPressed: _isTestingCascade ? null : () => _runCascadeTest(context),
                    ),

                    if (_cascadeLogs != null && _cascadeLogs!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cascade Audit Trail:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.starGold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ..._cascadeLogs!.map(
                              (log) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  log,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Courier',
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Providers Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Configured Providers (Priority Order)', style: AppTypography.titleSmall),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18, color: AppColors.starGold),
                    label: const Text('Add Custom', style: TextStyle(color: AppColors.starGold, fontSize: 12)),
                    onPressed: () => _showAddCustomDialog(context, notifier),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Reorderable Providers List (Supports drag-and-drop + arrow buttons)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: providers.length,
                onReorder: (oldIndex, newIndex) {
                  notifier.reorderProviders(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return _buildProviderCard(
                    key: ValueKey(provider.id),
                    context: context,
                    provider: provider,
                    index: index,
                    totalCount: providers.length,
                    now: now,
                    notifier: notifier,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    Key? key,
    required BuildContext context,
    required AiProviderConfig provider,
    required int index,
    required int totalCount,
    required DateTime now,
    required AiProvidersNotifier notifier,
  }) {
    final health = provider.getHealth(now);
    final isCooling = provider.isCoolingDown(now);
    final remainingCooldown = provider.remainingCooldownSeconds(now);

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nebulaCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: provider.isEnabled
              ? (isCooling
                  ? AppColors.scoreYellow.withOpacity(0.5)
                  : Colors.white.withOpacity(0.08))
              : Colors.white.withOpacity(0.03),
          width: isCooling ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(provider.type.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            provider.name,
                            style: AppTypography.titleSmall.copyWith(
                              color: provider.isEnabled ? Colors.white : Colors.white38,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _healthPill(health, remainingCooldown),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Model: ${provider.model}',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.isEnabled,
                activeColor: AppColors.xpGreen,
                onChanged: (val) {
                  notifier.toggleProvider(provider.id, val);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // API Key status preview
          Row(
            children: [
              Icon(
                provider.hasKey ? Icons.key : Icons.key_off,
                size: 14,
                color: provider.hasKey ? AppColors.xpGreen : AppColors.scoreRed,
              ),
              const SizedBox(width: 6),
              Text(
                provider.hasKey
                    ? 'Key: ••••••••${provider.apiKey.length > 4 ? provider.apiKey.substring(provider.apiKey.length - 4) : ""}'
                    : 'No API key set',
                style: TextStyle(
                  fontSize: 12,
                  color: provider.hasKey ? Colors.white70 : AppColors.scoreRed,
                ),
              ),
              const Spacer(),
              // Priority Reordering Buttons & Drag Handle
              if (index > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 16, color: Colors.white60),
                  tooltip: 'Move up priority',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => notifier.reorderProviders(index, index - 1),
                ),
              const SizedBox(width: 8),
              if (index < totalCount - 1)
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 16, color: Colors.white60),
                  tooltip: 'Move down priority',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => notifier.reorderProviders(index, index + 2),
                ),
              const SizedBox(width: 8),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.drag_indicator, size: 20, color: Colors.white38),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons: Edit Key, Test Connection, Docs
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                icon: const Icon(Icons.edit, size: 13, color: Colors.white70),
                label: const Text('Edit Key', style: TextStyle(fontSize: 11, color: Colors.white70)),
                onPressed: () => _showEditKeyDialog(context, provider, notifier),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
                icon: const Icon(Icons.network_check, size: 13, color: AppColors.starGold),
                label: const Text('Test', style: TextStyle(fontSize: 11, color: AppColors.starGold)),
                onPressed: () => _testSingleProvider(context, provider),
              ),
              if (provider.type == AiProviderType.custom) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.scoreRed),
                  tooltip: 'Delete Provider',
                  onPressed: () => notifier.deleteProvider(provider.id),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _healthPill(AiProviderHealth health, int remainingSeconds) {
    switch (health) {
      case AiProviderHealth.healthy:
        return _pill('Ready', AppColors.xpGreen);
      case AiProviderHealth.rateLimited:
        return _pill('Cooldown ${remainingSeconds}s', AppColors.scoreYellow);
      case AiProviderHealth.error:
        return _pill('Error', AppColors.scoreRed);
      case AiProviderHealth.disabled:
        return _pill('Disabled', Colors.white38);
    }
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Future<void> _runCascadeTest(BuildContext context) async {
    setState(() {
      _isTestingCascade = true;
      _cascadeLogs = ['Starting cascading circuit breaker test...'];
    });

    try {
      final repo = ref.read(aiProviderRepositoryProvider);
      final result = await repo.requestCoaching(
        sisterName: 'Maya',
        stage: DevelopmentalStage.middleSchool,
        score: 92,
        streakDays: 14,
        topSubject: 'Math',
      );

      setState(() {
        _cascadeLogs = [
          ...result.auditTrail,
          '🏁 Final Outcome: Provided by ${result.providerName}',
          'Coaching Preview: "${result.text.length > 80 ? '${result.text.substring(0, 80)}...' : result.text}"',
        ];
      });
    } catch (e) {
      setState(() {
        _cascadeLogs = [...?_cascadeLogs, 'Fatal Error: $e'];
      });
    } finally {
      if (mounted) {
        setState(() => _isTestingCascade = false);
      }
    }
  }

  Future<void> _testSingleProvider(BuildContext context, AiProviderConfig provider) async {
    final service = ref.read(aiFallbackServiceProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing connection to ${provider.name}...'),
        duration: const Duration(seconds: 1),
      ),
    );

    final res = await service.testConnection(provider);
    if (!context.mounted) return;

    final success = res['success'] as bool? ?? false;
    final message = res['message'] as String? ?? '';
    final latency = res['latencyMs'] as int? ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? AppColors.xpGreen : AppColors.scoreRed,
            ),
            const SizedBox(width: 8),
            Text(success ? 'Connection Verified' : 'Connection Failed',
                style: AppTypography.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${provider.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Model: ${provider.model}'),
            if (latency > 0) Text('Latency: ${latency}ms'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditKeyDialog(
    BuildContext context,
    AiProviderConfig provider,
    AiProvidersNotifier notifier,
  ) {
    final keyController = TextEditingController(text: provider.apiKey);
    final modelController = TextEditingController(text: provider.model);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit ${provider.name}', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Paste ${provider.type.name} free key',
                prefixIcon: const Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: 'Model Identifier',
                prefixIcon: Icon(Icons.memory),
              ),

            ),
            const SizedBox(height: 10),
            if (provider.type.keyDocumentationUrl.isNotEmpty)
              Text(
                'Get free key at: ${provider.type.keyDocumentationUrl}',
                style: const TextStyle(fontSize: 11, color: AppColors.starGold),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.saveProvider(
                provider.copyWith(
                  apiKey: keyController.text.trim(),
                  model: modelController.text.trim(),
                  clearError: true,
                ),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDialog(BuildContext context, AiProvidersNotifier notifier) {
    final nameController = TextEditingController(text: 'Local Ollama / Together');
    final urlController = TextEditingController(text: 'http://localhost:11434/v1/chat/completions');
    final keyController = TextEditingController();
    final modelController = TextEditingController(text: 'llama3.2');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.nebulaCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Custom AI Provider', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Presets (Free AI Key Givers):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.starGold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('Ollama Local', style: TextStyle(fontSize: 10)),
                      onPressed: () {
                        setDialogState(() {
                          nameController.text = 'Ollama Local';
                          urlController.text = 'http://localhost:11434/v1/chat/completions';
                          modelController.text = 'llama3.2';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('DeepSeek Free', style: TextStyle(fontSize: 10)),
                      onPressed: () {
                        setDialogState(() {
                          nameController.text = 'DeepSeek Free';
                          urlController.text = 'https://openrouter.ai/api/v1/chat/completions';
                          modelController.text = 'deepseek/deepseek-chat';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Together AI', style: TextStyle(fontSize: 10)),
                      onPressed: () {
                        setDialogState(() {
                          nameController.text = 'Together AI';
                          urlController.text = 'https://api.together.xyz/v1/chat/completions';
                          modelController.text = 'meta-llama/Llama-3.3-70B-Instruct-Turbo';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Cloudflare AI', style: TextStyle(fontSize: 10)),
                      onPressed: () {
                        setDialogState(() {
                          nameController.text = 'Cloudflare AI';
                          urlController.text = 'https://api.cloudflare.com/client/v4/accounts/{account_id}/ai/v1/chat/completions';
                          modelController.text = '@cf/meta/llama-3.3-70b-instruct';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Provider Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint URL',
                    hintText: 'https://.../v1/chat/completions',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(labelText: 'API Key (Optional for Local)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Model Identifier'),
                ),
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newConfig = AiProviderConfig(
                id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                type: AiProviderType.custom,
                apiKey: keyController.text.trim(),
                model: modelController.text.trim(),
                endpointUrl: urlController.text.trim(),
                priority: 10,
                isEnabled: true,
              );
              notifier.saveProvider(newConfig);
              Navigator.of(ctx).pop();
            },
            child: const Text('Add Provider'),
          ),
        ],
      ),
    ),
  );
}

  void _confirmReset(BuildContext context, AiProvidersNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.nebulaCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Providers?'),
        content: const Text(
          'This will reset all AI provider configurations and priorities to the recommended default free tiers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.scoreRed),
            onPressed: () {
              notifier.resetDefaults();
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
