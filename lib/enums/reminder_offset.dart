import 'package:hive/hive.dart';

part 'reminder_offset.g.dart';

@HiveType(typeId: 7)
enum ReminderOffset {
  @HiveField(0)
  atTime,

  @HiveField(1)
  tenMinutesBefore,

  @HiveField(2)
  oneHourBefore,

  @HiveField(3)
  oneDayBefore,
}
