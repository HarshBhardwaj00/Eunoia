import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIAnalysisService {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'AQ.Ab8RN6JZZyTYAqwLId8X3zx1j61zU1XMCVJ-bChd0bT1LDNIRA');
  late final GenerativeModel _model;

  AIAnalysisService() {
    _model = GenerativeModel(model: 'gemini-3.1-flash-lite', apiKey: geminiApiKey);
  }

  Future<Map<String, dynamic>> analyzeJournal(String content) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);
    const fallbackMessage = 'Our AI companion is taking a short breather due to high demand. Your insights will refresh shortly!';

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final prompt =
            '''
Analyze this personal journal text. Return raw JSON data containing exactly these keys: "sentiment" (String: Positive/Negative/Neutral), "detectedEmotion" (String: Sadness/Anxiety/Joy/etc.), and "summary" (String: One brief sentence summing up the emotional core). Text: $content
''';

        final response = await _model.generateContent([Content.text(prompt)]);
        final responseText = response.text ?? '';

        // Extract JSON from response (in case there's extra text)
        final jsonMatch = RegExp(
          r'\{.*\}',
          dotAll: true,
        ).firstMatch(responseText);
        if (jsonMatch == null) {
          throw Exception('No JSON found in response');
        }

        final jsonString = jsonMatch.group(0) ?? '{}';
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

        return jsonData;
      } on GenerativeAIException catch (e) {
        // If it's a server error (503/UNAVAILABLE), retry
        if (e.message.contains('503') || e.message.contains('UNAVAILABLE')) {
          if (attempt < maxRetries) {
            await Future.delayed(retryDelay);
            continue;
          } else {
            // All retries exhausted, return fallback
            return {
              'sentiment': 'Neutral',
              'detectedEmotion': 'Unknown',
              'summary': fallbackMessage,
            };
          }
        }
        // For other GenerativeAIException errors, return fallback immediately
        return {
          'sentiment': 'Neutral',
          'detectedEmotion': 'Unknown',
          'summary': fallbackMessage,
        };
      } catch (e) {
        // For non-GenerativeAIException errors, return fallback
        return {
          'sentiment': 'Neutral',
          'detectedEmotion': 'Unknown',
          'summary': fallbackMessage,
        };
      }
    }

    // This should never be reached, but return fallback as safety net
    return {
      'sentiment': 'Neutral',
      'detectedEmotion': 'Unknown',
      'summary': fallbackMessage,
    };
  }
}
