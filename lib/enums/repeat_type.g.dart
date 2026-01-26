// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repeat_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepeatTypeAdapter extends TypeAdapter<RepeatType> {
  @override
  final int typeId = 6;

  @override
  RepeatType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatType.Onece;
      case 1:
        return RepeatType.Daily;
      case 2:
        return RepeatType.Weekly;
      case 3:
        return RepeatType.Monthly;
      case 4:
        return RepeatType.Yearly;
      default:
        return RepeatType.Onece;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatType obj) {
    switch (obj) {
      case RepeatType.Onece:
        writer.writeByte(0);
        break;
      case RepeatType.Daily:
        writer.writeByte(1);
        break;
      case RepeatType.Weekly:
        writer.writeByte(2);
        break;
      case RepeatType.Monthly:
        writer.writeByte(3);
        break;
      case RepeatType.Yearly:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
