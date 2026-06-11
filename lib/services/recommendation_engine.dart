class RecommendationEngine {
  Map<String, dynamic> getRecommendation(
    Map<String, dynamic> recentAiAnalysis,
    int sleepHours,
  ) {
    final detectedEmotion = recentAiAnalysis['detectedEmotion'] as String?;
    final sentiment = recentAiAnalysis['sentiment'] as String?;

    // Check for anxiety or negative sentiment
    if (detectedEmotion == 'Anxiety' || sentiment == 'Negative') {
      return {
        'message':
            'You often feel anxious at night. Try a 2-minute breathing session.',
        'action': 'route_breathing',
      };
    }

    // Check for insufficient sleep
    if (sleepHours < 6) {
      return {
        'message':
            'Your sleep duration dropped to $sleepHours hrs. Maintaining strict rest periods directly lowers emotional instability.',
        'action': null,
      };
    }

    // Default fallback - positive mental health reminder
    return {
      'message':
          'You\'re doing great! Keep up the positive momentum with your journaling and self-care routine.',
      'action': null,
    };
  }

  /// Get action warning map based on latest journal metadata
  Map<String, dynamic>? getActionWarning(Map<String, dynamic> journalMetadata) {
    final detectedEmotion = journalMetadata['detectedEmotion'] as String?;
    final sentiment = journalMetadata['sentiment'] as String?;

    // Check for high anxiety or negative sentiment
    if (detectedEmotion == 'Anxiety' ||
        detectedEmotion == 'Stress' ||
        sentiment == 'Negative' ||
        sentiment == 'Very Negative') {
      return {
        'message':
            'You often feel anxious at night. Try a 2-minute breathing session.',
        'action': 'route_breathing',
      };
    }

    return null;
  }
}
