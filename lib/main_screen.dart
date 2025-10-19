import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/data/task_manager.dart';
import 'package:pomoslice/log_screen.dart';
import 'package:pomoslice/main.dart';
import 'package:pomoslice/setting_screen.dart';
import 'package:pomoslice/timer_screen.dart';
import 'package:pomoslice/components/background_container.dart';
import 'package:pomoslice/data/state_changer.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.pomodoroBreak,
    required this.pomodoroLongBreak,
    required this.pomodoroTime,
  });

  final int pomodoroTime;
  final int pomodoroBreak;
  final int pomodoroLongBreak;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int screenNumber = 0;
  bool startedTimer = false;
  int currentTimerValue = 0;
  String buttonStateText = "";
  final audioPlayer = AudioPlayer();
  late TextEditingController taskController;

  TaskManager tasksManager = TaskManager();
  late StateChanger myStateChanger;

  Timer? _timer;
  DateTime? _endTime;

  final int pomodoroNotificationId = 0;

  @override
  void initState() {
    super.initState();
    myStateChanger = StateChanger(
      widget.pomodoroTime,
      widget.pomodoroBreak,
      widget.pomodoroLongBreak,
    );
    taskController = TextEditingController();

    currentTimerValue = myStateChanger.getCurrentStateTime();
    buttonStateText = myStateChanger.getCurrentStateName();
    myStateChanger.setStateTime();

    audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  void toggleTimer() {
    audioPlayer.stop();

    if (!startedTimer) {
      setState(() {
        startedTimer = true;
        currentTimerValue = myStateChanger.getCurrentStateTime();
      });

      _endTime = DateTime.now().add(Duration(seconds: currentTimerValue));

      final notificationBody = (myStateChanger.currentState == 0)
          ? 'Your Pomodoro session is over! Time for a break.'
          : 'Your break is over! Time to focus.';

      scheduleNotification(
        id: pomodoroNotificationId,
        title: 'PomoSlice',
        body: notificationBody,
        durationInSeconds: currentTimerValue,
        payload: 'pomodoro_end',
      );

      _timer = Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
        if (_endTime == null) return;

        final now = DateTime.now();
        final remaining = _endTime!.difference(now);

        if (remaining.isNegative) {
          setState(() {
            currentTimerValue = 0;
            startedTimer = false;
          });
          _timer?.cancel();
          _timer = null;
          _endTime = null;
          timerEnd();
        } else {
          setState(() {
            currentTimerValue = (remaining.inMilliseconds / 1000).ceil();
          });
        }
      });
    } else {
      _timer?.cancel();
      _timer = null;
      _endTime = null;

      cancelNotification(pomodoroNotificationId);

      setState(() {
        startedTimer = false;
        currentTimerValue = myStateChanger.getCurrentStateTime();
      });
    }
  }

  void toggleState() {
    myStateChanger.toggleState();
    refreshStateChanger();
  }

  void refreshStateChanger() {
    setState(() {
      buttonStateText = myStateChanger.getCurrentStateName();
    });
    if (!startedTimer) {
      setState(() {
        currentTimerValue = myStateChanger.getCurrentStateTime();
      });
    }
  }

  Future<void> playAlarm() async {
    await audioPlayer.play(AssetSource('alarm.mp3'));
  }

  void timerEnd() async {
    debugPrint("Timer end");
    timeOutAddTask();
    myStateChanger.nextState();

    setState(() {
      buttonStateText = myStateChanger.getCurrentStateName();
      currentTimerValue = myStateChanger.getCurrentStateTime();
    });

    await audioPlayer.play(AssetSource('alarm.mp3'));
    Vibration.vibrate(
      preset: VibrationPreset.countdownTimerAlert,
      duration: 3000,
    );
  }

  Widget currentScreen = Text("Screen");

  @override
  void dispose() {
    _timer?.cancel();
    audioPlayer.dispose();
    taskController.dispose();
    super.dispose();
  }

  void timeOutAddTask() {
    if (myStateChanger.currentState == 0) {
      Task newTask = Task(
        tasksManager.currentSelectedTask,
        myStateChanger.pomodorTime,
      );
      tasksManager.updateTask(newTask);
    }
  }

  @override
  Widget build(context) {
    if (screenNumber == 0) {
      refreshStateChanger();
      currentScreen = TimerScreen(
        toggleTimer: toggleTimer,
        taskManager: tasksManager,
        toggleState: toggleState,
        startedTimer: startedTimer,
        currentTimerValue: currentTimerValue,
        buttonStateText: buttonStateText,
        taskController: taskController,
      );
    } else if (screenNumber == 1) {
      currentScreen = LogScreen(taskManager: tasksManager);
    } else if (screenNumber == 2) {
      currentScreen = SettingScreen(stateChanger: myStateChanger);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: screenNumber,
          onDestinationSelected: (int index) {
            setState(() {
              screenNumber = index;
              debugPrint("Current screen index is: $index");
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.access_time),
              label: 'Timer',
            ),
            NavigationDestination(icon: Icon(Icons.notes), label: 'Activities'),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        body: SafeArea(child: BackgroundContainer(child: currentScreen)),
      ),
    );
  }
}
