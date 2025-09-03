import 'package:flutter/material.dart';
import 'package:pomoslice/log_screen.dart';
import 'package:pomoslice/timer_screen.dart';
import 'package:pomoslice/components/background_container.dart';
import 'package:pomoslice/data/state_changer.dart';
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

  var myStateChanger = StateChanger(25, 5, 15);

  @override
  void initState() {
    currentTimerValue = myStateChanger.getCurrentStateTime();
    buttonStateText = myStateChanger.getCurrentStateName();
    super.initState();
  }

  Timer? _timer;

  void toggleTimer() {
    currentTimerValue = myStateChanger.getCurrentStateTime();
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

  void toggleState(){
    myStateChanger.toggleState();
    setState(() {
      buttonStateText = myStateChanger.getCurrentStateName();
    });
  }

  void timerEnd() {
    debugPrint("Timer end");
    currentTimerValue = 60;
    myStateChanger.nextState();
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
            toggleTimer: toggleTimer,
            toggleState: toggleState,
            startedTimer: startedTimer,
            currentTimerValue: currentTimerValue,
            buttonStateText: buttonStateText
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
