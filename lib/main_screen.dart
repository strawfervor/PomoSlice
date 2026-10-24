import 'package:flutter/material.dart';
import 'package:pomoslice/data/task.dart';
import 'package:pomoslice/data/task_manager.dart';
import 'package:pomoslice/log_screen.dart';
import 'package:pomoslice/services/notifications.dart';
import 'package:pomoslice/setting_screen.dart';
import 'package:pomoslice/timer_screen.dart';
import 'package:pomoslice/components/background_container.dart';
import 'package:pomoslice/data/state_changer.dart';
import 'package:vibration/vibration.dart';
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
  int _sessionMinutes = 0;
  int _timerGeneration = 0;

  // The in-app alarm is used when a notification cannot be scheduled (for
  // example when the user denied notification permissions).
  bool _useInAppAlarm = true;
  bool _notificationWarningShown = false;

  StreamSubscription<void>? _notificationTapSubscription;

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

    _notificationTapSubscription = notificationTaps.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        screenNumber = 0;
      });
    });

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
    unawaited(audioPlayer.stop());

    if (!startedTimer) {
      final int durationSeconds = myStateChanger.getCurrentStateTime();
      final int generation = ++_timerGeneration;

      setState(() {
        startedTimer = true;
        currentTimerValue = durationSeconds;
        _sessionMinutes = (durationSeconds / 60).ceil();
      });

      _endTime = DateTime.now().add(Duration(seconds: durationSeconds));
      _useInAppAlarm = true;

      // Remove a stale notification from a previous session before scheduling
      // the new one.
      unawaited(cancelNotification(pomodoroNotificationId));
      unawaited(_scheduleTimerNotification(generation));

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
      _timerGeneration++;
      _timer?.cancel();
      _timer = null;
      _endTime = null;

      unawaited(cancelNotification(pomodoroNotificationId));

      setState(() {
        startedTimer = false;
        currentTimerValue = myStateChanger.getCurrentStateTime();
      });
    }
  }

  Future<void> _scheduleTimerNotification(int generation) async {
    final DateTime? endTime = _endTime;
    if (endTime == null) {
      return;
    }

    final String notificationBody = (myStateChanger.currentState == 0)
        ? 'Your Pomodoro session is over! Time for a break.'
        : 'Your break is over! Time to focus.';

    final bool hasPermission = await ensureNotificationPermissions();
    if (!mounted ||
        generation != _timerGeneration ||
        !startedTimer ||
        _endTime == null) {
      return;
    }

    bool scheduled = false;
    if (hasPermission) {
      scheduled = await scheduleNotification(
        id: pomodoroNotificationId,
        title: 'PomoSlice',
        body: notificationBody,
        scheduledDate: endTime,
        payload: 'pomodoro_end',
      );
    }

    if (!mounted || generation != _timerGeneration || !startedTimer) {
      return;
    }

    setState(() {
      _useInAppAlarm = !scheduled;
    });

    if (!scheduled && notificationsSupported && !_notificationWarningShown) {
      _notificationWarningShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are unavailable, so the alarm will play inside the app.',
          ),
        ),
      );
    }
  }

  void toggleState() {
    myStateChanger.toggleState();
    setState(() {
      buttonStateText = myStateChanger.getCurrentStateName();
      if (!startedTimer) {
        currentTimerValue = myStateChanger.getCurrentStateTime();
      }
    });
  }

  void syncTimerWithState() {
    setState(() {
      buttonStateText = myStateChanger.getCurrentStateName();
      if (!startedTimer) {
        currentTimerValue = myStateChanger.getCurrentStateTime();
      }
    });
  }

  Future<void> playAlarm() async {
    try {
      await audioPlayer.play(AssetSource('alarm.mp3'));
    } catch (error) {
      debugPrint('Could not play the alarm: $error');
    }
  }

  void timerEnd() {
    debugPrint("Timer end");
    timeOutAddTask();
    myStateChanger.nextState();

    setState(() {
      buttonStateText = myStateChanger.getCurrentStateName();
      currentTimerValue = myStateChanger.getCurrentStateTime();
    });

    if (_useInAppAlarm) {
      unawaited(playAlarm());
      unawaited(Vibration.vibrate(duration: 3000));
    }
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    _timer?.cancel();
    audioPlayer.dispose();
    taskController.dispose();
    super.dispose();
  }

  void timeOutAddTask() {
    if (myStateChanger.currentState != 0) {
      return;
    }

    final String taskName = tasksManager.currentSelectedTask.trim();
    if (taskName.isEmpty) {
      return;
    }

    final int minutes = _sessionMinutes > 0
        ? _sessionMinutes
        : myStateChanger.pomodoroTime;
    tasksManager.updateTask(Task(taskName, minutes));
  }

  @override
  Widget build(context) {
    final Widget currentScreen;
    if (screenNumber == 0) {
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
    } else {
      currentScreen = SettingScreen(
        stateChanger: myStateChanger,
        onSettingsApplied: syncTimerWithState,
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: screenNumber,
          onDestinationSelected: (int index) {
            setState(() {
              screenNumber = index;
              if (index == 0 && !startedTimer) {
                buttonStateText = myStateChanger.getCurrentStateName();
                currentTimerValue = myStateChanger.getCurrentStateTime();
              }
            });
          },
          destinations: const [
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
