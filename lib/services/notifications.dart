import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

const String _channelId = 'pomoslice_sessions_v2';
const String _channelName = 'PomoSlice Sessions';
const String _channelDescription =
    'Notifications for Pomodoro sessions and breaks';

final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<void> _notificationTapController =
    StreamController<void>.broadcast();

/// Emits whenever the user taps a PomoSlice notification while the app is
/// running.
Stream<void> get notificationTaps => _notificationTapController.stream;

/// Called by the OS when a notification action is handled in a background
/// isolate. The app currently has no actions, so there is nothing to do here.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

void _onNotificationResponse(NotificationResponse notificationResponse) {
  if (!_notificationTapController.isClosed) {
    _notificationTapController.add(null);
  }
}

/// Whether local notifications are implemented on this platform.
bool get notificationsSupported => _notificationsSupported;

bool get _notificationsSupported {
  if (kIsWeb) {
    return false;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.linux:
    case TargetPlatform.windows:
    case TargetPlatform.fuchsia:
      return false;
  }
}

Future<void> initNotifications() async {
  if (!_notificationsSupported) {
    return;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_stat_pomoslice');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _createAndroidChannel();
    return;
  }

  const DarwinInitializationSettings darwinSettings =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
  const InitializationSettings initializationSettings = InitializationSettings(
    iOS: darwinSettings,
    macOS: darwinSettings,
  );

  await _notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
}

Future<void> _createAndroidChannel() async {
  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  if (androidPlugin == null) {
    return;
  }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alarm'),
    enableVibration: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
  );

  await androidPlugin.createNotificationChannel(channel);
}

/// Requests the permissions needed to display notifications.
///
/// Returns `false` when notifications are unavailable or denied.
Future<bool> ensureNotificationPermissions() async {
  if (!_notificationsSupported) {
    return false;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin == null) {
      return false;
    }

    bool enabled = await androidPlugin.areNotificationsEnabled() ?? false;
    if (!enabled) {
      enabled = await androidPlugin.requestNotificationsPermission() ?? false;
    }
    return enabled;
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final IOSFlutterLocalNotificationsPlugin? iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  if (defaultTargetPlatform == TargetPlatform.macOS) {
    final MacOSFlutterLocalNotificationsPlugin? macosPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
    return await macosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  return false;
}

const AndroidNotificationDetails _androidNotificationDetails =
    AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      ticker: 'ticker',
    );

const DarwinNotificationDetails _darwinNotificationDetails =
    DarwinNotificationDetails(presentAlert: true, presentSound: true);

/// Schedules a local notification for [scheduledDate].
///
/// Returns `true` when the notification was scheduled successfully. On Android
/// it automatically falls back to an inexact alarm when exact alarms are not
/// permitted.
Future<bool> scheduleNotification({
  required String title,
  required String body,
  required DateTime scheduledDate,
  String payload = 'default_payload',
  required int id,
}) async {
  if (!_notificationsSupported || !scheduledDate.isAfter(DateTime.now())) {
    return false;
  }

  const NotificationDetails notificationDetails = NotificationDetails(
    android: _androidNotificationDetails,
    iOS: _darwinNotificationDetails,
    macOS: _darwinNotificationDetails,
  );

  try {
    final tz.TZDateTime zonedDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final bool canScheduleExact =
          await androidPlugin?.canScheduleExactNotifications() ?? false;

      final List<AndroidScheduleMode> scheduleModes = canScheduleExact
          ? <AndroidScheduleMode>[
              AndroidScheduleMode.exactAllowWhileIdle,
              AndroidScheduleMode.inexactAllowWhileIdle,
            ]
          : <AndroidScheduleMode>[AndroidScheduleMode.inexactAllowWhileIdle];

      for (final AndroidScheduleMode scheduleMode in scheduleModes) {
        try {
          await _notificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            zonedDate,
            notificationDetails,
            payload: payload,
            androidScheduleMode: scheduleMode,
          );
          return true;
        } catch (error) {
          debugPrint('Could not schedule notification ($scheduleMode): $error');
        }
      }
      return false;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      zonedDate,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  } catch (error) {
    debugPrint('Could not schedule notification: $error');
    return false;
  }
}

Future<void> cancelNotification(int id) async {
  if (!_notificationsSupported) {
    return;
  }

  try {
    await _notificationsPlugin.cancel(id);
  } catch (error) {
    debugPrint('Could not cancel notification: $error');
  }
}
