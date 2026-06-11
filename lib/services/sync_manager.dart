import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'offline_storage_service.dart';
import 'cbt_offline_storage_service.dart';
import '../data/models/local_journal_model.dart';
import '../data/models/local_cbt_model.dart';

class SyncManager {
  static SyncManager? _instance;
  StreamSubscription<InternetConnectionStatus>? _connectionSubscription;
  final OfflineStorageService _offlineStorage = OfflineStorageService.instance;
  final CbtOfflineStorageService _cbtOfflineStorage =
      CbtOfflineStorageService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _journalCollection = 'user_journals';
  static const String _cbtCollection = 'cbt_thought_records';
  bool _isSyncing = false;

  SyncManager._internal();

  static SyncManager get instance {
    _instance ??= SyncManager._internal();
    return _instance!;
  }

  /// Initialize sync manager and start listening to internet connection changes
  void initialize() {
    _connectionSubscription?.cancel();
    _connectionSubscription = InternetConnectionChecker.createInstance()
        .onStatusChange
        .listen((status) {
          if (status == InternetConnectionStatus.connected) {
            _syncUnsyncedRecords();
          }
        });
  }

  /// Sync all unsynced records to Firestore
  Future<void> _syncUnsyncedRecords() async {
    if (_isSyncing) {
      return; // Prevent concurrent sync operations
    }

    _isSyncing = true;

    try {
      // First, process pending deletions
      await _processPendingDeletions();

      // Then, sync unsynced journal records
      await _syncJournalRecords();

      // Finally, sync unsynced CBT records
      await _syncCbtRecords();
    } catch (e) {
      // Sync failed, will retry on next connection change
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync unsynced journal records
  Future<void> _syncJournalRecords() async {
    try {
      final unsyncedRecords = await _offlineStorage.getUnsyncedJournals();

      if (unsyncedRecords.isEmpty) {
        return;
      }

      for (final record in unsyncedRecords) {
        await _syncSingleRecord(record);
      }
    } catch (e) {
      // Journal sync failed, will retry
    }
  }

  /// Sync unsynced CBT records
  Future<void> _syncCbtRecords() async {
    try {
      final unsyncedRecords = await _cbtOfflineStorage.getUnsyncedCbtRecords();

      if (unsyncedRecords.isEmpty) {
        return;
      }

      for (final record in unsyncedRecords) {
        await _syncSingleCbtRecord(record);
      }
    } catch (e) {
      // CBT sync failed, will retry
    }
  }

  /// Process pending deletions (records marked for deletion while offline)
  Future<void> _processPendingDeletions() async {
    try {
      final pendingDeletions = await _offlineStorage.getPendingDeletions();

      for (final record in pendingDeletions) {
        try {
          // Delete from Firestore
          await _firestore
              .collection(_journalCollection)
              .doc(record.id)
              .delete();

          // Delete from local Hive storage
          await _offlineStorage.deleteJournalEntry(record.id);
        } catch (e) {
          // Individual deletion failed, continue with others
        }
      }
    } catch (e) {
      // Failed to get pending deletions, continue with sync
    }
  }

  /// Sync a single record to Firestore
  Future<void> _syncSingleRecord(LocalJournal record) async {
    try {
      final data = {
        'id': record.id,
        'uid': record.uid,
        'encryptedTitle': record.encryptedTitle,
        'encryptedContent': record.encryptedContent,
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(record.timestamp),
        'sentiment': record.sentiment,
        'detectedEmotion': record.detectedEmotion,
        'summary': record.summary,
        'sleepHours': record.sleepHours,
      };

      await _firestore
          .collection(_journalCollection)
          .doc(record.id)
          .set(data, SetOptions(merge: true));

      // Update sync status in local database
      await _offlineStorage.updateSyncStatus(record.id, true);
    } catch (e) {
      // Individual record sync failed, continue with others
    }
  }

  /// Sync a single CBT record to Firestore
  Future<void> _syncSingleCbtRecord(LocalCbtRecord record) async {
    try {
      final data = {
        'id': record.id,
        'uid': record.uid,
        'encryptedSituation': record.encryptedSituation,
        'encryptedNegativeThought': record.encryptedNegativeThought,
        'cognitiveDistortionType': record.cognitiveDistortionType,
        'encryptedRationalChallenge': record.encryptedRationalChallenge,
        'encryptedAlternativeThought': record.encryptedAlternativeThought,
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(record.timestamp),
      };

      await _firestore
          .collection(_cbtCollection)
          .doc(record.id)
          .set(data, SetOptions(merge: true));

      // Update sync status in local database
      await _cbtOfflineStorage.updateSyncStatus(record.id, true);
    } catch (e) {
      // Individual record sync failed, continue with others
    }
  }

  /// Manually trigger sync (for testing or manual refresh)
  Future<void> triggerSync() async {
    await _syncUnsyncedRecords();
  }

  /// Stop listening to connection changes
  void dispose() {
    _connectionSubscription?.cancel();
  }
}
