import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/ai_provider_config.dart';
import '../../domain/models/developmental_stage.dart';
import '../services/ai_fallback_service.dart';

final aiFallbackServiceProvider = Provider<AiFallbackService>((ref) {
  return AiFallbackService();
});

final aiProviderRepositoryProvider = Provider<AiProviderRepository>((ref) {
  return AiProviderRepository(
    fallbackService: ref.watch(aiFallbackServiceProvider),
  );
});

final aiProvidersStateProvider =
    StateNotifierProvider<AiProvidersNotifier, List<AiProviderConfig>>((ref) {
  final repo = ref.watch(aiProviderRepositoryProvider);
  return AiProvidersNotifier(repo);
});

final lastAiCoachingResultProvider = StateProvider<AiCoachingResult?>((ref) => null);

class AiProvidersNotifier extends StateNotifier<List<AiProviderConfig>> {
  final AiProviderRepository _repository;

  AiProvidersNotifier(this._repository) : super([]) {
    loadProviders();
  }

  Future<void> loadProviders() async {
    final list = await _repository.getProviders();
    state = list;
  }

  Future<void> saveProvider(AiProviderConfig config) async {
    await _repository.saveProvider(config);
    await loadProviders();
  }

  Future<void> toggleProvider(String id, bool enabled) async {
    await _repository.toggleProvider(id, enabled);
    await loadProviders();
  }

  Future<void> reorderProviders(int oldIndex, int newIndex) async {
    await _repository.reorder(oldIndex, newIndex);
    await loadProviders();
  }

  Future<void> resetDefaults() async {
    await _repository.resetToDefaults();
    await loadProviders();
  }

  Future<void> deleteProvider(String id) async {
    await _repository.deleteProvider(id);
    await loadProviders();
  }

  Future<void> recordRateLimit(String id, DateTime cooldownUntil, String? error) async {
    await _repository.recordRateLimit(id, cooldownUntil, error);
    await loadProviders();
  }

  Future<void> recordError(String id, String error) async {
    await _repository.recordError(id, error);
    await loadProviders();
  }

  Future<void> recordSuccess(String id) async {
    await _repository.recordSuccess(id);
    await loadProviders();
  }
}

class AiProviderRepository {
  static const _storageKey = 'starpath_ai_providers_v1';
  final AiFallbackService _fallbackService;

  AiProviderRepository({required AiFallbackService fallbackService})
      : _fallbackService = fallbackService;

  Future<List<AiProviderConfig>> getProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((item) => AiProviderConfig.fromMap(item as Map<String, dynamic>))
            .toList();
        list.sort((a, b) => a.priority.compareTo(b.priority));
        return list;
      }
    } catch (_) {}

    final defaults = AiProviderConfig.defaultProviders();
    await _saveAll(defaults);
    return defaults;
  }

  Future<void> saveProvider(AiProviderConfig config) async {
    final current = await getProviders();
    final index = current.indexWhere((p) => p.id == config.id);
    if (index >= 0) {
      current[index] = config;
    } else {
      current.add(config);
    }
    await _saveAll(current);
  }

  Future<void> toggleProvider(String id, bool enabled) async {
    final current = await getProviders();
    final index = current.indexWhere((p) => p.id == id);
    if (index >= 0) {
      current[index] = current[index].copyWith(isEnabled: enabled);
      await _saveAll(current);
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = await getProviders();
    if (oldIndex < 0 || oldIndex >= current.length) return;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= current.length) newIndex = current.length - 1;
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);

    for (int i = 0; i < current.length; i++) {
      current[i] = current[i].copyWith(priority: i);
    }
    await _saveAll(current);
  }

  Future<void> recordRateLimit(String id, DateTime cooldownUntil, String? error) async {
    final current = await getProviders();
    final index = current.indexWhere((p) => p.id == id);
    if (index >= 0) {
      current[index] = current[index].copyWith(
        cooldownUntil: cooldownUntil,
        lastError: error,
        failureCount: current[index].failureCount + 1,
      );
      await _saveAll(current);
    }
  }

  Future<void> recordError(String id, String error) async {
    final current = await getProviders();
    final index = current.indexWhere((p) => p.id == id);
    if (index >= 0) {
      current[index] = current[index].copyWith(
        lastError: error,
        failureCount: current[index].failureCount + 1,
      );
      await _saveAll(current);
    }
  }

  Future<void> recordSuccess(String id) async {
    final current = await getProviders();
    final index = current.indexWhere((p) => p.id == id);
    if (index >= 0) {
      current[index] = current[index].copyWith(
        clearCooldown: true,
        clearError: true,
        successCount: current[index].successCount + 1,
        lastTestedAt: DateTime.now(),
      );
      await _saveAll(current);
    }
  }

  Future<void> deleteProvider(String id) async {
    final current = await getProviders();
    current.removeWhere((p) => p.id == id);
    for (int i = 0; i < current.length; i++) {
      current[i] = current[i].copyWith(priority: i);
    }
    await _saveAll(current);
  }

  Future<void> resetToDefaults() async {
    final defaults = AiProviderConfig.defaultProviders();
    await _saveAll(defaults);
  }

  Future<AiCoachingResult> requestCoaching({
    required String sisterName,
    required DevelopmentalStage stage,
    required int score,
    required int streakDays,
    String? topSubject,
    String? focusSubject,
    int extrasCount = 0,
  }) async {
    final providers = await getProviders();

    return await _fallbackService.executeWithFallback(
      providers: providers,
      sisterName: sisterName,
      stage: stage,
      score: score,
      streakDays: streakDays,
      topSubject: topSubject,
      focusSubject: focusSubject,
      extrasCount: extrasCount,
      onRateLimited: (id, cooldown, error) async {
        await recordRateLimit(id, cooldown, error);
      },
      onError: (id, error) async {
        await recordError(id, error);
      },
      onSuccess: (id) async {
        await recordSuccess(id);
      },
    );
  }

  Future<void> _saveAll(List<AiProviderConfig> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(list.map((p) => p.toMap()).toList());
      await prefs.setString(_storageKey, data);
    } catch (_) {}
  }
}
