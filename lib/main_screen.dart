import 'package:flutter/material.dart';
import 'package:pomoslice/log_screen.dart';
import 'package:pomoslice/timer_screen.dart';
import 'package:pomoslice/components/background_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int screenNumber = 0;
  Widget currentScreen = TimerScreen();

  @override
  Widget build(context) {
    currentScreen = (screenNumber == 0) ? TimerScreen() : LogScreen();
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
