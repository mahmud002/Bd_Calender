// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HolidayModelAdapter extends TypeAdapter<HolidayModel> {
  @override
  final int typeId = 0;

  @override
  HolidayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HolidayModel(
      titleEn: fields[0] as String,
      titleBn: fields[1] as String,
      date: fields[2] as DateTime,
      isGovt: fields[3] as bool,
      month: fields[4] as int,
      year: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HolidayModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.titleEn)
      ..writeByte(1)
      ..write(obj.titleBn)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isGovt)
      ..writeByte(4)
      ..write(obj.month)
      ..writeByte(5)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
