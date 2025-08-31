import 'package:flutter/material.dart';
import 'package:pomoslice/components/tasks_autocomplete.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Text(
          "25:00",
          style: TextStyle(fontSize: 68, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 120),
        OutlinedButton(
          onPressed: () => {},
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Ustawia ostre krawędzie
            ),
            fixedSize: const Size(200, 16),
            padding: EdgeInsets.zero,
          ),
          child: Text("Pomodoro (25 min)", style: TextStyle(fontSize: 16)),
        ),
        SizedBox(height: 30),
        Align(alignment: Alignment.bottomLeft, child: Text("Task:")),
        SizedBox(width: 200, child: TasksAutocomplete()),
        SizedBox(height: 30),
        OutlinedButton(
          onPressed: () => {},
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Ustawia ostre krawędzie
            ),
            fixedSize: const Size(200, 16),
            padding: EdgeInsets.zero,
          ),
          child: Text("Start", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
