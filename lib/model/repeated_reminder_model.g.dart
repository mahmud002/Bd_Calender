// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repeated_reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepeatedReminderModelAdapter extends TypeAdapter<RepeatedReminderModel> {
  @override
  final int typeId = 4;

  @override
  RepeatedReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepeatedReminderModel(
      title: fields[0] as String,
      note: fields[1] as String?,
      startDate: fields[2] as DateTime,
      time: fields[3] as DateTime,
      repeatType: fields[4] as RepeatType,
      reminderOffset: fields[5] as ReminderOffset,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RepeatedReminderModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.repeatType)
      ..writeByte(5)
      ..write(obj.reminderOffset)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatedReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
