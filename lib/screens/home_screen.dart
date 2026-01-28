import 'package:hive/hive.dart';

import '../model/task_model.dart';
import 'repeated_reminder_list_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'task_page.dart';

import 'holiday_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/holiday_model.dart';
import '../model/notice_blog_model.dart';

import '../services/local_holiday_service.dart';
import '../services/holiday_service.dart';

import '../services/local_notice_service.dart';
import '../services/notice_blog_service.dart';

import 'package:url_launcher/url_launcher.dart';
import 'dart:async';


class CalendarScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const CalendarScreen({super.key, required this.toggleTheme});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  List<HolidayModel> holidays = [];
  List<NoticeModel> notices = [];

  final localService = LocalHolidayService();
  final firestoreService = FirestoreHolidayService();

  final noticeLocal = LocalNoticeService();
  final noticeRemote = NoticeService();
  Timer? _minuteTimer;

  bool isLoadingHolidays = true;
  bool isLoadingNotices = true;

  final double _calendarHeight = 400; // Approx height of your calendar grid
  final double _monthRowHeight = 60; // Height of month + weekday rows
  late Box<TaskModel> taskBox;


  @override
  void initState() {
    super.initState();
    loadHolidays();
    loadNotices();
    // Open Hive box for tasks
    taskBox = Hive.box<TaskModel>(
      'taskBox',
    ); // Make sure you already opened this box in main()

    // Start auto-refresh every minute
    _minuteTimer = Timer.periodic(
      const Duration(minutes: 1),
          (timer) {
        if (mounted) {
          setState(() {}); // rebuild only the widgets that depend on time
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minuteTimer?.cancel();
    super.dispose();
  }
  Map<String, dynamic> getTodayTaskStatsFromList(List<TaskModel> tasks) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int completed = tasks
        .where((t) => t.isCompleted && isSameDay(t.date, today))
        .length;

    int missed = tasks.where((t) {
      if (t.isCompleted) return false;

      final taskDateTime = DateTime(
        t.date.year,
        t.date.month,
        t.date.day,
        t.time.hour,
        t.time.minute,
      );

      return taskDateTime.isBefore(now);
    }).length;

    int remaining = tasks.where((t) {
      return !t.isCompleted && isSameDay(t.date, today);
    }).length;

    // ✅ UPCOMING = Today + Not Completed + Time Not Passed
    List<TaskModel> upcoming = tasks.where((t) {
      if (t.isCompleted) return false;

      // Must be today
      if (!isSameDay(t.date, today)) return false;

      final taskDateTime = DateTime(
        t.date.year,
        t.date.month,
        t.date.day,
        t.time.hour,
        t.time.minute,
      );

      // Must be in future
      return taskDateTime.isAfter(now);
    }).toList();

    // Sort by time (nearest first)
    upcoming.sort((a, b) => a.time.compareTo(b.time));

    return {
      "completed": completed,
      "remaining": remaining,
      "missed": missed,
      "upcoming": upcoming,
    };
  }
  List<TaskModel> getTodayUpcomingTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return tasks.where((t) {
      if (t.isCompleted) return false;

      // Normalize task date
      final taskDay = DateTime(
        t.date.year,
        t.date.month,
        t.date.day,
      );

      if (!isSameDay(taskDay, today)) return false;

      // Combine date + time correctly
      final taskDateTime = DateTime(
        taskDay.year,
        taskDay.month,
        taskDay.day,
        t.time.hour,
        t.time.minute,
      );

      // Allow now or future
      return !taskDateTime.isBefore(now);

    }).toList()
      ..sort((a, b) {
        final aTime = DateTime(
          a.date.year,
          a.date.month,
          a.date.day,
          a.time.hour,
          a.time.minute,
        );

        final bTime = DateTime(
          b.date.year,
          b.date.month,
          b.date.day,
          b.time.hour,
          b.time.minute,
        );

        return aTime.compareTo(bTime);
      });
  }

  String formatTaskTime(TaskModel task) {
    // Combine task date + time to make sure it's correct
    final taskDateTime = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      task.time.hour,
      task.time.minute,
    );

    // Format as 12-hour with leading zeros
    return DateFormat('hh:mm a').format(taskDateTime); // e.g., 12:05 AM
  }


  String getTimeLeft(TaskModel task) {
    final now = DateTime.now();

    final dueDateTime = DateTime(
      task.date.year,
      task.date.month,
      task.date.day,
      task.time.hour,
      task.time.minute,
    );

    final diff = dueDateTime.difference(now);

    if (diff.isNegative) return "Missed";

    if (diff.inMinutes < 1) return "Now";

    if (diff.inHours < 1) {
      return "${diff.inMinutes}m left";
    }

    return "${diff.inHours}h ${diff.inMinutes % 60}m left";
  }

  String _formatTaskDateTime(
      DateTime time,
      BuildContext context,
      ) {
    // Combine date + time
    final combined = DateTime(
      time.hour,
      time.minute,
    );


    // Format time
    final formattedTime = TimeOfDay.fromDateTime(combined).format(context);

    return '$formattedTime';
  }
  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void showCustomAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Icon
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 15),

                // App Name
                const Text(
                  "BD Holiday Calendar",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                // Version
                const SizedBox(height: 5),
                Text(
                  "Version 1.0",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 15),

                // Description
                const Text(
                  "Developed by MKJ Soft Lab",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),

                const SizedBox(height: 20),

                // Close Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------ HOLIDAYS LOADER --------------------
  Future<void> loadHolidays() async {
    // 1) Load local & show immediately (no flicker)
    final local = localService.loadLocalHolidays();
    holidays = local;
    setState(() {}); // update UI instantly

    // 2) Load from Firestore
    final synced = await firestoreService.getHolidays();

    // 4) Update UI
    holidays = synced;
    isLoadingHolidays = false;
    setState(() {});
  }

  // ------------------ NOTICES LOADER --------------------
  Future<void> loadNotices() async {
    // 1) Local load instant
    final local = noticeLocal.loadLocalNotices();
    notices = local;
    setState(() {});

    // 2) Load Firestore
    final synced = await noticeRemote.getNotices();

    // 3) Save to Hive
    // await noticeLocal.saveLocalNotices(synced);

    // 4) Update UI
    notices = synced;
    isLoadingNotices = false;
    setState(() {});
  }

  // ------------------ DATE HELPERS ----------------------
  void _previousMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
    });
  }

  bool isHoliday(DateTime date) {
    return holidays.any(
      (h) =>
          h.date.day == date.day &&
          h.date.month == date.month &&
          h.date.year == date.year,
    );
  }

  Future<void> showYearMonthPicker(
    BuildContext context,
    Function(int year, int month) onSelected,
  ) async {
    // STEP 1 → PICK YEAR
    final int? selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
              selectedDate: DateTime.now(),
              onChanged: (date) {
                Navigator.pop(context, date.year);
              },
            ),
          ),
        );
      },
    );

    if (selectedYear == null) return; // user cancelled

    // STEP 2 → PICK MONTH
    final int? selectedMonth = await showDialog<int>(
      context: context,
      builder: (context) {
        final months = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December",
        ];

        return AlertDialog(
          title: Text("Select Month ($selectedYear)"),
          content: SizedBox(
            width: 300,
            height: 330,
            child: GridView.builder(
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.0,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.pop(context, index + 1),
                  child: Card(
                    elevation: 1,
                    child: Center(
                      child: Text(
                        months[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedMonth == null) return; // user cancelled

    // 🔥 Final selected year & month
    onSelected(selectedYear, selectedMonth);
  }

  HolidayModel? getHoliday(DateTime date) {
    return holidays.firstWhere(
      (h) =>
          h.date.day == date.day &&
          h.date.month == date.month &&
          h.date.year == date.year,
      orElse: () => HolidayModel(
        titleEn: '',
        titleBn: '',
        date: DateTime(0),
        isGovt: false,
        month: 0,
        year: 0,
      ),
    );
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null) return;

    if (velocity.abs() < 300) return; // prevents accidental swipe

    if (velocity < 0) {
      _nextMonth();
    } else {
      _previousMonth();
    }
  }

  // ------------------ BUILD UI ----------------------
  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final daysInMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'BD Calendar',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pop(context); // close drawer

                // Scroll to notifications or navigate to another screen

                // Scroll to notifications
                _scrollController.animateTo(
                  _monthRowHeight -
                      _calendarHeight *
                          2, // adjust this according to your layout
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Task Manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Repeated Reminded'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RepeatedReminderListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('All Holidays'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HolidayListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Scroll to notifications or navigate to another screen

                // Scroll to notifications
                _scrollController.animateTo(
                  _monthRowHeight +
                      _calendarHeight, // adjust this according to your layout
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Toggle Dark/Light'),
              onTap: () {
                //Navigator.pop(context);
                widget.toggleTheme();
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: const Text('Setting'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => HolidayListPage()),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showCustomAboutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: _onHorizontalSwipe,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ------------------ Banner ------------------
            SliverAppBar(
              pinned: true,
              expandedHeight: 180,
              iconTheme: const IconThemeData(
                color: Colors.green, // <-- Drawer menu icon color
              ),
              actionsIconTheme: const IconThemeData(
                color: Colors.green, // <-- Actions icons color
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.brightness_6),
                  onPressed: widget.toggleTheme,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  'assets/images/calendar_banner.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // ------------------ Month navigation --------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: _previousMonth,
                    ),
                    GestureDetector(
                      onTap: () {
                        showYearMonthPicker(context, (year, month) {
                          setState(() {
                            selectedDate = DateTime(year, month, 1);
                          });
                        });
                      },
                      child: Text(
                        DateFormat.yMMMM().format(selectedDate),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
            ),

            // ------------------ Weekdays ---------------------
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map(
                      (e) => Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            e,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            // ------------------ Calendar Loading --------------
            if (isLoadingHolidays)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              // ------------------ Calendar Grid -----------------
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < firstDayOfMonth.weekday % 7)
                      return const SizedBox();

                    final day = index - (firstDayOfMonth.weekday % 7) + 1;
                    final date = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      day,
                    );

                    final holiday = isHoliday(date);

                    final today =
                        date.day == DateTime.now().day &&
                        date.month == DateTime.now().month &&
                        date.year == DateTime.now().year;

                    Color cellColor = holiday
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Color(0xFF8B0000)
                              : Color(0xFFDE3163))
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade500
                              : Colors.grey.shade200);

                    return GestureDetector(
                      onTap: holiday
                          ? () {
                              final h = getHoliday(date);
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Holiday"),
                                  content: Text(h!.titleEn),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: cellColor,
                          border: today
                              ? Border.all(color: Colors.green, width: 5)
                              : null,
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: holiday ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }, childCount: daysInMonth + firstDayOfMonth.weekday % 7),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                ),
              ),
            // ------------------ Today's Tasks (Auto Refresh) -----------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<TaskModel>('taskBox').listenable(),
                  builder: (context, Box<TaskModel> box, _) {

                    final tasks = box.values.toList().cast<TaskModel>();

                    // ✅ ADD THIS
                    final todayUpcoming = getTodayUpcomingTasks(tasks);

                    final stats = getTodayTaskStatsFromList(tasks);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("Today's Tasks"),

                            Text("✅ Completed: ${stats['completed']}"),
                            Text("⏳ Remaining: ${stats['remaining']}"),


                            // ✅ USE IT HERE

                            if (todayUpcoming.isNotEmpty) ...[
                              const SizedBox(height: 12),

                              const Text("⚠️ Due Today"),

                              ...todayUpcoming.map((task) {
                                return Text(
                                    "👉 ${task.title} at ${formatTaskTime(task)} (${getTimeLeft(task)})"
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

              ),
            ),

            // ------------------ Notifications -----------------
            if (isLoadingNotices)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final n = notices[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Colors.green,
                      ),
                      title: Text(
                        n.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${n.message}\nUpdated: ${DateFormat.yMMMd().format(n.lastUpdate)}",
                      ),
                      onTap: () async {
                        Uri url = Uri.parse(n.url);
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                  );
                }, childCount: notices.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
