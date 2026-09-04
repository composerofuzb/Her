import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/ai_provider_config.dart';
import '../../domain/models/developmental_stage.dart';
import '../../domain/use_cases/psychological_offline_coaching.dart';
import '../../domain/use_cases/developmental_stage_engine.dart';

/// Service implementing multi-provider AI resilience with automatic
/// cascading circuit breaking across free-tier AI endpoints.
class AiFallbackService {
  final http.Client _client;

  AiFallbackService({http.Client? client}) : _client = client ?? http.Client();

  /// Executes AI coaching with automatic cascading fallback
  Future<AiCoachingResult> executeWithFallback({
    required List<AiProviderConfig> providers,
    required String sisterName,
    required DevelopmentalStage stage,
    required int score,
    required int streakDays,
    String? topSubject,
    String? focusSubject,
    int extrasCount = 0,
    FutureOr<void> Function(String providerId, DateTime cooldownUntil, String? error)? onRateLimited,
    FutureOr<void> Function(String providerId, String error)? onError,
    FutureOr<void> Function(String providerId)? onSuccess,
  }) async {
    final now = DateTime.now();
    final auditTrail = <String>[];

    // 1. Sort enabled providers by priority (0 is highest)
    final sortedProviders = [...providers]
      ..sort((a, b) => a.priority.compareTo(b.priority));

    final systemPrompt = DevelopmentalStageEngine.buildSystemPrompt(
      stage: stage,
      sisterName: sisterName,
    );

    final userPrompt = '''
Sister's name: $sisterName
Developmental Stage: ${stage.stageName} (${stage.ageRangeDescription})
Today's Academic Score: $score / 100
Current Streak: $streakDays days
Top Subject: ${topSubject ?? 'General Studies'}
Subject for Attention: ${focusSubject ?? 'None'}
Bonus Activities: $extrasCount

Please provide a concise (2-3 sentences), uplifting, stage-appropriate coaching message for her.
Include 1 actionable focus tip for tomorrow and an encouraging cosmic emoji.
''';

    for (final provider in sortedProviders) {
      if (!provider.isEnabled) {
        auditTrail.add('⚪ Skipped ${provider.name}: Provider is disabled.');
        continue;
      }

      if (!provider.hasKey) {
        auditTrail.add('⚠️ Skipped ${provider.name}: No API key provided.');
        continue;
      }

      if (provider.isCoolingDown(now)) {
        final remaining = provider.remainingCooldownSeconds(now);
        auditTrail.add(
            '⏳ Skipped ${provider.name}: Circuit open (Rate-limit cooldown active for ${remaining}s).');
        continue;
      }

      final stopwatch = Stopwatch()..start();
      auditTrail.add('🚀 Attempting ${provider.name} (${provider.model})...');

      try {
        final result = await _callProvider(
          provider: provider,
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
        );

        stopwatch.stop();

        final responseBody = utf8.decode(result.bodyBytes, allowMalformed: true);

        if (result.statusCode == 200) {
          final content = _extractContent(provider, responseBody);
          if (content != null && content.trim().isNotEmpty) {
            auditTrail.add(
                '✅ Success via ${provider.name} (${stopwatch.elapsedMilliseconds}ms).');
            await onSuccess?.call(provider.id);

            return AiCoachingResult(
              text: content.trim(),
              providerName: provider.name,
              providerId: provider.id,
              wasOfflineFallback: false,
              latencyMs: stopwatch.elapsedMilliseconds,
              auditTrail: auditTrail,
            );
          } else {
            auditTrail.add(
                '❌ ${provider.name} returned HTTP 200 but content was empty or unparseable. Cascading...');
            await onError?.call(provider.id, 'Empty or unparseable response body');
            continue;
          }
        }

        // Handle Rate Limit (HTTP 429) or Quota Exceeded
        if (_isRateLimited(result.statusCode, responseBody)) {
          final retryAfterHeader = result.headers['retry-after'];
          int cooldownSec = 60;
          if (retryAfterHeader != null) {
            cooldownSec = int.tryParse(retryAfterHeader) ?? 60;
          }
          final cooldownUntil = DateTime.now().add(Duration(seconds: cooldownSec));

          auditTrail.add(
              '🚫 ${provider.name} rate-limited (HTTP ${result.statusCode} / Quota). Circuit opened for ${cooldownSec}s. Cascading to next provider...');
          await onRateLimited?.call(
            provider.id,
            cooldownUntil,
            'Rate limit exceeded (HTTP ${result.statusCode}). Cooldown for ${cooldownSec}s.',
          );
          continue; // Cascades to next provider!
        }

        // Other HTTP Error (e.g. 401 Bad Key, 500, 503)
        final preview = responseBody.length > 80 ? '${responseBody.substring(0, 80)}...' : responseBody;
        auditTrail.add(
            '❌ ${provider.name} returned HTTP ${result.statusCode} ($preview). Cascading...');
        await onError?.call(
          provider.id,
          'HTTP ${result.statusCode}: $preview',
        );
      } catch (e) {
        stopwatch.stop();
        auditTrail.add('❌ ${provider.name} exception: $e. Cascading...');
        await onError?.call(provider.id, e.toString());
      }
    }

    // 2. Offline Fallback: If all online providers were rate-limited or failed
    auditTrail.add(
        '🌿 All online providers exhausted or rate-limited. Activating Psychological Offline Coaching Engine.');

    final offlineText = PsychologicalOfflineCoachingEngine.generateCoaching(
      sisterName: sisterName,
      stage: stage,
      score: score,
      streakDays: streakDays,
      topSubject: topSubject,
      focusSubject: focusSubject,
      extrasCount: extrasCount,
    );

    return AiCoachingResult(
      text: offlineText,
      providerName: 'Psychological Offline Engine',
      providerId: 'offline-psychology',
      wasOfflineFallback: true,
      latencyMs: 1,
      auditTrail: auditTrail,
    );
  }

