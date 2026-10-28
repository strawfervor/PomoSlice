import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomoslice/components/square_button.dart';
import 'package:pomoslice/data/state_changer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const String _supportUrl = 'https://pomoslice.strawfervor.com';

int _validMinutes(int? value, int fallback) {
  if (value == null || value < 1) {
    return fallback;
  }
  return value;
}

class SettingScreen extends StatefulWidget {
  const SettingScreen({
    super.key,
    required this.stateChanger,
    this.onSettingsApplied,
  });

  final StateChanger stateChanger;
  final VoidCallback? onSettingsApplied;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late StateChanger myStateChanger;
  int _pomodoroTime = 25;
  int _breakTime = 5;
  int _longBreakTime = 15;

  late final TextEditingController _pomodoroController;
  late final TextEditingController _breakController;
  late final TextEditingController _longBreakController;

  @override
  void initState() {
    super.initState();
    myStateChanger = widget.stateChanger;
    _pomodoroController = TextEditingController(text: _pomodoroTime.toString());
    _breakController = TextEditingController(text: _breakTime.toString());
    _longBreakController = TextEditingController(
      text: _longBreakTime.toString(),
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _breakController.dispose();
    _longBreakController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int pomodoro = _validMinutes(prefs.getInt('pomodoroTime'), 25);
      final int breakTime = _validMinutes(prefs.getInt('breakTime'), 5);
      final int longBreak = _validMinutes(prefs.getInt('longBreakTime'), 15);

      if (!mounted) {
        return;
      }

      _pomodoroTime = pomodoro;
      _breakTime = breakTime;
      _longBreakTime = longBreak;

      _pomodoroController.text = pomodoro.toString();
      _breakController.text = breakTime.toString();
      _longBreakController.text = longBreak.toString();
    } catch (error) {
      debugPrint('Could not load settings: $error');
    }
  }

  int? _parseMinutes(String value) {
    final int? parsed = int.tryParse(value);
    if (parsed == null || parsed < 1) {
      return null;
    }
    return parsed;
  }

  void _updateStateChanger() {
    myStateChanger.breakTime = _breakTime;
    myStateChanger.longBreakTime = _longBreakTime;
    myStateChanger.pomodoroTime = _pomodoroTime;
    myStateChanger.setStateTime();
  }

  Future<void> _saveSettings() async {
    final int? pomodoro = _parseMinutes(_pomodoroController.text);
    final int? breakTime = _parseMinutes(_breakController.text);
    final int? longBreak = _parseMinutes(_longBreakController.text);

    if (pomodoro == null || breakTime == null || longBreak == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter whole numbers greater than 0 for all fields.'),
        ),
      );
      return;
    }

    _pomodoroTime = pomodoro;
    _breakTime = breakTime;
    _longBreakTime = longBreak;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pomodoroTime', _pomodoroTime);
    await prefs.setInt('breakTime', _breakTime);
    await prefs.setInt('longBreakTime', _longBreakTime);

    _updateStateChanger();
    widget.onSettingsApplied?.call();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved.')));
  }

  Future<void> _openSupportLink() async {
    final Uri uri = Uri.parse(_supportUrl);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (launched || !mounted) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: _supportUrl));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the link, so it was copied.'),
      ),
    );
  }

  @override
  Widget build(context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 70),
        child: Column(
          children: [
            SizedBox(height: 50),
            Text("Settings", style: TextStyle(fontSize: 52)),
            SizedBox(height: 50),
            TextField(
              controller: _pomodoroController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                label: Text("Pomodoro time (minutes):"),
              ),
              onChanged: (value) {
                final int? parsed = _parseMinutes(value);
                if (parsed != null) {
                  _pomodoroTime = parsed;
                }
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _breakController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(label: Text("Break time (minutes):")),
              onChanged: (value) {
                final int? parsed = _parseMinutes(value);
                if (parsed != null) {
                  _breakTime = parsed;
                }
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _longBreakController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                label: Text("Long break time (minutes):"),
              ),
              onChanged: (value) {
                final int? parsed = _parseMinutes(value);
                if (parsed != null) {
                  _longBreakTime = parsed;
                }
              },
            ),
            SizedBox(height: 50),
            SquareButton(
              onPressed: _saveSettings,
              buttonText: "Save and Apply",
            ),
            SizedBox(height: 100),
            Text(
              "Support PomoSlice",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Enjoying the app? Help keep it free, open-source and ad-free.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 6),
            InkWell(
              onTap: _openSupportLink,
              child: Text(
                _supportUrl,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
