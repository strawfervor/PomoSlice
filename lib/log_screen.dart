import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:pomoslice/components/log_card.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/data/task_manager.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key, required this.taskManager});

  final TaskManager taskManager;

  @override
  Widget build(context) {
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          SizedBox(height: 50),
          Text("Activities", style: TextStyle(fontSize: 52)),
          SizedBox(height: 20),
          Expanded(
            child: ValueListenableBuilder<Box<Task>>(
              valueListenable: taskManager.listenable,
              builder: (context, box, _) {
                final List<Task> tasks = box.values
                    .where((task) => task.taskName.trim().isNotEmpty)
                    .toList();
                if (tasks.isEmpty) {
                  return const Center(child: Text('No activities yet.'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (BuildContext context, int index) => LogCard(
                    lastDone: tasks[index].getLastDone(),
                    streak: tasks[index].streak,
                    taskName: tasks[index].taskName,
                    taskTime: tasks[index].taskTime,
                    onDelete: () => taskManager.deleteTask(tasks[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
