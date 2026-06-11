/// Abstract entity schema for an encrypted Journal Entry
/// All sensitive content must be encrypted before storage using AES-256
/// Raw text must never be stored in plain text in Hive or Cloud Firestore
abstract class JournalEntry {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String encryptedContent;
  final String encryptionKeyHash;
  final List<String> tags;
  final int moodRating;

  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.encryptedContent,
    required this.encryptionKeyHash,
    this.tags = const [],
    required this.moodRating,
  });
}
