import 'package:hive/hive.dart';
import '../model/holiday_model.dart';

class LocalHolidayService {
  Box<HolidayModel> get box => Hive.box<HolidayModel>('holidayBox');

  List<HolidayModel> loadLocalHolidays() {
    return box.values.toList();
  }

  void saveHolidays(List<HolidayModel> holidays) {
    for (var holiday in holidays) {
      box.put(holiday.date.toIso8601String(), holiday);
    }
  }
}
