import 'package:flutter/material.dart';
import 'package:pomoslice/components/tasks_autocomplete.dart';
import 'package:pomoslice/components/square_button.dart';
import 'package:pomoslice/data/task_manager.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({
    super.key,
    required this.toggleTimer,
    required this.toggleState,
    required this.currentTimerValue,
    required this.buttonStateText,
    required this.startedTimer,
    required this.taskManager,
    required this.taskController,
  });

  final VoidCallback toggleTimer;
  final VoidCallback toggleState;
  final TaskManager taskManager;
  final bool startedTimer;
  final int currentTimerValue;
  final String buttonStateText;
  final TextEditingController taskController;

  Widget toggleButton() {
    return SquareButton(
      onPressed: startedTimer ? null : toggleState,
      buttonText: buttonStateText,
    );
  }

  @override
  Widget build(context) {
    String minutes = (currentTimerValue / 60).toInt().toString().padLeft(
      2,
      '0',
    );
    String seconds = (currentTimerValue % 60).toString().padLeft(2, '0');
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "$minutes:$seconds",
                maxLines: 1,
                softWrap: false,
                style: TextStyle(fontSize: 68, fontWeight: FontWeight.w400),
              ),
            ),
            Text(buttonStateText),
            SizedBox(height: 120),
            toggleButton(),
            SizedBox(height: 30),
            Align(alignment: Alignment.bottomLeft, child: Text("Task:")),
            SizedBox(
              width: 200,
              child: TasksAutocomplete(
                tasksList: taskManager.getTaskNames(),
                taskManager: taskManager,
                controller: taskController,
              ),
            ),
            SizedBox(height: 30),
            SquareButton(
              onPressed: toggleTimer,
              buttonText: startedTimer ? "Stop" : "Start",
            ),
          ],
        ),
      ),
    );
  }
}
