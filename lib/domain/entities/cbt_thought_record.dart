/// Abstract entity schema for a multi-step CBT Thought Record
/// Follows Cognitive Behavioral Therapy methodology for thought challenging
/// All sensitive content must be encrypted before storage using AES-256
abstract class CBTThoughtRecord {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String encryptedSituation;
  final String encryptedAutomaticThoughts;
  final String encryptedEmotions;
  final List<String> cognitiveDistortions;
  final String encryptedAlternativeThoughts;
  final String encryptedOutcome;
  final int distressLevelBefore;
  final int distressLevelAfter;
  final String encryptionKeyHash;
  
  const CBTThoughtRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.encryptedSituation,
    required this.encryptedAutomaticThoughts,
    required this.encryptedEmotions,
    this.cognitiveDistortions = const [],
    required this.encryptedAlternativeThoughts,
    required this.encryptedOutcome,
    required this.distressLevelBefore,
    required this.distressLevelAfter,
    required this.encryptionKeyHash,
  });
}
