import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:pomoslice/data/task.dart';

class TaskManager {
  final Box<Task> _tasksBox = Hive.box<Task>('tasksBox');

  List<Task> get tasksList => _tasksBox.values.toList();

  late final ValueListenable<Box<Task>> _listenable = _tasksBox.listenable();

  ValueListenable<Box<Task>> get listenable => _listenable;

  String currentSelectedTask = "";

  void addTask(Task task) {
    if (task.taskName.trim().isEmpty) {
      return;
    }
    _tasksBox.add(task);
  }

  void deleteTask(Task task) {
    task.delete();
  }

  void updateTask(Task incomingTask) {
    final String taskName = incomingTask.taskName.trim();
    if (taskName.isEmpty) {
      return;
    }

    Task? taskToUpdate = tasksList
        .where((t) => t.taskName.trim().toLowerCase() == taskName.toLowerCase())
        .firstOrNull;

    if (taskToUpdate != null) {
      taskToUpdate.updateTaskTime(incomingTask.taskTime);
      taskToUpdate.checkStreak();
    } else {
      addTask(Task(taskName, incomingTask.taskTime));
    }
  }

  void setCurrentSelectedTask(String currentTask) {
    currentSelectedTask = currentTask;
  }

  List<String> getTaskNames() {
    return tasksList
        .map((task) => task.getName().trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }
}
