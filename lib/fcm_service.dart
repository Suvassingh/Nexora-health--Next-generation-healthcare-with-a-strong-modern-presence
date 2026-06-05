



import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _supabase = Supabase.instance.client;
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  /// Call once on app startup (after Firebase & Supabase are ready)
  static Future<void> initialize() async {
    //  Local notifications setup 
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotif.initialize(settings);

    //  FCM setup 
    // Request permissions (iOS)
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Send current token if user already logged in
    await _sendCurrentToken();

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      _sendCurrentToken(token: newToken);
    });

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Call after EVERY successful login (email/password, Google, etc.)
  static Future<void> onUserLogin() async {
    await _sendCurrentToken();
  }

  /// Call on explicit logout – removes all tokens for the current user
  static Future<void> onUserLogout() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('fcm_tokens').delete().eq('user_id', userId);
      debugPrint('Cleared FCM tokens for user $userId');
    } catch (e) {
      debugPrint(' Failed to clear tokens: $e');
    }
  }

  //  internal token sync 
  static Future<void> _sendCurrentToken({String? token}) async {
    try {
      final fcmToken = token ?? await _messaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      final user = _supabase.auth.currentUser;
      if (user == null) return; 

      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android';

      await _supabase.functions.invoke(
        'update-fcm-token',
        body: {'token': fcmToken, 'platform': platform},
      );
      debugPrint('FCM token synced for user ${user.id}');
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  //  Missed call notification helpers 
  static void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'missed_call') {
      _showMissedCallNotification(data);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    final data = message.data;
    if (data['type'] == 'missed_call') {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const settings = InitializationSettings(android: android, iOS: ios);
      await _localNotif.initialize(settings);
      await _showMissedCallNotification(data);
    }
  }

  static Future<void> _showMissedCallNotification(
    Map<String, dynamic> data,
  ) async {
    final callerName = data['callerName'] ?? 'Unknown';
    final callId =
        data['callId'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    const androidDetails = AndroidNotificationDetails(
      'missed_calls',
      'Missed Calls',
      channelDescription: 'Notifications for missed calls',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotif.show(
      callId.hashCode,
      'Missed Call',
      'Missed call from $callerName',
      details,
      payload: jsonEncode({'type': 'missed_call', 'callId': callId}),
    );
  }
}
