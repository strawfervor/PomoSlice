import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:pomoslice/data/task.dart';

class TaskManager {
  final Box<Task> _tasksBox = Hive.box<Task>('tasksBox');

  List<Task> get tasksList => _tasksBox.values.toList();

  String currentSelectedTask = "";

  void addTask(Task task) {
    _tasksBox.add(task);
  }

  void deleteTask(Task task) {
    task.delete();
  }

  void updateTask(Task incomingTask) {
    Task? taskToUpdate = tasksList
        .where((t) => t.taskName == incomingTask.taskName)
        .firstOrNull;

    if (taskToUpdate != null) {
      taskToUpdate.updateTaskTime(incomingTask.taskTime);
      taskToUpdate.checkStreak();
    } else {
      addTask(incomingTask);
    }
  }

  void setCurrentSelecedTask(String currentTask) {
    currentSelectedTask = currentTask;
    debugPrint("Wpisany tekst: $currentTask");
  }

  List<String> getTaskNames() {
    return tasksList.map((task) => task.getName()).toList();
  }
}
