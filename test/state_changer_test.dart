import 'package:flutter_test/flutter_test.dart';
import 'package:pomoslice/data/state_changer.dart';

void main() {
  group('StateChanger', () {
    test('starts with a pomodoro', () {
      final changer = StateChanger(25, 5, 15);

      expect(changer.currentState, 0);
      expect(changer.getCurrentStateTime(), 25 * 60);
      expect(changer.getCurrentStateName(), 'Pomodoro (25:00)');
    });

    test('moves from pomodoro to a short break and back', () {
      final changer = StateChanger(25, 5, 15);

      changer.nextState();
      expect(changer.currentState, 1);
      expect(changer.getCurrentStateTime(), 5 * 60);

      changer.nextState();
      expect(changer.currentState, 0);
      expect(changer.getCurrentStateTime(), 25 * 60);
    });

    test('takes a long break after four completed pomodoros', () {
      final changer = StateChanger(25, 5, 15);

      for (int i = 0; i < 3; i++) {
        changer.nextState(); // pomodoro -> break
        changer.nextState(); // break -> pomodoro
      }

      expect(changer.completedPomodoros, 3);

      changer.nextState(); // fourth pomodoro -> long break
      expect(changer.currentState, 2);
      expect(changer.getCurrentStateTime(), 15 * 60);
    });

    test('manual toggle cycles through every state', () {
      final changer = StateChanger(25, 5, 15);

      changer.toggleState();
      expect(changer.currentState, 1);

      changer.toggleState();
      expect(changer.currentState, 2);

      changer.toggleState();
      expect(changer.currentState, 0);
    });

    test('uses the configured durations', () {
      final changer = StateChanger(50, 10, 30);

      expect(changer.getCurrentStateTime(), 50 * 60);
      changer.setNowBreak();
      expect(changer.getCurrentStateTime(), 10 * 60);
      changer.setNowLongBreak();
      expect(changer.getCurrentStateTime(), 30 * 60);
    });
  });
}