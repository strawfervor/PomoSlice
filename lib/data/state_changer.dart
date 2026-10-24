class StateChanger {
  StateChanger(this.pomodoroTime, this.breakTime, this.longBreakTime) {
    setStateTime();
  }

  static const int pomodorosBeforeLongBreak = 4;

  int currentState = 0;
  int stateTime = 60 * 25;
  int pomodoroTime = 25;
  int breakTime = 5;
  int longBreakTime = 15;
  int completedPomodoros = 0;

  void nextState() {
    if (currentState == 0) {
      completedPomodoros++;
      currentState = completedPomodoros % pomodorosBeforeLongBreak == 0 ? 2 : 1;
    } else {
      currentState = 0;
    }
    setStateTime();
  }

  void toggleState() {
    if (currentState < 2) {
      currentState++;
      setStateTime();
    } else {
      currentState = 0;
      setStateTime();
    }
  }

  void setNowPomodoro() {
    currentState = 0;
    setStateTime();
  }

  void setNowBreak() {
    currentState = 1;
    setStateTime();
  }

  void setNowLongBreak() {
    currentState = 2;
    setStateTime();
  }

  int getCurrentStateTime() {
    return stateTime;
  }

  String buttonTime() {
    String minutes = (stateTime / 60).toInt().toString().padLeft(2, '0');
    String seconds = (stateTime % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  String getCurrentStateName() {
    String btnTime = buttonTime();
    switch (currentState) {
      case 0:
        return "Pomodoro ($btnTime)";
      case 1:
        return "Break ($btnTime)";
      case 2:
        return "Long break ($btnTime)";
      default:
        return "Error";
    }
  }

  void setStateTime() {
    switch (currentState) {
      case 0:
        stateTime = pomodoroTime * 60;
        break;
      case 1:
        stateTime = breakTime * 60;
        break;
      case 2:
        stateTime = longBreakTime * 60;
        break;
      default:
        stateTime = 25 * 60;
        break;
    }
  }
}
