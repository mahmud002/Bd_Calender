import 'package:hive/hive.dart';
import '../enums/repeat_type.dart';
import '../enums/reminder_offset.dart';

part 'repeated_reminder_model.g.dart'; // ← MUST match THIS FILE NAME EXACTLY

@HiveType(typeId: 4)
class RepeatedReminderModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? note;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  DateTime time;

  @HiveField(4)
  RepeatType repeatType;

  @HiveField(5)
  ReminderOffset reminderOffset;

  @HiveField(6)
  bool isActive;

  RepeatedReminderModel({
    required this.title,
    this.note,
    required this.startDate,
    required this.time,
    required this.repeatType,
    this.reminderOffset = ReminderOffset.atTime,
    this.isActive = true,
  });
}
