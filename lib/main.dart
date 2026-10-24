import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/main_screen.dart';
import 'package:pomoslice/hive/hive_registrar.g.dart';
import 'package:pomoslice/services/notifications.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //init hive
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox<Task>('tasksBox');

  //init tz
  tz.initializeTimeZones();
  try {
    final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  } catch (error) {
    debugPrint('Could not determine the local timezone: $error');
  }

  await initNotifications();

  //load settings
  final prefs = await SharedPreferences.getInstance();
  final int pomodoroTime = _validMinutes(prefs.getInt('pomodoroTime'), 25);
  final int breakTime = _validMinutes(prefs.getInt('breakTime'), 5);
  final int longBreakTime = _validMinutes(prefs.getInt('longBreakTime'), 15);

  runApp(
    MyApp(
      pomodoroBreak: breakTime,
      pomodoroLongBreak: longBreakTime,
      pomodoroTime: pomodoroTime,
    ),
  );
}

int _validMinutes(int? value, int fallback) {
  if (value == null || value < 1) {
    return fallback;
  }
  return value;
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.pomodoroBreak,
    required this.pomodoroLongBreak,
    required this.pomodoroTime,
  });
  final int pomodoroTime;
  final int pomodoroBreak;
  final int pomodoroLongBreak;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PomoSlice',
      home: MainScreen(
        pomodoroBreak: pomodoroBreak,
        pomodoroLongBreak: pomodoroLongBreak,
        pomodoroTime: pomodoroTime,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 83, 211, 243),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
