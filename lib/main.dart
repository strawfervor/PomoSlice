import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/main_screen.dart';
import 'package:pomoslice/hive/hive_registrar.g.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'dart:async';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox<Task>('tasksBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PomoSlice',
      home: MainScreen(),
    );
  }
}
