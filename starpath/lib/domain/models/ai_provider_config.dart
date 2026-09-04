/// Supported AI service providers (focusing on generous free tiers)
enum AiProviderType {
  /// Google Gemini Free Tier: 15 RPM, 1,000,000 TPM, 1,500 RPD (gemini-1.5-flash)
  gemini,

  /// Groq Cloud Free Tier: 30 RPM, 14,400 RPD (llama-3.3-70b-versatile / llama-3.1-8b-instant)
  groq,

  /// Mistral AI Free Tier: La Plateforme tier (mistral-small-latest / open-mistral-7b)
  mistral,

  /// OpenRouter Free Models: :free router endpoints (gemini-2.0-flash-exp:free, llama-3.3-70b:free)
  openRouter,

  /// Custom OpenAI-compatible endpoint (e.g. Local Ollama, Cloudflare Workers AI, vLLM, etc.)
  custom,
}

extension AiProviderTypeX on AiProviderType {
  String get displayName {
    switch (this) {
      case AiProviderType.gemini:
        return 'Google Gemini (Free Tier)';
      case AiProviderType.groq:
        return 'Groq (Free LLaMA-3.3)';
      case AiProviderType.mistral:
        return 'Mistral AI (Free Tier)';
      case AiProviderType.openRouter:
        return 'OpenRouter (Free Router)';
      case AiProviderType.custom:
        return 'Custom OpenAI Endpoint';
    }
  }

  String get defaultModel {
    switch (this) {
      case AiProviderType.gemini:
        return 'gemini-1.5-flash';
      case AiProviderType.groq:
        return 'llama-3.3-70b-versatile';
      case AiProviderType.mistral:
        return 'mistral-small-latest';
      case AiProviderType.openRouter:
        return 'google/gemini-2.0-flash-exp:free';
      case AiProviderType.custom:
        return 'gpt-3.5-turbo';
    }
  }

  String get defaultEndpoint {
    switch (this) {
      case AiProviderType.gemini:
        return 'https://generativelanguage.googleapis.com/v1beta/models';
      case AiProviderType.groq:
        return 'https://api.groq.com/openai/v1/chat/completions';
      case AiProviderType.mistral:
        return 'https://api.mistral.ai/v1/chat/completions';
      case AiProviderType.openRouter:
        return 'https://openrouter.ai/api/v1/chat/completions';
      case AiProviderType.custom:
        return 'http://localhost:11434/v1/chat/completions';
    }
  }

  String get keyDocumentationUrl {
    switch (this) {
      case AiProviderType.gemini:
        return 'https://aistudio.google.com/app/apikey';
      case AiProviderType.groq:
        return 'https://console.groq.com/keys';
      case AiProviderType.mistral:
        return 'https://console.mistral.ai/api-keys';
      case AiProviderType.openRouter:
        return 'https://openrouter.ai/keys';
      case AiProviderType.custom:
        return '';
    }
  }

  String get iconEmoji {
    switch (this) {
      case AiProviderType.gemini:
        return '✨';
      case AiProviderType.groq:
        return '⚡';
      case AiProviderType.mistral:
        return '🌪️';
      case AiProviderType.openRouter:
        return '🔀';
      case AiProviderType.custom:
        return '🛠️';
    }
  }
}

/// Operational status of an AI provider
enum AiProviderHealth {
  healthy,
  rateLimited,
  error,
  disabled,
}

/// Configuration for an AI provider instance with rate-limit and circuit breaker state
class AiProviderConfig {
  final String id;
  final String name;
  final AiProviderType type;
  final String apiKey;
  final String model;
  final String? endpointUrl;
  final bool isEnabled;
  final int priority; // 0 = highest priority, 1 = fallback 1, etc.
  final DateTime? cooldownUntil;
  final String? lastError;
  final DateTime? lastTestedAt;
  final int successCount;
  final int failureCount;

  const AiProviderConfig({
    required this.id,
    required this.name,
    required this.type,
    this.apiKey = '',
    required this.model,
    this.endpointUrl,
    this.isEnabled = true,
    this.priority = 0,
    this.cooldownUntil,
    this.lastError,
    this.lastTestedAt,
    this.successCount = 0,
    this.failureCount = 0,
  });

  bool get hasKey => apiKey.trim().isNotEmpty;

  bool isCoolingDown(DateTime now) {
    if (cooldownUntil == null) return false;
    return cooldownUntil!.isAfter(now);
  }

  int remainingCooldownSeconds(DateTime now) {
    if (cooldownUntil == null) return 0;
    final diff = cooldownUntil!.difference(now).inSeconds;
    return diff > 0 ? diff : 0;
  }

