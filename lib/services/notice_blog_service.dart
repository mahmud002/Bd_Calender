import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/notice_blog_model.dart';
import 'local_notice_service.dart';

class NoticeService {
  final LocalNoticeService local = LocalNoticeService();

  Future<List<NoticeModel>> getNotices() async {
    final snapshot =
    await FirebaseFirestore.instance.collection("notice_blog").get();

    List<NoticeModel> notices = snapshot.docs.map((doc) {
      final data = doc.data();

      return NoticeModel(
        title: data["title"] ?? "",
        message: data["message"] ?? "",
        lastUpdate: (data["last_update"] as Timestamp).toDate(),
        url: data["url"] ?? "",
      );
    }).toList();

    // Save to Hive
    local.saveNotices(notices);

    return notices;
  }
}
