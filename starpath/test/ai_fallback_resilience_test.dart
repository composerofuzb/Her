import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:starpath/domain/models/ai_provider_config.dart';
import 'package:starpath/domain/models/developmental_stage.dart';
import 'package:starpath/data/services/ai_fallback_service.dart';
import 'package:starpath/domain/use_cases/psychological_offline_coaching.dart';

void main() {
  group('Multi-Provider AI Fallback & Resilience Manager Tests', () {
    test('Provider health states calculate correctly based on time and cooldown', () {
      final now = DateTime(2026, 9, 5, 12, 0, 0);

      // 1. Healthy provider
      const healthyProvider = AiProviderConfig(
        id: 'p1',
        name: 'Gemini',
        type: AiProviderType.gemini,
        apiKey: 'test-key',
        model: 'gemini-1.5-flash',
        isEnabled: true,
      );
      expect(healthyProvider.getHealth(now), AiProviderHealth.healthy);
      expect(healthyProvider.isCoolingDown(now), isFalse);

      // 2. Rate-limited provider in cooldown
      final coolingProvider = healthyProvider.copyWith(
        cooldownUntil: now.add(const Duration(seconds: 45)),
      );
      expect(coolingProvider.getHealth(now), AiProviderHealth.rateLimited);
      expect(coolingProvider.isCoolingDown(now), isTrue);
      expect(coolingProvider.remainingCooldownSeconds(now), 45);

      // 3. Expired cooldown becomes healthy again
      expect(coolingProvider.isCoolingDown(now.add(const Duration(seconds: 50))), isFalse);

      // 4. Disabled provider
      final disabledProvider = healthyProvider.copyWith(isEnabled: false);
      expect(disabledProvider.getHealth(now), AiProviderHealth.disabled);

      // 5. Errored provider
      final errorProvider = healthyProvider.copyWith(
        lastError: 'HTTP 500',
        failureCount: 2,
        successCount: 0,
      );
      expect(errorProvider.getHealth(now), AiProviderHealth.error);
    });

    test('Executes primary provider successfully when HTTP 200 is returned', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('googleapis.com')) {
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': 'Great job today Maya! Keep building your superpowers ⭐'}
                    ]
                  }
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not found', 404);
      });

      final service = AiFallbackService(client: mockClient);
      final providers = [
        const AiProviderConfig(
          id: 'gemini',
          name: 'Google Gemini',
          type: AiProviderType.gemini,
          apiKey: 'fake-gemini-key',
          model: 'gemini-1.5-flash',
          priority: 0,
        ),
      ];

      final result = await service.executeWithFallback(
        providers: providers,
        sisterName: 'Maya',
        stage: DevelopmentalStage.middleSchool,
        score: 90,
        streakDays: 14,
      );

      expect(result.wasOfflineFallback, isFalse);
      expect(result.providerName, 'Google Gemini');
      expect(result.text, contains('superpowers'));
      expect(result.auditTrail.any((entry) => entry.contains('Success via Google Gemini')), isTrue);
    });

    test('Automatic Cascading Circuit Breaker: cascades on HTTP 429 rate limit to next provider', () async {
      String? rateLimitedProviderId;
      DateTime? cooldownRecorded;

      final mockClient = MockClient((request) async {
        // Gemini (Priority 0) returns 429 Rate Limit Exceeded
        if (request.url.host.contains('googleapis.com')) {
          return http.Response(
            jsonEncode({'error': {'message': 'Resource has been exhausted (e.g. check quota)'}}),
            429,
            headers: {
              'retry-after': '60',
              'content-type': 'application/json; charset=utf-8',
            },
          );
        }

        // Groq (Priority 1) returns 200 Success
        if (request.url.host.contains('groq.com')) {
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {
                    'content': 'Groq LLaMA says: Fantastic 14-day streak! You are on fire 🚀'
                  }
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        return http.Response('Not found', 404);
      });

      final service = AiFallbackService(client: mockClient);
      final providers = [
        const AiProviderConfig(
          id: 'gemini',
          name: 'Google Gemini',
          type: AiProviderType.gemini,
          apiKey: 'key-gemini',
          model: 'gemini-1.5-flash',
          priority: 0,
        ),
        const AiProviderConfig(
          id: 'groq',
          name: 'Groq Cloud',
          type: AiProviderType.groq,
          apiKey: 'key-groq',
          model: 'llama-3.3-70b-versatile',
          priority: 1,
        ),
      ];

      final result = await service.executeWithFallback(
        providers: providers,
        sisterName: 'Maya',
        stage: DevelopmentalStage.middleSchool,
        score: 95,
        streakDays: 14,
        onRateLimited: (id, cooldown, error) {
          rateLimitedProviderId = id;
          cooldownRecorded = cooldown;
        },
      );

      // Verifications:
      expect(rateLimitedProviderId, 'gemini');
      expect(cooldownRecorded, isNotNull);
      expect(result.wasOfflineFallback, isFalse);
      expect(result.providerName, 'Groq Cloud');
      expect(result.text, contains('Groq LLaMA says'));

      // Check the audit trail records the exact rate-limit and cascade
      expect(
        result.auditTrail.any((a) => a.contains('Google Gemini rate-limited (HTTP 429')),
        isTrue,
      );
      expect(
        result.auditTrail.any((a) => a.contains('Success via Groq Cloud')),
        isTrue,
      );
    });

    test('Seamlessly falls back to Psychological Offline Engine when all APIs fail or offline', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = AiFallbackService(client: mockClient);
      final providers = [
        const AiProviderConfig(
          id: 'gemini',
          name: 'Google Gemini',
          type: AiProviderType.gemini,
          apiKey: 'key-gemini',
          model: 'gemini-1.5-flash',
          priority: 0,
        ),
      ];

      final result = await service.executeWithFallback(
        providers: providers,
        sisterName: 'Maya',
        stage: DevelopmentalStage.middleSchool,
        score: 92,
        streakDays: 14,
        topSubject: 'Math',
      );

      expect(result.wasOfflineFallback, isTrue);
      expect(result.providerName, 'Psychological Offline Engine');
      expect(result.text, contains('Supernova performance today, Maya!'));
      expect(
        result.auditTrail.any((a) => a.contains('Activating Psychological Offline Coaching Engine')),
        isTrue,
      );
    });

    test('PsychologicalOfflineCoachingEngine generates nuanced advice across stages and scores', () {
      // Middle school high score
      final middleHigh = PsychologicalOfflineCoachingEngine.generateCoaching(
        sisterName: 'Maya',
        stage: DevelopmentalStage.middleSchool,
        score: 95,
        streakDays: 14,
        topSubject: 'Math',
      );
      expect(middleHigh.contains('Supernova'), isTrue);
      expect(middleHigh.contains('14-day streak is blazing'), isTrue);

      // High school recharge score
      final hsLow = PsychologicalOfflineCoachingEngine.generateCoaching(
        sisterName: 'Maya',
        stage: DevelopmentalStage.highSchool,
        score: 55,
        streakDays: 2,
        focusSubject: 'AP Physics',
      );
      expect(hsLow.contains('Reset and recalibrate'), isTrue);
      expect(hsLow.contains('AP Physics'), isTrue);

      // University mastery score
      final univHigh = PsychologicalOfflineCoachingEngine.generateCoaching(
        sisterName: 'Maya',
        stage: DevelopmentalStage.university,
        score: 90,
        streakDays: 20,
      );
      expect(univHigh.contains('Intellectual mastery'), isTrue);
    });

    test('Handles malformed URL, empty URL, or network exception gracefully without crashing (Attack Vector 1)', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('groq.com')) {
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'Groq fallback rescued the request! 🚀'}
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        throw http.ClientException('Connection refused');
      });

      final service = AiFallbackService(client: mockClient);
      final providers = [
        // Provider with invalid/malformed endpoint URL
        const AiProviderConfig(
          id: 'bad-url-provider',
          name: 'Broken URL Endpoint',
          type: AiProviderType.custom,
          apiKey: 'key',
          model: 'custom-model',
          endpointUrl: 'http://', // Invalid host!
          priority: 0,
        ),
        // Provider with empty endpointUrl (should fallback to default endpoint or cascade)
        const AiProviderConfig(
          id: 'unreachable-provider',
          name: 'Unreachable Endpoint',
          type: AiProviderType.custom,
          apiKey: 'key',
          model: 'custom-model',
          endpointUrl: 'http://127.0.0.1:54321/v1/chat/completions',
          priority: 1,
        ),
        // Healthy fallback provider
        const AiProviderConfig(
          id: 'groq',
          name: 'Groq Cloud',
          type: AiProviderType.groq,
          apiKey: 'key-groq',
          model: 'llama-3.3-70b-versatile',
          priority: 2,
        ),
      ];

      final result = await service.executeWithFallback(
        providers: providers,
        sisterName: 'Maya',
        stage: DevelopmentalStage.middleSchool,
        score: 88,
        streakDays: 7,
      );

      expect(result.wasOfflineFallback, isFalse);
      expect(result.providerName, 'Groq Cloud');
      expect(result.text, contains('Groq fallback rescued'));
      expect(
        result.auditTrail.any((a) => a.contains('Broken URL Endpoint exception')),
        isTrue,
      );
      expect(
        result.auditTrail.any((a) => a.contains('Unreachable Endpoint exception')),
        isTrue,
      );
    });

    test('Concatenates multi-part Gemini content and array-based OpenAI content', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('googleapis.com')) {
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': 'Part 1: Great dedication! '},
                      {'text': 'Part 2: You mastered AP Calculus today! ⭐'}
                    ]
                  }
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not found', 404);
      });

      final service = AiFallbackService(client: mockClient);
      final providers = [
        const AiProviderConfig(
          id: 'gemini',
          name: 'Gemini MultiPart',
          type: AiProviderType.gemini,
          apiKey: 'test-key',
          model: 'gemini-1.5-flash',
          priority: 0,
        ),
      ];

      final result = await service.executeWithFallback(
        providers: providers,
        sisterName: 'Maya',
        stage: DevelopmentalStage.highSchool,
        score: 95,
        streakDays: 10,
      );

      expect(result.text, contains('Part 1: Great dedication!'));
      expect(result.text, contains('Part 2: You mastered AP Calculus'));
    });

    test('Cascades when HTTP 200 contains unparseable or empty content', () async {
      final mockClient = MockClient((request) async {
        if (request.url.host.contains('googleapis.com')) {
          // Gemini returns 200 with empty parts (e.g. filtered)
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'finishReason': 'SAFETY',
                  'content': {'parts': []}
                }
              ]
            }),
            200,
          );
        }
        if (request.url.host.contains('groq.com')) {
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'Fallback Groq advice 🌟'}
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('Not found', 404);
      });

      final service = AiFallbackService(client: mockClient);
      final providers = [
        const AiProviderConfig(
          id: 'gemini',
          name: 'Gemini Safety Filtered',
          type: AiProviderType.gemini,
          apiKey: 'key',
          model: 'gemini-1.5-flash',
          priority: 0,
        ),
        const AiProviderConfig(
          id: 'groq',
          name: 'Groq Cloud',
          type: AiProviderType.groq,
          apiKey: 'key',
          model: 'llama-3.3-70b-versatile',
          priority: 1,
        ),
      ];

      final result = await service.executeWithFallback(
        providers: providers,
        sisterName: 'Maya',
        stage: DevelopmentalStage.middleSchool,
        score: 80,
        streakDays: 5,
      );

      expect(result.providerName, 'Groq Cloud');
      expect(result.text, 'Fallback Groq advice 🌟');
      expect(
        result.auditTrail.any((a) => a.contains('returned HTTP 200 but content was empty or unparseable')),
        isTrue,
      );
    });

    test('testConnection detects unparseable 200 response and quota error accurately', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('empty-200')) {
          return http.Response('{}', 200);
        }
        if (request.url.toString().contains('quota-429')) {
          return http.Response(
            jsonEncode({'error': {'message': 'RESOURCE_EXHAUSTED: daily limit reached'}}),
            403,
          );
        }
        return http.Response('OK', 200);
      });

      final service = AiFallbackService(client: mockClient);

      // Empty JSON response on 200 must NOT claim success
      final resEmpty = await service.testConnection(
        const AiProviderConfig(
          id: 'p-empty',
          name: 'Empty Provider',
          type: AiProviderType.custom,
          apiKey: 'key',
          model: 'm',
          endpointUrl: 'http://test.com/empty-200',
        ),
      );
      expect(resEmpty['success'], isFalse);

      // RESOURCE_EXHAUSTED error must be detected as rate/quota limit
      final resQuota = await service.testConnection(
        const AiProviderConfig(
          id: 'p-quota',
          name: 'Quota Provider',
          type: AiProviderType.custom,
          apiKey: 'key',
          model: 'm',
          endpointUrl: 'http://test.com/quota-429',
        ),
      );
      expect(resQuota['success'], isFalse);
      expect(resQuota['isRateLimit'], isTrue);
    });
  });
}
