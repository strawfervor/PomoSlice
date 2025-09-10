class Task {
  Task(this.taskName, this.taskTime);

  final String taskName;
  int taskTime;
  int streak = 0;
  DateTime lastDone = DateTime.now();

  void checkStreak() {
    if (DateTime.now().difference(lastDone).inDays == 1) {
      streak++;
    } else if (DateTime.now().difference(lastDone).inDays > 1) {
      streak = 1;
    }
    lastDone = DateTime.now();
  }

  void updateTaskTime(int time) {
    taskTime += time;
  }

  int getTaskTime(){
    return taskTime;
  }

  int getStreak(){
    return streak;
  }

  String getName(){
    return taskName;
  }

  String getLastDone(){
    return lastDone.toString();
  }

  String getDetails(){
    return '$taskName: $taskTime minuts, streak: $streak';
  }
}