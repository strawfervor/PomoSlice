import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomoslice/components/square_button.dart';
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
  late int _pomodorTime;
  late int _breakTime;
  late int _longBreakTime;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    myStateChanger = widget.stateChanger;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _pomodorTime = prefs.getInt('pomodoroTime') ?? 25;
    _breakTime = prefs.getInt('breakTime') ?? 25;
    _longBreakTime = prefs.getInt('longBreakTime') ?? 25;
  }

  void _updateStateChanger() {
    myStateChanger.breakTime = _breakTime;
    myStateChanger.longBreakTime = _longBreakTime;
    setState(() {
      myStateChanger.pomodorTime = _pomodorTime;
    });
    myStateChanger.setStateTime();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _updateStateChanger();
    debugPrint("current data: p: $_pomodorTime, b: $_breakTime, lb: $_longBreakTime");
    prefs.setInt('pomodoroTime', _pomodorTime);
    prefs.setInt('breakTime', _breakTime);
    prefs.setInt('longBreakTime', _longBreakTime);
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        SizedBox(height: 50,),
        Text("Settings", style: TextStyle(fontSize: 40)),
        SizedBox(height: 50,),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow((RegExp(r'[0-9]'))),
          ],
          decoration: InputDecoration(label: Text("Pomodoro time (minutes):")),
          onChanged: (value) => _pomodorTime = int.parse(value),
        ),
        SizedBox(height: 20,),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow((RegExp(r'[0-9]'))),
          ],
          decoration: InputDecoration(label: Text("Break time (minutes):")),
          onChanged: (value) => _breakTime = int.parse(value),
        ),
        SizedBox(height: 20,),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow((RegExp(r'[0-9]'))),
          ],
          decoration: InputDecoration(label: Text("Long break time (minutes):")),
          onChanged: (value) => _longBreakTime = int.parse(value),
        ),
        SizedBox(height: 50,),
        SquareButton(_saveSettings, buttonText: "Save and Apply")
      ],
    );
  }
}
