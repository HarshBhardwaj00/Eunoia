// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_journal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalJournalAdapter extends TypeAdapter<LocalJournal> {
  @override
  final int typeId = 0;

  @override
  LocalJournal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalJournal(
      id: fields[0] as String,
      uid: fields[1] as String,
      encryptedTitle: fields[2] as String,
      encryptedContent: fields[3] as String,
      timestamp: fields[4] as int,
      sentiment: fields[5] as String?,
      detectedEmotion: fields[6] as String?,
      summary: fields[7] as String?,
      sleepHours: fields[8] as int?,
      isSynced: fields[9] as bool,
      isDeletedPending: fields[10] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalJournal obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.encryptedTitle)
      ..writeByte(3)
      ..write(obj.encryptedContent)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.sentiment)
      ..writeByte(6)
      ..write(obj.detectedEmotion)
      ..writeByte(7)
      ..write(obj.summary)
      ..writeByte(8)
      ..write(obj.sleepHours)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.isDeletedPending);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalJournalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
