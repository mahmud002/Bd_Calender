// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_blog_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoticeModelAdapter extends TypeAdapter<NoticeModel> {
  @override
  final int typeId = 2;

  @override
  NoticeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoticeModel(
      title: fields[0] as String,
      message: fields[1] as String,
      lastUpdate: fields[2] as DateTime,
      url: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NoticeModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.lastUpdate)
      ..writeByte(3)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoticeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
