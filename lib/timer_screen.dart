import 'package:flutter/material.dart';
import 'package:pomoslice/components/tasks_autocomplete.dart';
import 'package:pomoslice/components/square_button.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    required this.toggleTimer,
    required this.toggleState,
    required this.currentTimerValue,
    required this.buttonStateText,
    required this.startedTimer,
  });

  final Function() toggleTimer;
  final Function() toggleState;
  final bool startedTimer;
  final int currentTimerValue;
  final String buttonStateText;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Function() toggleTimer;
  late Function() toggleState;

  @override
  void initState() {
    super.initState();
    toggleTimer = widget.toggleTimer;
    toggleState = widget.toggleState;
  }

  @override
  Widget build(context) {
    String minutes = (widget.currentTimerValue / 60).toInt().toString().padLeft(
      2,
      '0',
    );
    String seconds = (widget.currentTimerValue % 60).toString().padLeft(2, '0');
    return Column(
      children: [
        SizedBox(height: 30),
        Text(
          "$minutes:$seconds",
          style: TextStyle(fontSize: 68, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 120),
        SquareButton(toggleState, buttonText: widget.buttonStateText),
        SizedBox(height: 30),
        Align(alignment: Alignment.bottomLeft, child: Text("Task:")),
        SizedBox(width: 200, child: TasksAutocomplete()),
        SizedBox(height: 30),
        SquareButton(toggleTimer, buttonText: widget.startedTimer ? "Stop" : "Start"),
      ],
    );
  }
}
