import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIAnalysisService {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  late final GenerativeModel _model;

  AIAnalysisService() {
    _model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: geminiApiKey);
  }

  Future<Map<String, dynamic>> analyzeJournal(String content) async {
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
    } catch (e) {
      // Handle API exceptions gracefully
      return {
        'sentiment': 'Neutral',
        'detectedEmotion': 'Unknown',
        'summary': 'Analysis failed: ${e.toString()}',
      };
    }
  }
}
