import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/repeated_reminder_model.dart';
import 'model/task_model.dart';
import 'model/holiday_model.dart';
import 'enums/reminder_offset.dart';
import 'enums/repeat_type.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hive Init
  await Hive.initFlutter();
  Hive.registerAdapter(HolidayModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(RepeatedReminderModelAdapter());
  Hive.registerAdapter(RepeatTypeAdapter());
  Hive.registerAdapter(ReminderOffsetAdapter());

  await Hive.openBox<HolidayModel>('holidayBox');
  await Hive.openBox("noticeBox");
  await Hive.openBox<TaskModel>('taskBox');
  await Hive.openBox<RepeatedReminderModel>('repeatedReminderBox');
  await Hive.openBox('settings');

  // Load saved theme
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode') ?? 'light';

  runApp(MyApp(initialTheme: savedTheme));
}

class MyApp extends StatefulWidget {
  final String initialTheme;

  const MyApp({super.key, required this.initialTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        prefs.setString('themeMode', 'dark');
      } else {
        _themeMode = ThemeMode.light;
        prefs.setString('themeMode', 'light');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BD Holiday Calendar',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.greenAccent,
        ),
      ),
      themeMode: _themeMode,
      home: CalendarScreen(toggleTheme: toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}
