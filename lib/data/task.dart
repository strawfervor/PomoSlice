import 'package:hive_ce_flutter/hive_flutter.dart';

class Task extends HiveObject {
  Task(this.taskName, this.taskTime);

  final String taskName;
  int taskTime;
  int streak = 1;
  DateTime lastDone = DateTime.now();

  void checkStreak() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime lastDoneDay = DateTime(
      lastDone.year,
      lastDone.month,
      lastDone.day,
    );
    final int dayDifference = today.difference(lastDoneDay).inDays;

    if (dayDifference == 0) {
      if (streak == 0) {
        streak = 1;
      }
    } else if (dayDifference == 1) {
      streak = streak == 0 ? 1 : streak + 1;
    } else {
      streak = 1;
    }

    lastDone = now;
    save();
  }

  void updateTaskTime(int time) {
    taskTime += time;
    save();
  }

  int getTaskTime() {
    return taskTime;
  }

  int getStreak() {
    return streak;
  }

  String getName() {
    return taskName;
  }

  String getDetails() {
    return '$taskName: $taskTime minutes, streak: $streak';
  }

  String getLastDoneDate() {
    final day = lastDone.day.toString().padLeft(2, '0');
    final month = lastDone.month.toString().padLeft(2, '0');
    final year = lastDone.year.toString();

    return '$day.$month.$year';
  }

  String getLastDoneTime() {
    final hour = lastDone.hour.toString().padLeft(2, '0');
    final minute = lastDone.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String getLastDone() {
    final day = getLastDoneDate();
    final hour = getLastDoneTime();
    return '$day @ $hour';
  }
}
