import 'package:hive/hive.dart';
import '../model/notice_blog_model.dart';


class LocalNoticeService {
  final Box noticeBox = Hive.box("noticeBox");

  List<NoticeModel> loadLocalNotices() {
    return noticeBox.values.cast<NoticeModel>().toList();
  }

  void saveNotices(List<NoticeModel> notices) {
    noticeBox.clear();
    for (var n in notices) {
      noticeBox.add(n);
    }
  }
}
