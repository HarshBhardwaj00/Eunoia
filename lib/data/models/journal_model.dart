// Data transfer object for journal entries (used in journal_provider.dart)
// Note: Domain entity is in lib/domain/entities/journal_entry.dart
class JournalEntryDto {
  final String id;
  final String encryptedTitle;
  final String encryptedContent;
  final DateTime timestamp;

  JournalEntryDto({
    required this.id,
    required this.encryptedTitle,
    required this.encryptedContent,
    required this.timestamp,
  });
}