  AiProviderHealth getHealth(DateTime now) {
    if (!isEnabled) return AiProviderHealth.disabled;
    if (isCoolingDown(now)) return AiProviderHealth.rateLimited;
    if (lastError != null && failureCount > 0 && successCount == 0) {
      return AiProviderHealth.error;
    }
    return AiProviderHealth.healthy;
  }

  AiProviderConfig copyWith({
    String? id,
    String? name,
    AiProviderType? type,
    String? apiKey,
    String? model,
    String? endpointUrl,
    bool? isEnabled,
    int? priority,
    DateTime? cooldownUntil,
    bool clearCooldown = false,
    String? lastError,
    bool clearError = false,
    DateTime? lastTestedAt,
    int? successCount,
    int? failureCount,
  }) {
    return AiProviderConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      endpointUrl: endpointUrl ?? this.endpointUrl,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      cooldownUntil: clearCooldown ? null : (cooldownUntil ?? this.cooldownUntil),
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastTestedAt: lastTestedAt ?? this.lastTestedAt,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'apiKey': apiKey,
        'model': model,
        'endpointUrl': endpointUrl,
        'isEnabled': isEnabled,
        'priority': priority,
        'cooldownUntil': cooldownUntil?.toIso8601String(),
        'lastError': lastError,
        'lastTestedAt': lastTestedAt?.toIso8601String(),
        'successCount': successCount,
        'failureCount': failureCount,
      };

  factory AiProviderConfig.fromMap(Map<String, dynamic> map) {
    return AiProviderConfig(
      id: map['id'] as String? ?? 'default',
      name: map['name'] as String? ?? 'AI Provider',
      type: AiProviderType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => AiProviderType.gemini,
      ),
      apiKey: map['apiKey'] as String? ?? '',
      model: map['model'] as String? ?? 'gemini-1.5-flash',
      endpointUrl: map['endpointUrl'] as String?,
      isEnabled: map['isEnabled'] as bool? ?? true,
      priority: (map['priority'] as num?)?.toInt() ?? 0,
      cooldownUntil: map['cooldownUntil'] != null
          ? DateTime.tryParse(map['cooldownUntil'] as String)
          : null,
      lastError: map['lastError'] as String?,
      lastTestedAt: map['lastTestedAt'] != null
          ? DateTime.tryParse(map['lastTestedAt'] as String)
          : null,
      successCount: (map['successCount'] as num?)?.toInt() ?? 0,
      failureCount: (map['failureCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Initial pre-seeded free-tier provider configurations
  static List<AiProviderConfig> defaultProviders() {
    return const [
      AiProviderConfig(
        id: 'google-gemini',
        name: 'Google Gemini 1.5 Flash',
        type: AiProviderType.gemini,
        apiKey: '',
        model: 'gemini-1.5-flash',
        priority: 0,
        isEnabled: true,
      ),
      AiProviderConfig(
        id: 'groq-llama',
        name: 'Groq LLaMA-3.3 70B',
        type: AiProviderType.groq,
        apiKey: '',
        model: 'llama-3.3-70b-versatile',
        priority: 1,
        isEnabled: true,
      ),
      AiProviderConfig(
        id: 'mistral-small',
        name: 'Mistral Small',
        type: AiProviderType.mistral,
        apiKey: '',
        model: 'mistral-small-latest',
        priority: 2,
        isEnabled: true,
      ),
      AiProviderConfig(
        id: 'openrouter-free',
        name: 'OpenRouter Free Tier',
        type: AiProviderType.openRouter,
        apiKey: '',
        model: 'google/gemini-2.0-flash-exp:free',
        priority: 3,
        isEnabled: true,
      ),
      AiProviderConfig(
        id: 'custom-openai',
        name: 'Custom OpenAI / Local',
        type: AiProviderType.custom,
        apiKey: '',
        model: 'gpt-3.5-turbo',
        endpointUrl: 'https://api.openai.com/v1/chat/completions',
        priority: 4,
        isEnabled: false,
      ),
    ];
  }

}

/// Result returned from the cascading AI coaching engine
class AiCoachingResult {
  final String text;
  final String providerName;
  final String providerId;
  final bool wasOfflineFallback;
  final int latencyMs;
  final List<String> auditTrail;

  const AiCoachingResult({
    required this.text,
    required this.providerName,
    required this.providerId,
    this.wasOfflineFallback = false,
    required this.latencyMs,
    required this.auditTrail,
  });
}
