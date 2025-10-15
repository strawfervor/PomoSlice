import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/main_screen.dart';
import 'package:pomoslice/hive/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //init hive
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox<Task>('tasksBox');
  await initNotifications();

  //load settings
  final prefs = await SharedPreferences.getInstance();
  final int pomodorTime = prefs.getInt('pomodoroTime') ?? 25;
  final int breakTime = prefs.getInt('breakTime') ?? 5;
  final int longBreakTime = prefs.getInt('longBreakTime') ?? 15;

  runApp(MyApp(pomodoroBreak: breakTime, pomodoroLongBreak: longBreakTime, pomodoroTime: pomodorTime));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.pomodoroBreak, required this.pomodoroLongBreak, required this.pomodoroTime});
  final int pomodoroTime;
  final int pomodoroBreak;
  final int pomodoroLongBreak;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PomoSlice',
      home: MainScreen(pomodoroBreak: pomodoroBreak, pomodoroLongBreak: pomodoroLongBreak, pomodoroTime: pomodoroTime,),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 83, 211, 243),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

//notifications:

Future<void> initNotifications() async {
  const androidSettings = AndroidInitializationSettings('appicon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationTapBackground,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  await androidPlugin?.requestNotificationsPermission();
}


Future<void> showSimpleNotification(
    {required String title, required String body, required String payload}) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('pomoslice_channel_id', 'PomoSlice Sessions',
          channelDescription: 'Notifications for Pomodoro sessions and breaks',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await notificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
    payload: payload,
  );
}