import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/holiday_model.dart';
import 'local_holiday_service.dart';

class FirestoreHolidayService {
  final localService = LocalHolidayService();

  Future<List<HolidayModel>> getHolidays() async {
    final snapshot = await FirebaseFirestore.instance.collection('holidays').get();

    List<HolidayModel> holidays = snapshot.docs.map((doc) {
      final data = doc.data();
      return HolidayModel(
        titleEn: data['title_en'] ?? "",
        titleBn: data['title_bn'] ?? "",
        date: (data['date'] as Timestamp).toDate(),
        isGovt: data['is_govt'] ?? false,
        month: data['month'] ?? 0,
        year: data['year'] ?? 0,
      );
    }).toList();

    localService.saveHolidays(holidays);
    return holidays;
  }

  Future<List<HolidayModel>> getNotices() async {
    final snapshot = await FirebaseFirestore.instance.collection('notice_blog').get();

    List<HolidayModel> holidays = snapshot.docs.map((doc) {
      final data = doc.data();
      return HolidayModel(
        titleEn: data['title_en'] ?? "",
        titleBn: data['title_bn'] ?? "",
        date: (data['date'] as Timestamp).toDate(),
        isGovt: data['is_govt'] ?? false,
        month: data['month'] ?? 0,
        year: data['year'] ?? 0,
      );
    }).toList();

    localService.saveHolidays(holidays);
    return holidays;
  }
}
