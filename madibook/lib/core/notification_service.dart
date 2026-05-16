
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Service to handle Push and Local Notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications for the app.
  Future<void> initialize() async {
    if (kIsWeb) return;

    // 1. Request permissions (especially for iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🔔 Notification permissions granted');
    }

    // 2. Initialize local notifications for foreground alerts
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings iosSettings = IOSInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize local notifications
    try {
      await _localNotifications.initialize(initSettings);
    } catch (e) {
      debugPrint('Local notifications init failed: $e');
    }

    // 3. Create Android notification channel
    if (defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'nexus_high_importance_channel',
        'Nexus Notifications',
        'Important notifications from Nexus.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 4. Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  /// Show a local notification when the app is in the foreground.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      try {
        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'nexus_high_importance_channel',
              'Nexus Notifications',
              'Important notifications from Nexus.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: IOSNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Local notification show failed: $e');
      }
    }
  }

  /// Get FCM Token and save it to the user's document.
  Future<void> updateFcmToken(String userId) async {
    if (kIsWeb) return; // Prevent Web crash

    try {
      String? token = await _fcm.getToken();
    if (token != null) {
      debugPrint('🔑 FCM Token: $token');
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcm_token': token,
        'last_active': FieldValue.serverTimestamp(),
      });
    }
    } catch (e) {
      debugPrint('FCM Token error: $e');
    }
  }
}

/// Top-level background message handler.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌙 Handling background message: ${message.messageId}');
}
