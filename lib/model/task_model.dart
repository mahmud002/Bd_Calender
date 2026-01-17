import 'package:hive/hive.dart';
import '../enums/repeat_type.dart';
import '../enums/reminder_offset.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? note;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  DateTime time;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  RepeatType repeatType;

  @HiveField(6)
  ReminderOffset reminderOffset;

  TaskModel({
    required this.title,
    this.note,
    required this.date,
    required this.time,
    this.isCompleted = false,
    this.repeatType = RepeatType.Onece,
    this.reminderOffset = ReminderOffset.atTime,
  });
}
