import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';

class TaskManager {

  final List<Task> tasksList = [];
  String currentSelectedTask = "";

  void addTask(Task task) {
    tasksList.add(task);
  }

  void updateTask(Task task) {
    Task? taskToUpdate = tasksList.where((t) => t.taskName == task.taskName).firstOrNull;

    if (taskToUpdate != null) {
      taskToUpdate.taskTime += task.taskTime;
      taskToUpdate.checkStreak();
      taskToUpdate.lastDone = task.lastDone;
    } else {
      addTask(task);
    }
  }

  void setCurrentSelecedTask(String currentTask) {
    currentSelectedTask = currentTask;
    debugPrint("Wpisany tekst: $currentTask");
  }

  List<String> getTaskNames() {
    List<String> taskNames = [];
    for (Task task in tasksList) {
      taskNames.add(task.getName());
    }
    return taskNames;
  }
}