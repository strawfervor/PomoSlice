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

  void deleteTaskAndUpdateList(Task task) {
    widget.taskManager.deleteTask(task);
    setState(() {
      tasks = widget.taskManager.tasksList;
    });
  }

  @override
  Widget build(context) {
    return SizedBox(width: 320, 
      child: Column(
        children: [
          Text("Log Screen"),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) => LogCard(
                task: tasks[index],
                lastDone: tasks[index].getLastDone(),
                streak: tasks[index].streak,
                taskName: tasks[index].taskName,
                taskTime: tasks[index].taskTime,
                onDelete: () => deleteTaskAndUpdateList(tasks[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
