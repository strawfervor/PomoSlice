import 'package:flutter/material.dart';

class LogCard extends StatelessWidget{
  const LogCard({super.key, required this.taskName, required this.taskTime, required this.streak, required this.lastDone});

  final String taskName;
  final int taskTime;
  final int streak;
  final String lastDone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Center(child: Text(taskName),),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text('Total time: $taskTime (min)'),
                Spacer(),
                Text('Streak: $streak'),
              ],
            ),
          ),
          Text('Last done: $lastDone'),
        ],
      ),
    );
  }
}