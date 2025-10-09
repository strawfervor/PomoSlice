import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/data/task_manager.dart';

class LogCard extends StatelessWidget {
  const LogCard({
    super.key,
    required this.taskName,
    required this.taskTime,
    required this.streak,
    required this.lastDone,
    required this.task,
    required this.taskManager,
  });

  final String taskName;
  final int taskTime;
  final int streak;
  final String lastDone;
  final Task task;
  final TaskManager taskManager;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Card(
        color: Colors.purple[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Center(child: Text(taskName, style: TextStyle(fontSize: 18))),
              SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.watch_later_outlined),
                    SizedBox(width: 10),
                    Text('$taskTime (mins)'),
                    SizedBox(width: 60),
                    Icon(Icons.whatshot),
                    SizedBox(width: 10),
                    Text('$streak'),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Spacer(),
                  Text('Last done: $lastDone'),
                  Spacer(),
                  IconButton(
                    style: ButtonStyle(
                      iconSize: WidgetStateProperty.all(20.0),
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      minimumSize: WidgetStateProperty.all(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.delete),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}