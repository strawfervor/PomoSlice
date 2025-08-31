import 'package:flutter/material.dart';

class LogScreen extends StatefulWidget{
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(context) {
    return Text("Log Screen");
  }
}