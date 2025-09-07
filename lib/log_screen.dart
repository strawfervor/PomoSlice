import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  Task t1 = Task('Testowanie', 30);

  void taskManipulator() {
    setState(() {
      t1.updateTaskTime(10);
    });
  }

  @override
  Widget build(context) {
    String taskT1 = t1.getDetails();
    return Column(children: [
      Text("Log Screen"),
      ElevatedButton(onPressed: taskManipulator, child: Text("Increase time")),
      Text('data of thing: $taskT1'),      
    ]);
  }
}
