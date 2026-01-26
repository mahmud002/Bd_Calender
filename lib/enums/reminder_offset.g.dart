// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_offset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderOffsetAdapter extends TypeAdapter<ReminderOffset> {
  @override
  final int typeId = 7;

  @override
  ReminderOffset read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderOffset.atTime;
      case 1:
        return ReminderOffset.tenMinutesBefore;
      case 2:
        return ReminderOffset.oneHourBefore;
      case 3:
        return ReminderOffset.oneDayBefore;
      default:
        return ReminderOffset.atTime;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderOffset obj) {
    switch (obj) {
      case ReminderOffset.atTime:
        writer.writeByte(0);
        break;
      case ReminderOffset.tenMinutesBefore:
        writer.writeByte(1);
        break;
      case ReminderOffset.oneHourBefore:
        writer.writeByte(2);
        break;
      case ReminderOffset.oneDayBefore:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderOffsetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
