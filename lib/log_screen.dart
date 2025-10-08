import 'package:flutter/material.dart';
import 'package:pomoslice/components/log_card.dart';
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
        Expanded(child: ListView.builder(itemCount: tasks.length, itemBuilder: (BuildContext context, int index) => 
          LogCard(taskName: tasks[index].getName(), taskTime: tasks[index].getTaskTime(), streak: tasks[index].getStreak(), lastDone: tasks[index].getLastDone()))),
      ]
    );
  }
}