  /// Pings an individual provider to verify connectivity and API key validity
  Future<Map<String, dynamic>> testConnection(AiProviderConfig provider) async {
    if (!provider.hasKey) {
      return {
        'success': false,
        'message': 'No API key entered.',
        'latencyMs': 0,
      };
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _callProvider(
        provider: provider,
        systemPrompt: 'You are an AI test echo.',
        userPrompt: 'Reply with the word OK.',
      );
      stopwatch.stop();

      final responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
      if (response.statusCode == 200) {
        final content = _extractContent(provider, responseBody);
        if (content != null && content.trim().isNotEmpty) {
          return {
            'success': true,
            'message': 'Connected! Response: "${content.trim()}"',
            'latencyMs': stopwatch.elapsedMilliseconds,
          };
        } else {
          return {
            'success': false,
            'message': 'HTTP 200 received, but could not extract AI message response.',
            'latencyMs': stopwatch.elapsedMilliseconds,
          };
        }
      } else if (_isRateLimited(response.statusCode, responseBody)) {
        return {
          'success': false,
          'message': 'Provider returned Rate Limit (HTTP ${response.statusCode}). Free quota exhausted.',
          'latencyMs': stopwatch.elapsedMilliseconds,
          'isRateLimit': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed with HTTP ${response.statusCode}: $responseBody',
          'latencyMs': stopwatch.elapsedMilliseconds,
        };
      }
    } catch (e) {
      stopwatch.stop();
      return {
        'success': false,
        'message': 'Connection error: $e',
        'latencyMs': stopwatch.elapsedMilliseconds,
      };
    }
  }

  /// Internal dispatcher based on provider type
  Future<http.Response> _callProvider({
    required AiProviderConfig provider,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    const timeout = Duration(seconds: 10);

    if (provider.type == AiProviderType.gemini) {
      final key = Uri.encodeQueryComponent(provider.apiKey.trim());
      final model = Uri.encodeComponent(provider.model.trim());
      final endpointStr = (provider.endpointUrl != null && provider.endpointUrl!.trim().isNotEmpty)
          ? provider.endpointUrl!.trim()
          : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$key';
      final url = Uri.tryParse(endpointStr);
      if (url == null || !url.hasScheme || url.host.isEmpty) {
        throw FormatException('Invalid endpoint URL: "$endpointStr"');
      }

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\n$userPrompt'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 350,
        }
      });

      return await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(timeout);
    } else {
      // OpenAI-compatible endpoint (Groq, Mistral, OpenRouter, Custom)
      final endpointRaw = provider.endpointUrl?.trim();
      final endpointStr = (endpointRaw != null && endpointRaw.isNotEmpty)
          ? endpointRaw
          : provider.type.defaultEndpoint;
      final url = Uri.tryParse(endpointStr);
      if (url == null || !url.hasScheme || url.host.isEmpty) {
        throw FormatException('Invalid endpoint URL: "$endpointStr"');
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${provider.apiKey.trim()}',
      };

      if (provider.type == AiProviderType.openRouter) {
        headers['HTTP-Referer'] = 'https://starpath.app';
        headers['X-Title'] = 'StarPath Learning Companion';
      }

      final body = jsonEncode({
        'model': provider.model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.7,
        'max_tokens': 350,
      });

      return await _client
          .post(
            url,
            headers: headers,
            body: body,
          )
          .timeout(timeout);
    }
  }

  /// Parses text from various AI API response JSON shapes
  String? _extractContent(AiProviderConfig provider, String responseBody) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      if (provider.type == AiProviderType.gemini) {
        final candidates = json['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final first = candidates.first as Map<String, dynamic>;
          final content = first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final buffer = StringBuffer();
            for (final part in parts) {
              if (part is Map<String, dynamic>) {
                final text = part['text'];
                if (text is String && text.isNotEmpty) {
                  buffer.write(text);
                }
              }
            }
            if (buffer.isNotEmpty) return buffer.toString();
          }
        }
      } else {
        // OpenAI / Groq / Mistral / OpenRouter shape
        final choices = json['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final first = choices.first as Map<String, dynamic>;
          final message = first['message'] as Map<String, dynamic>?;
          final rawContent = message?['content'];
          if (rawContent is String) {
            return rawContent;
          } else if (rawContent is List) {
            final buffer = StringBuffer();
            for (final item in rawContent) {
              if (item is Map<String, dynamic> && item['text'] is String) {
                buffer.write(item['text']);
              } else if (item is String) {
                buffer.write(item);
              }
            }
            if (buffer.isNotEmpty) return buffer.toString();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Detects if an HTTP response represents a rate-limit or quota error across providers
  bool _isRateLimited(int statusCode, String responseBody) {
    if (statusCode == 429) return true;
    final lower = responseBody.toLowerCase();
    return lower.contains('quota') ||
        lower.contains('rate limit') ||
        lower.contains('rate_limit_exceeded') ||
        lower.contains('resource_exhausted') ||
        lower.contains('insufficient_quota') ||
        lower.contains('too many requests') ||
        lower.contains('tokens per minute') ||
        lower.contains('requests per minute') ||
        lower.contains('requests per day');
  }
}
