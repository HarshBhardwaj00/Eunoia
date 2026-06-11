// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_cbt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalCbtRecordAdapter extends TypeAdapter<LocalCbtRecord> {
  @override
  final int typeId = 1;

  @override
  LocalCbtRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalCbtRecord(
      id: fields[0] as String,
      uid: fields[1] as String,
      encryptedSituation: fields[2] as String,
      encryptedNegativeThought: fields[3] as String,
      cognitiveDistortionType: fields[4] as String,
      encryptedRationalChallenge: fields[5] as String,
      encryptedAlternativeThought: fields[6] as String,
      timestamp: fields[7] as int,
      isSynced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalCbtRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.encryptedSituation)
      ..writeByte(3)
      ..write(obj.encryptedNegativeThought)
      ..writeByte(4)
      ..write(obj.cognitiveDistortionType)
      ..writeByte(5)
      ..write(obj.encryptedRationalChallenge)
      ..writeByte(6)
      ..write(obj.encryptedAlternativeThought)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCbtRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
