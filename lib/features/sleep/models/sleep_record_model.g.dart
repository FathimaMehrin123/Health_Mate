// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SleepRecordModelAdapter extends TypeAdapter<SleepRecordModel> {
  @override
  final int typeId = 2;

  @override
  SleepRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepRecordModel(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      qualityScore: fields[3] as int,
      phaseDurationsMap: (fields[4] as Map).cast<String, int>(),
      movementCount: fields[5] as int,
      soundLevels: (fields[6] as List).cast<double>(),
      totalDuration: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SleepRecordModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.qualityScore)
      ..writeByte(4)
      ..write(obj.phaseDurationsMap)
      ..writeByte(5)
      ..write(obj.movementCount)
      ..writeByte(6)
      ..write(obj.soundLevels)
      ..writeByte(7)
      ..write(obj.totalDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
