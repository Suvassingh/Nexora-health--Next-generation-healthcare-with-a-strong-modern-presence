

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:patient_app/livekit_call_screen.dart';
import 'package:patient_app/services/appointment_reminder_service.dart';
import 'package:patient_app/services/presence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controller/app_setting.dart';
import 'controller/internet_status_controller.dart';
import 'fcm_service.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'splash_screen.dart';

// GLOBAL NAVIGATOR

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// BACKGROUND HANDLER

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final data = message.data;

  if (data['type'] == 'incoming_call') {
    final params = CallKitParams(
      id: data['appointmentId'] ?? '',
      nameCaller: data['callerName'] ?? 'Unknown',
      handle: data['callerName'] ?? 'Call',
      type: data['callType'] == 'video' ? 1 : 0,
      duration: 30000,
      extra: {
        'roomName': data['roomName'],
        'token': data['token'],
        'callType': data['callType'],
        'callerId': data['callerId'],
        'appointmentId': data['appointmentId'],
      },
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}

// MAIN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Env
  await dotenv.load(fileName: ".env");

  // Shared prefs
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString("language") ?? "en";

  // GetX controllers
  Get.put(ConnectivityController(), permanent: true);

  // Supabase
  await Supabase.initialize(
    url: dotenv.env['supabase_url']!,
    anonKey: dotenv.env['supabase_anonKey']!,
  );

  final session = Supabase.instance.client.auth.currentSession;
  print('=== SESSION DEBUG ===');
  print('Session exists: ${session != null}');
  print('Is expired: ${session?.isExpired}');
  print(
    'Expires at: ${DateTime.fromMillisecondsSinceEpoch((session?.expiresAt ?? 0) * 1000)}',
  );
  print('Access token (first 20): ${session?.accessToken.substring(0, 20)}');

  // Notifications
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Firebase background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Local notifications
  await NotificationService.instance.initialize();
  await FcmService.initialize();
await AppointmentReminderService.init();
  // FOREGROUND CALL LISTENER
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final data = message.data;

    if (data['type'] == 'incoming_call') {
      final params = CallKitParams(
        id: data['appointmentId'] ?? '',
        nameCaller: data['callerName'] ?? 'Unknown',
        handle: data['callerName'] ?? 'Call',
        type: data['callType'] == 'video' ? 1 : 0,
        duration: 30000,
        extra: {
          'roomName': data['roomName'],
          'token': data['token'],
          'callType': data['callType'],
          'callerId': data['callerId'],
          'appointmentId': data['appointmentId'],
        },
      );

      await FlutterCallkitIncoming.showCallkitIncoming(params);
    }
  });

  
  // CALLKIT EVENTS – kept exactly as in the "CORRECT" block of the commented version
  

  FlutterCallkitIncoming.onEvent.listen((event) async {
    if (event is! CallEvent) return;

    final body = event.body;

    switch (event.event) {
      case Event.actionCallAccept:
        final extra = Map<String, dynamic>.from(body['extra'] ?? {});
        final roomName = extra['roomName'] as String?;
        final token = extra['token'] as String?;
        final callType = extra['callType'] as String?;
        final callerName = body['nameCaller'] ?? 'Unknown';

        if (roomName != null && token != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => LiveKitCallScreen(
                livekitUrl: 'ws://45.115.217.244:7880',
                token: token,
                roomName: roomName,
                remoteUserName: callerName,
                isVideo: callType == 'video',
                isCaller: false,
              ),
            ),
          );
        }
        break;

      case Event.actionCallDecline:
      case Event.actionCallTimeout:
        final callId = body['id'] as String?;
        if (callId != null) {
          await FlutterCallkitIncoming.endCall(callId);
        }
        break;

      default:
        break;
    }
  });

  runApp(
    ProviderScope(
      child: AppSettingsProvider(child: PatientApp(languageCode: languageCode)),
    ),
  );
}

// APP

class PatientApp extends StatefulWidget {
  final String languageCode;

  const PatientApp({super.key, required this.languageCode});

  static PatientAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<PatientAppState>();

  @override
  State<PatientApp> createState() => PatientAppState();
}

class PatientAppState extends State<PatientApp> with WidgetsBindingObserver {
  late Locale _locale;

  String get currentLanguageCode => _locale.languageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locale = Locale(widget.languageCode);
    _setupAuthListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      PresenceService.stopHeartbeat();
      PresenceService.setOffline();
    } else if (state == AppLifecycleState.resumed) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && !session.isExpired) {
        PresenceService.startHeartbeat();
      }
    }
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      switch (event.event) {
        case AuthChangeEvent.signedIn:
          FcmService.onUserLogin(); // sync FCM token
          PresenceService.startHeartbeat();
          debugPrint('User signed in: ${event.session?.user.id}');
          break;
        case AuthChangeEvent.tokenRefreshed:
          debugPrint('Token refreshed');
          break;
        case AuthChangeEvent.signedOut:
          PresenceService.stopHeartbeat();
          PresenceService.setOffline();
          debugPrint('User signed out');
          break;
        default:
          break;
      }
    });
  }

  void changeLanguage(String code) async {
    setState(() {
      _locale = Locale(code);
    });

    Get.updateLocale(Locale(code));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", code);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ne')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
