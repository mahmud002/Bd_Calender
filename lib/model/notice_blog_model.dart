import 'package:hive/hive.dart';

part 'notice_blog_model.g.dart';   // MUST MATCH FILE NAME EXACTLY

@HiveType(typeId: 2)
class NoticeModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String message;

  @HiveField(2)
  DateTime lastUpdate;

  @HiveField(3)
  String url;

  NoticeModel({
    required this.title,
    required this.message,
    required this.lastUpdate,
    required this.url,
  });
}
