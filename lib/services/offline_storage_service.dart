import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/local_journal_model.dart';

class OfflineStorageService {
  static OfflineStorageService? _instance;
  static Box<LocalJournal>? _journalBox;

  OfflineStorageService._internal();

  static OfflineStorageService get instance {
    _instance ??= OfflineStorageService._internal();
    return _instance!;
  }

  Future<Box<LocalJournal>> get journalBox async {
    if (_journalBox != null && _journalBox!.isOpen) return _journalBox!;

    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    if (!Hive.isAdapterRegistered(LocalJournalAdapter().typeId)) {
      Hive.registerAdapter(LocalJournalAdapter());
    }

    _journalBox = await Hive.openBox<LocalJournal>('local_journals');
    return _journalBox!;
  }

  /// Save journal entry to local Hive database
  Future<void> saveJournalEntry(LocalJournal journal) async {
    final box = await journalBox;
    await box.put(journal.id, journal);
  }

  /// Get all journal entries from local Hive database
  Future<List<LocalJournal>> getAllJournals() async {
    final box = await journalBox;
    final journals = box.values.toList();
    journals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return journals;
  }

  /// Stream of all journal entries from local Hive database
  Stream<List<LocalJournal>> watchJournals() async* {
    final box = await journalBox;
    yield box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get journal entries by user ID
  Future<List<LocalJournal>> getJournalsByUid(String uid) async {
    final box = await journalBox;
    final journals = box.values.where((j) => j.uid == uid).toList();
    journals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return journals;
  }

  /// Update journal entry sync status
  Future<void> updateSyncStatus(String id, bool isSynced) async {
    final box = await journalBox;
    final journal = box.get(id);
    if (journal != null) {
      journal.isSynced = isSynced;
      await box.put(id, journal);
    }
  }

  /// Delete journal entry from local database
  Future<void> deleteJournalEntry(String id) async {
    final box = await journalBox;
    await box.delete(id);
  }

  /// Mark journal entry as pending deletion (for offline scenario)
  Future<void> markAsDeletedPending(String id) async {
    final box = await journalBox;
    final journal = box.get(id);
    if (journal != null) {
      journal.isDeletedPending = true;
      await box.put(id, journal);
    }
  }

  /// Get journals marked for pending deletion
  Future<List<LocalJournal>> getPendingDeletions() async {
    final box = await journalBox;
    return box.values.where((j) => j.isDeletedPending == true).toList();
  }

  /// Get unsynced journal entries
  Future<List<LocalJournal>> getUnsyncedJournals() async {
    final box = await journalBox;
    return box.values.where((j) => !j.isSynced).toList();
  }

  /// Clear all local data (use with caution)
  Future<void> clearAll() async {
    final box = await journalBox;
    await box.clear();
  }

  /// Close Hive instance
  Future<void> close() async {
    if (_journalBox != null && _journalBox!.isOpen) {
      await _journalBox!.close();
      _journalBox = null;
    }
  }
}
