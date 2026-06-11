import 'package:hive/hive.dart';

part 'local_journal_model.g.dart';

@HiveType(typeId: 0)
class LocalJournal {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String encryptedTitle;

  @HiveField(3)
  final String encryptedContent;

  @HiveField(4)
  final int timestamp;

  @HiveField(5)
  final String? sentiment;

  @HiveField(6)
  final String? detectedEmotion;

  @HiveField(7)
  final String? summary;

  @HiveField(8)
  final int? sleepHours;

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  bool? isDeletedPending;

  LocalJournal({
    required this.id,
    required this.uid,
    required this.encryptedTitle,
    required this.encryptedContent,
    required this.timestamp,
    this.sentiment,
    this.detectedEmotion,
    this.summary,
    this.sleepHours,
    required this.isSynced,
    this.isDeletedPending,
  });
}
