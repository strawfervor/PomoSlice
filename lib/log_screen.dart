import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/data/task_manager.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key, required this.taskManager});

  final TaskManager taskManager;

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<Task> tasks = [];

  Task t1 = Task('Testowanie', 30);

  void taskManipulator() {
    setState(() {
      t1.updateTaskTime(10);
    });
  }

  @override
  void initState() {
    tasks = widget.taskManager.tasksList;
    super.initState();
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        Text("Log Screen"),
        Column(
          children: tasks
              .map((item) => ListTile(leading: Text(item.streak.toString()),title: Text(item.getName()), subtitle: (Text(item.getTaskTime().toString())), ))
              .toList(),
        ),
      ]
    );
  }
}
