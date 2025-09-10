import 'package:flutter/material.dart';
import 'package:pomoslice/main_screen.dart';
import 'dart:async';

Future<void> main() async {

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
