import 'package:cloud_firestore/cloud_firestore.dart';

// Data transfer object for mood logs (used in journal_repository.dart)
class MoodLog {
  final String id;
  final String encryptedTitle;
  final String encryptedContent;
  final DateTime timestamp;
  final String? sentiment;
  final String? detectedEmotion;
  final String? summary;
  final int? sleepHours;

  MoodLog({
    required this.id,
    required this.encryptedTitle,
    required this.encryptedContent,
    required this.timestamp,
    this.sentiment,
    this.detectedEmotion,
    this.summary,
    this.sleepHours,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'encryptedTitle': encryptedTitle,
      'encryptedContent': encryptedContent,
      'timestamp': Timestamp.fromDate(timestamp),
      'sentiment': sentiment,
      'detectedEmotion': detectedEmotion,
      'summary': summary,
      'sleepHours': sleepHours,
    };
  }

  factory MoodLog.fromFirestore(Map<String, dynamic> data) {
    return MoodLog(
      id: data['id'] as String,
      encryptedTitle: data['encryptedTitle'] as String,
      encryptedContent: data['encryptedContent'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sentiment: data['sentiment'] as String?,
      detectedEmotion: data['detectedEmotion'] as String?,
      summary: data['summary'] as String?,
      sleepHours: data['sleepHours'] as int?,
    );
  }
}
