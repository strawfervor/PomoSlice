import 'package:flutter/material.dart';
import 'package:pomoslice/log_screen.dart';
import 'package:pomoslice/timer_screen.dart';
import 'package:pomoslice/components/background_container.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int screenNumber = 0;
  int timePomodoro = 25 * 60;
  int timeBreak = 5 * 60;
  bool startedTimer = false;
  int currentTimerValue = 21;

  Timer? _timer;

  void toggleTimer() {
    if (!startedTimer) {
      setState(() {
        startedTimer = !startedTimer;
      });
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        setState(() {
          currentTimerValue--;
        });
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

  void timerEnd() {
    debugPrint("TIMER IS DFONEENENENENENENE");
  }

  Widget currentScreen = Text("Screen");

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(context) {
    currentScreen = (screenNumber == 0)
        ? TimerScreen(
            timeBreak: timeBreak,
            timePomodoro: timePomodoro,
            toggleTimer: toggleTimer,
            currentTimerValue: currentTimerValue,
          )
        : LogScreen();
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: screenNumber,
        onDestinationSelected: (int index) {
          setState(() {
            screenNumber = index;
            debugPrint("Current screen index is: $index");
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.access_time), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.notes), label: 'Log'),
        ],
      ),
      body: SafeArea(child: BackgroundContainer(child: currentScreen)),
    );
  }
}
