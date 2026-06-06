import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/models.dart';

/// LE coeur du produit : des rappels FIABLES (le point faible de tous les
/// concurrents). Notifications locales planifiées (pas de serveur) + timezone.
/// Voir Spec-app-animaux.pdf §10.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1) Timezone (cause n°1 des bugs : toujours planifier en TZDateTime)
    tzdata.initializeTimeZones();
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Paris'));
    }

    // 2) Init du plugin
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  /// À appeler une fois (ex. au premier lancement ou depuis les réglages).
  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Rappels de soins',
          channelDescription: 'Rappels de médicaments et de soins',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// id stable par (traitement, créneau) pour pouvoir annuler/replanifier.
  int _notifId(int treatmentId, int index) => treatmentId * 100 + index;

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Planifie un rappel quotidien par créneau du traitement.
  Future<void> scheduleForTreatment(Treatment t) async {
    if (t.id == null || !t.active) return;
    await cancelForTreatment(t.id!);
    for (var i = 0; i < t.times.length; i++) {
      final parts = t.times[i].split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      await _plugin.zonedSchedule(
        _notifId(t.id!, i),
        '💊 ${t.name}',
        'Dose : ${t.dosage} — c\'est l\'heure',
        _nextInstanceOfTime(hour, minute),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // répétition quotidienne
      );
    }
  }

  Future<void> cancelForTreatment(int treatmentId, {int maxSlots = 20}) async {
    for (var i = 0; i < maxSlots; i++) {
      await _plugin.cancel(_notifId(treatmentId, i));
    }
  }
}
