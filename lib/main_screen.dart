import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/data/task_manager.dart';
import 'package:pomoslice/log_screen.dart';
import 'package:pomoslice/setting_screen.dart';
import 'package:pomoslice/timer_screen.dart';
import 'package:pomoslice/components/background_container.dart';
import 'package:pomoslice/data/state_changer.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int screenNumber = 0;
  bool startedTimer = false;
  int currentTimerValue = 21;
  String buttonStateText = "";
  bool paused = false;
  final audioPlayer = AudioPlayer();

  TaskManager tasksManager = TaskManager();

  var myStateChanger = StateChanger(1, 1, 1);

  @override
  void initState() {
    currentTimerValue = myStateChanger.getCurrentStateTime();
    buttonStateText = myStateChanger.getCurrentStateName();

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

    super.initState();
  }

  Timer? _timer;

  void toggleTimer() {
    audioPlayer.stop();
    currentTimerValue = myStateChanger.getCurrentStateTime();
    if (!startedTimer) {
      setState(() {
        startedTimer = !startedTimer;
      });
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        if (!paused) {
          setState(() {
            currentTimerValue -= 10;
          });
        }
        debugPrint("Curerent time: $currentTimerValue");
        if (currentTimerValue <= 0) {
          toggleTimer();
          timerEnd();
        }
      });
    } else {
      _timer?.cancel();
      setState(() {
        startedTimer = !startedTimer;
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
    currentTimerValue = 60;
    timeOutAddTask();
    myStateChanger.nextState();
    setState(() {
      buttonStateText = myStateChanger.getCurrentStateName();
    });
    currentTimerValue = myStateChanger.getCurrentStateTime();
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
