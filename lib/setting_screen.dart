import 'package:flutter/material.dart';
import 'package:pomoslice/data/state_changer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key, required this.stateChanger});

  final StateChanger stateChanger;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late StateChanger myStateChanger;
  int _pomodorTime = 25;
  int _breakTime = 5;
  int _longBreakTime = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    myStateChanger = widget.stateChanger;
  }

  Future<void> _loadSettings() async{
    final prefs = await SharedPreferences.getInstance();
    _pomodorTime = prefs.getInt('pomodoroTime') ?? 25;
    _breakTime = prefs.getInt('breakTime') ?? 25;
    _longBreakTime = prefs.getInt('longBreakTime') ?? 25;
  }

  void _updateStateChanger() {
    myStateChanger.breakTime = _breakTime;
    myStateChanger.longBreakTime = _longBreakTime;
    myStateChanger.pomodorTime = _pomodorTime;
  }

  Future<void> _saveSettings() async{
    final prefs = await SharedPreferences.getInstance();
    _updateStateChanger();
    prefs.setInt('pomodoroTime', _pomodorTime);
    prefs.setInt('breakTime', _breakTime);
    prefs.setInt('longBreakTime', _longBreakTime);
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        Text("Settings"),
      ]
    );
  }
}
