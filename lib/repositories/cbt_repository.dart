import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../data/models/local_cbt_model.dart';
import '../services/encryption_service.dart';
import '../services/cbt_offline_storage_service.dart';

class CbtRepository {
  static const String _firestoreCollection = 'cbt_thought_records';
  final FirebaseFirestore _firestore;
  final CbtOfflineStorageService _offlineStorage;
  final InternetConnectionChecker _connectionChecker;

  CbtRepository(this._firestore, this._offlineStorage, this._connectionChecker);

  /// Save CBT record with encryption and sync logic
  Future<void> saveCbtRecord({
    required String situation,
    required String negativeThought,
    required String cognitiveDistortionType,
    required String rationalChallenge,
    required String alternativeThought,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique ID
      final id = _firestore.collection(_firestoreCollection).doc().id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Encrypt sensitive fields
      final encryptedSituation = EncryptionService.encryptData(situation);
      final encryptedNegativeThought = EncryptionService.encryptData(
        negativeThought,
      );
      final encryptedRationalChallenge = EncryptionService.encryptData(
        rationalChallenge,
      );
      final encryptedAlternativeThought = EncryptionService.encryptData(
        alternativeThought,
      );

      // Create local record
      final localRecord = LocalCbtRecord(
        id: id,
        uid: uid,
        encryptedSituation: encryptedSituation,
        encryptedNegativeThought: encryptedNegativeThought,
        cognitiveDistortionType: cognitiveDistortionType,
        encryptedRationalChallenge: encryptedRationalChallenge,
        encryptedAlternativeThought: encryptedAlternativeThought,
        timestamp: timestamp,
        isSynced: false,
      );

      // Save to local Hive storage immediately
      await _offlineStorage.saveCbtRecord(localRecord);

      // Check internet connectivity
      final isConnected = await _connectionChecker.hasConnection;

      if (isConnected) {
        // Online: Sync to Firestore immediately
        await _syncToFirestore(localRecord);
      }
      // If offline, record stays with isSynced = false for later sync
    } catch (e) {
      throw Exception('Failed to save CBT record: $e');
    }
  }

  /// Sync single record to Firestore
  Future<void> _syncToFirestore(LocalCbtRecord record) async {
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
          .collection(_firestoreCollection)
          .doc(record.id)
          .set(data, SetOptions(merge: true));

      // Update sync status in local storage
      await _offlineStorage.updateSyncStatus(record.id, true);
    } catch (e) {
      // Sync failed, will retry via SyncManager
      throw Exception('Failed to sync to Firestore: $e');
    }
  }

  /// Get all CBT records for current user
  Future<List<LocalCbtRecord>> getCbtRecords() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return [];
      }

      return await _offlineStorage.getCbtRecordsByUid(uid);
    } catch (e) {
      throw Exception('Failed to get CBT records: $e');
    }
  }

  /// Delete CBT record
  Future<void> deleteCbtRecord(String id) async {
    try {
      // Delete from Firestore
      await _firestore.collection(_firestoreCollection).doc(id).delete();

      // Delete from local storage
      await _offlineStorage.deleteCbtRecord(id);
    } catch (e) {
      throw Exception('Failed to delete CBT record: $e');
    }
  }
}
