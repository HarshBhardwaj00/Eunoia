import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../data/models/mood_log_model.dart';
import '../data/models/local_journal_model.dart';
import 'encryption_service.dart';
import 'offline_storage_service.dart';

class JournalRepository {
  static const String _firestoreCollection = 'user_journals';
  final FirebaseFirestore _firestore;
  List<MoodLog> _localCache = [];
  final OfflineStorageService _offlineStorage = OfflineStorageService.instance;
  final InternetConnectionChecker _connectionChecker;

  JournalRepository(this._firestore)
    : _connectionChecker = InternetConnectionChecker.createInstance();

  Future<void> initialize() async {
    // Load initial data from local Hive database for instant UI
    await _loadFromHive();
  }

  Future<void> _loadFromHive() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _localCache = [];
        return;
      }

      final localJournals = await _offlineStorage.getJournalsByUid(uid);

      // Convert LocalJournal to MoodLog with decryption
      _localCache = localJournals.map((localJournal) {
        // Decrypt fields
        String decryptedTitle;
        String decryptedContent;

        try {
          decryptedTitle = EncryptionService.decryptData(
            localJournal.encryptedTitle,
          );
        } catch (e) {
          decryptedTitle = localJournal.encryptedTitle;
        }

        try {
          decryptedContent = EncryptionService.decryptData(
            localJournal.encryptedContent,
          );
        } catch (e) {
          decryptedContent = localJournal.encryptedContent;
        }

        return MoodLog(
          id: localJournal.id,
          encryptedTitle: decryptedTitle,
          encryptedContent: decryptedContent,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            localJournal.timestamp,
          ),
          sentiment: localJournal.sentiment,
          detectedEmotion: localJournal.detectedEmotion,
          summary: localJournal.summary,
          sleepHours: localJournal.sleepHours,
        );
      }).toList();
    } catch (e) {
      // If Isar fails, start with empty cache
      _localCache = [];
    }
  }

  /// Helper method to decrypt encrypted fields and parse log
  MoodLog _decryptAndParseLog(Map<String, dynamic> data) {
    // Decrypt encrypted fields
    String? decryptedTitle;
    String? decryptedContent;

    if (data['encryptedTitle'] != null) {
      try {
        decryptedTitle = EncryptionService.decryptData(data['encryptedTitle']);
      } catch (e) {
        decryptedTitle = data['encryptedTitle'] as String?;
      }
    }

    if (data['encryptedContent'] != null) {
      try {
        decryptedContent = EncryptionService.decryptData(
          data['encryptedContent'],
        );
      } catch (e) {
        decryptedContent = data['encryptedContent'] as String?;
      }
    }

    // Create decrypted data map
    final decryptedData = Map<String, dynamic>.from(data);
    decryptedData['encryptedTitle'] = decryptedTitle;
    decryptedData['encryptedContent'] = decryptedContent;

    return MoodLog.fromFirestore(decryptedData);
  }

  /// Save mood log to Firestore with offline-first pattern
  Future<void> saveMoodLog(MoodLog log) async {
    try {
      // Get current user's uid
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      // Prepare data with uid and encrypt sensitive fields
      final data = log.toFirestore();
      data['uid'] = uid;

      // Encrypt title and content before saving
      if (data['encryptedTitle'] != null) {
        data['encryptedTitle'] = EncryptionService.encryptData(
          data['encryptedTitle'],
        );
      }
      if (data['encryptedContent'] != null) {
        data['encryptedContent'] = EncryptionService.encryptData(
          data['encryptedContent'],
        );
      }

      // Save to local Hive database immediately with isSynced = false
      final localJournal = LocalJournal(
        id: log.id,
        uid: uid,
        encryptedTitle: data['encryptedTitle'],
        encryptedContent: data['encryptedContent'],
        timestamp: log.timestamp.millisecondsSinceEpoch,
        sentiment: log.sentiment,
        detectedEmotion: log.detectedEmotion,
        summary: log.summary,
        sleepHours: log.sleepHours ?? 7,
        isSynced: false,
        isDeletedPending: false,
      );
      await _offlineStorage.saveJournalEntry(localJournal);

      // Update local cache with decrypted data for UI
      _localCache.insert(0, log);

      // Fire-and-forget sync to Firestore if internet is available
      _syncToFirestore(log.id, data);
    } catch (e) {
      throw Exception('Failed to save mood log: $e');
    }
  }

  /// Sync journal entry to Firestore (fire-and-forget)
  Future<void> _syncToFirestore(String id, Map<String, dynamic> data) async {
    final hasInternet = await _connectionChecker.hasConnection;
    if (!hasInternet) {
      return; // Skip sync if no internet
    }

    try {
      await _firestore
          .collection(_firestoreCollection)
          .doc(id)
          .set(data, SetOptions(merge: true));

      // Update sync status in local database
      await _offlineStorage.updateSyncStatus(id, true);
    } catch (e) {
      // Sync failed, but local data is safe
      // Will be retried on next sync opportunity
    }
  }

  /// Get all mood logs from local cache
  List<MoodLog> getLocalMoodLogs() {
    return _localCache;
  }

  /// Stream of mood logs from Firestore for real-time updates
  Stream<List<MoodLog>> getMoodLogsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return _firestore
        .collection(_firestoreCollection)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final logs = snapshot.docs
              .map((doc) => _decryptAndParseLog(doc.data()))
              .toList();
          _localCache = logs;
          return logs;
        });
  }

  /// Get mood logs within a date range for analytics
  List<MoodLog> getMoodLogsByDateRange(DateTime start, DateTime end) {
    return _localCache
        .where(
          (log) => log.timestamp.isAfter(start) && log.timestamp.isBefore(end),
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Delete a mood log from Firestore and local Hive storage
  Future<void> deleteMoodLog(String id) async {
    try {
      // Check internet connectivity
      final isConnected = await _connectionChecker.hasConnection;

      if (isConnected) {
        // Online: Delete from Firestore immediately
        await _firestore.collection(_firestoreCollection).doc(id).delete();

        // Delete from local Hive storage
        await _offlineStorage.deleteJournalEntry(id);
      } else {
        // Offline: Mark as pending deletion in Hive storage
        await _offlineStorage.markAsDeletedPending(id);
      }

      // Remove from local cache (immediate UI update)
      _localCache.removeWhere((log) => log.id == id);
    } catch (e) {
      throw Exception('Failed to delete mood log: $e');
    }
  }

  /// Clear all local data (use with caution)
  Future<void> clearLocalData() async {
    _localCache = [];
  }

  /// Get the latest journal entry with AI analysis fields from local Hive
  Future<Map<String, dynamic>?> getLatestJournalEntry() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return null;
      }

      final localJournals = await _offlineStorage.getJournalsByUid(uid);

      if (localJournals.isEmpty) {
        return null;
      }

      final latestJournal = localJournals.first;

      // Decrypt encrypted fields
      String decryptedTitle;
      String decryptedContent;

      try {
        decryptedTitle = EncryptionService.decryptData(
          latestJournal.encryptedTitle,
        );
      } catch (e) {
        decryptedTitle = latestJournal.encryptedTitle;
      }

      try {
        decryptedContent = EncryptionService.decryptData(
          latestJournal.encryptedContent,
        );
      } catch (e) {
        decryptedContent = latestJournal.encryptedContent;
      }

      // Extract fields with fallbacks for null values
      return {
        'id': latestJournal.id,
        'encryptedTitle': decryptedTitle,
        'encryptedContent': decryptedContent,
        'timestamp': DateTime.fromMillisecondsSinceEpoch(
          latestJournal.timestamp,
        ),
        'sentiment': latestJournal.sentiment,
        'detectedEmotion': latestJournal.detectedEmotion,
        'summary': latestJournal.summary,
        'sleepHours': latestJournal.sleepHours,
      };
    } catch (e) {
      return null;
    }
  }
}
