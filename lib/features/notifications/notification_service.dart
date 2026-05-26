import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_strings.dart';
import '../psalm/domain/psalm.dart';
import '../settings/app_settings.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService deve ser sobrescrito no main.');
});

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _payloadController = StreamController<String>.broadcast();
  String? _launchPayload;

  Stream<String> get payloads => _payloadController.stream;

  String? consumeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _payloadController.add(payload);
        }
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = launchDetails?.notificationResponse?.payload;
    }
  }

  Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  Future<void> scheduleDailyPsalms({
    required AppSettings settings,
    required List<Psalm> cache,
  }) async {
    await _plugin.cancelAll();
    if (!settings.notificationsEnabled) {
      return;
    }

    await requestPermissions();
    for (var index = 0; index < settings.notificationTimes.length; index++) {
      final time = settings.notificationTimes[index];
      final psalm = cache.isEmpty ? null : cache[index % cache.length];
      await _plugin.zonedSchedule(
        100 + index,
        psalm?.reference ?? AppStrings.notificationFallbackTitle,
        psalm?.text ?? AppStrings.notificationFallbackBody,
        _nextOccurrence(time.hour, time.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_psalms',
            'Salmos diários',
            channelDescription: 'Lembretes diários com Salmos salvos no app.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: psalm?.encode(),
      );
    }
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
