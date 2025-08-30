import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget{
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int screenNumber = 0;


  @override
  Widget build(context) {
    return Text("Timer Screen");
  }
}