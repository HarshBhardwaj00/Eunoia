import 'package:hive/hive.dart';

part 'local_cbt_model.g.dart';

@HiveType(typeId: 1)
class LocalCbtRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String encryptedSituation;

  @HiveField(3)
  final String encryptedNegativeThought;

  @HiveField(4)
  final String cognitiveDistortionType;

  @HiveField(5)
  final String encryptedRationalChallenge;

  @HiveField(6)
  final String encryptedAlternativeThought;

  @HiveField(7)
  final int timestamp;

  @HiveField(8)
  bool isSynced;

  LocalCbtRecord({
    required this.id,
    required this.uid,
    required this.encryptedSituation,
    required this.encryptedNegativeThought,
    required this.cognitiveDistortionType,
    required this.encryptedRationalChallenge,
    required this.encryptedAlternativeThought,
    required this.timestamp,
    this.isSynced = false,
  });
}
