import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();
  static const _channelId = 'ecoscan_channel';

  static Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final token = await _messaging.getToken();
    await _saveToken(token);
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
