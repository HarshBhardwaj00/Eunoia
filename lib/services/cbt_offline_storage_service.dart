import 'package:hive/hive.dart';
import '../data/models/local_cbt_model.dart';

class CbtOfflineStorageService {
  static const String _boxName = 'cbt_records';
  static CbtOfflineStorageService? _instance;
  Box<LocalCbtRecord>? _cbtBox;

  CbtOfflineStorageService._internal();

  static CbtOfflineStorageService get instance {
    _instance ??= CbtOfflineStorageService._internal();
    return _instance!;
  }

  Future<Box<LocalCbtRecord>> get cbtBox async {
    if (_cbtBox != null && _cbtBox!.isOpen) {
      return _cbtBox!;
    }

    _cbtBox = await Hive.openBox<LocalCbtRecord>(_boxName);
    return _cbtBox!;
  }

  /// Save CBT record to local Hive storage
  Future<void> saveCbtRecord(LocalCbtRecord record) async {
    final box = await cbtBox;
    await box.put(record.id, record);
  }

  /// Get CBT records by user ID
  Future<List<LocalCbtRecord>> getCbtRecordsByUid(String uid) async {
    final box = await cbtBox;
    return box.values.where((record) => record.uid == uid).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, bool isSynced) async {
    final box = await cbtBox;
    final record = box.get(id);
    if (record != null) {
      record.isSynced = isSynced;
      await box.put(id, record);
    }
  }

  /// Delete CBT record from local storage
  Future<void> deleteCbtRecord(String id) async {
    final box = await cbtBox;
    await box.delete(id);
  }

  /// Get unsynced CBT records
  Future<List<LocalCbtRecord>> getUnsyncedCbtRecords() async {
    final box = await cbtBox;
    return box.values.where((record) => !record.isSynced).toList();
  }

  /// Clear all CBT records (use with caution)
  Future<void> clearAll() async {
    final box = await cbtBox;
    await box.clear();
  }

  /// Close Hive instance
  Future<void> close() async {
    if (_cbtBox != null && _cbtBox!.isOpen) {
      await _cbtBox!.close();
      _cbtBox = null;
    }
  }
}
