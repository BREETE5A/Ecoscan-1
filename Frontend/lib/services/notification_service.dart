import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();
  static const _channelId = 'ecoscan_channel';

  static Future<void> init() async {
    // Init timezone — Maroc (Africa/Casablanca)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Casablanca'));

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Fire & forget — ne bloque pas si hors-ligne (FCM nécessite internet)
    _messaging.getToken().then(_saveToken).catchError((_) {});
    _messaging.onTokenRefresh.listen(_saveToken);

    FirebaseMessaging.onMessage.listen(_handleForeground);
  }

  static Future<void> _saveToken(String? token) async {
    if (token == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> _handleForeground(RemoteMessage message) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await _showLocal(
      title: message.notification?.title ?? 'EcoScan',
      body: message.notification?.body ?? '',
    );
  }

  static Future<void> _showLocal({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId, 'EcoScan',
      channelDescription: 'Notifications EcoScan',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title, body,
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ── Rappels planifiés ────────────────────────────────────────────────────────

  static Future<void> scheduleDailyReminders() async {
    try {
      await _local.cancel(10);
      await _local.zonedSchedule(
        10,
        '🌿 EcoScan — Rappel du jour',
        'Triez vos déchets aujourd\'hui et gagnez des points !',
        _nextInstanceOfHour(8, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId, 'EcoScan',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // ignore notification scheduling errors
    }
  }

  static Future<void> scheduleWeeklyChallengeReminder() async {
    try {
      await _local.cancel(11);
      await _local.zonedSchedule(
        11,
        '🏆 Nouveaux défis hebdomadaires !',
        'De nouveaux défis vous attendent cette semaine. Relevez-les !',
        _nextInstanceOfWeekday(DateTime.monday, 8, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId, 'EcoScan',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      // ignore notification scheduling errors
    }
  }

  static tz.TZDateTime _nextInstanceOfHour(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    tz.TZDateTime scheduled = _nextInstanceOfHour(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> showNewRewardUnlocked(String rewardName) async {
    await _showLocal(
      title: '🎁 Récompense disponible !',
      body: 'Vous avez assez de points pour "$rewardName"',
    );
  }

  static Future<void> markAsRead(String notificationId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  static Stream<List<Map<String, dynamic>>> getNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }
}
