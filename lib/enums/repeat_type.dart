import 'package:hive/hive.dart';

part 'repeat_type.g.dart';

@HiveType(typeId: 6)
enum RepeatType {
  @HiveField(0)
  Onece,

  @HiveField(1)
  Daily,

  @HiveField(2)
  Weekly,

  @HiveField(3)
  Monthly,

  @HiveField(4)
  Yearly,
}
