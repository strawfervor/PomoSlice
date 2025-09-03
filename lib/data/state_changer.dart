class StateChanger {
  StateChanger(this.pomodorTime, this.breakTime, this.longBreakTime) {
    setStateTime();
  }

  int currentState = 0;
  int stateTime = 60 * 25;
  int pomodorTime = 25;
  int breakTime = 5;
  int longBreakTime = 15;

  void nextState() {
    if (currentState < 1) {
      currentState++;
      setStateTime();
    } else {
      currentState = 0;
      setStateTime();
    }
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

  void setNowPomodoro(){
    currentState = 0;
    setStateTime();
  }

  void setNowBreak() {
    currentState = 1;
    setStateTime();
  }

  void setNowLongBreak(){
    currentState = 2;
    setStateTime();
  }

  int getCurrentStateTime() {
    return stateTime;
  }

  String buttonTime(){
    String minutes = (stateTime / 60).toInt().toString().padLeft(2, '0');
    String seconds = (stateTime % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  String getCurrentStateName() {
    String btnTime = buttonTime();
    switch (currentState) {
      case 0:
        return "Pomodoro ($btnTime mins)";
      case 1:
        return "Break ($btnTime mins)";
      case 2:
        return "Long break ($btnTime mins)";
      default:
        return "error";
    }
  }

  void setStateTime() {
    switch (currentState) {
      case 0:
        stateTime = pomodorTime * 60;
        break;
      case 1:
        stateTime = breakTime * 60;
        break;
      case 2:
        stateTime = longBreakTime * 60;
        break;
      default:
        stateTime = 25;
        break;
    }
  }
}