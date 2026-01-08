import 'package:hive/hive.dart';

part 'holiday_model.g.dart';

@HiveType(typeId: 0)
class HolidayModel {
  @HiveField(0)
  String titleEn;

  @HiveField(1)
  String titleBn;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isGovt;

  @HiveField(4)
  int month;

  @HiveField(5)
  int year;

  HolidayModel({
    required this.titleEn,
    required this.titleBn,
    required this.date,
    required this.isGovt,
    required this.month,
    required this.year,
  });
}
