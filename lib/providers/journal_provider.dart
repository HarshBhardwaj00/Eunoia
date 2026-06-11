import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/crypto/encryption_utility.dart';
import '../data/models/journal_model.dart';

// Journal state
enum JournalStatus { initial, loading, loaded, error }

class JournalState {
  final JournalStatus status;
  final List<JournalEntryDto> entries;
  final String? errorMessage;

  const JournalState({
    this.status = JournalStatus.initial,
    this.entries = const [],
    this.errorMessage,
  });

  JournalState copyWith({
    JournalStatus? status,
    List<JournalEntryDto>? entries,
    String? errorMessage,
  }) {
    return JournalState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Journal state notifier
class JournalNotifier extends StateNotifier<JournalState> {
  static const String _journalBoxName = 'journal_entries';
  static const String _firestoreCollection = 'user_journals';
  late Box<JournalEntryDto> _journalBox;
  final FirebaseFirestore _firestore;

  JournalNotifier(this._firestore) : super(const JournalState());

  Future<void> loadJournals() async {
    try {
      state = state.copyWith(status: JournalStatus.loading);

      _journalBox = await Hive.openBox<JournalEntryDto>(_journalBoxName);
      final entries = _journalBox.values.toList();

      state = state.copyWith(status: JournalStatus.loaded, entries: entries);
    } catch (e) {
      state = state.copyWith(
        status: JournalStatus.error,
        errorMessage: 'Failed to load journals: $e',
      );
    }
  }

  Future<void> saveJournalEntry(String title, String content) async {
    try {
      state = state.copyWith(status: JournalStatus.loading);

      // Encrypt title and content using AES-256
      final encryptedTitle = await EncryptionUtility.encryptText(title);
      final encryptedContent = await EncryptionUtility.encryptText(content);

      // Create journal entry with encrypted data
      final entry = JournalEntryDto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        encryptedTitle: encryptedTitle,
        encryptedContent: encryptedContent,
        timestamp: DateTime.now(),
      );

      // Save to local Hive box
      _journalBox = await Hive.openBox<JournalEntryDto>(_journalBoxName);
      await _journalBox.put(entry.id, entry);

      // Sync to Firestore with only ciphertext payload
      await _firestore.collection(_firestoreCollection).doc(entry.id).set({
        'encryptedTitle': encryptedTitle,
        'encryptedContent': encryptedContent,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Reload journals to update state
      final entries = _journalBox.values.toList();
      state = state.copyWith(status: JournalStatus.loaded, entries: entries);
    } catch (e) {
      state = state.copyWith(
        status: JournalStatus.error,
        errorMessage: 'Failed to save journal entry: $e',
      );
    }
  }
}

// Journal provider
final journalProvider = StateNotifierProvider<JournalNotifier, JournalState>((
  ref,
) {
  return JournalNotifier(FirebaseFirestore.instance);
});
