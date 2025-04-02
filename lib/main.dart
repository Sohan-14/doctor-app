import 'package:doctor_app/bindings/app_bindings.dart';
import 'package:doctor_app/views/auth/signin_page.dart';
import 'package:doctor_app/views/auth/signup_page.dart';
import 'package:doctor_app/views/chat/call_page.dart';
import 'package:doctor_app/views/home_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';


@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'call') {
    await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameCaller: message.data['recipientName'],
      appName: 'Doctor App',
      handle: 'Video Call',
      type: 2, // 1 = audio, 2 = video
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: {
        'roomId': message.data['roomId'],
        'callerId': message.data['recipientId'],
      },
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      android: const AndroidParams(
          isCustomNotification: false,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          actionColor: '#4CAF50',
          isImportant: true,
          textColor: '#ffffff',
          isShowFullLockedScreen: true,
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call",
          isShowCallID: false
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    ));
  }
  print("Handling background message id : ${message.messageId}");
  print("Handling background message title : ${message.notification?.title}");

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitSettings,
  );
  FlutterLocalNotificationsPlugin().initialize(initSettings);

  FlutterCallkitIncoming.onEvent.listen((event) {
    print("event of call event: $event");
    switch (event?.event) {
      case Event.actionCallAccept:
        final roomId = event?.body['extra']['roomId'];
        if (roomId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed('/home');
            Get.to(() => CallPage(roomId: roomId));
          });
        }
        print("Event.actionCallAccept");
        break;
      case Event.actionCallDecline:
        print("Event.actionCallDecline");
        break;
      default:
        print("Event:Ohters");
    }
  });


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'call') {
      FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nameCaller: message.data['recipientName'],
        appName: 'Doctor App',
        handle: 'Video Call',
        type: 2,
        duration: 30000,
        extra: {
          'roomId': message.data['roomId'],
          'callerId': message.data['callerId'],
        },
        android: AndroidParams(
          isCustomNotification: false,
          isShowFullLockedScreen: true,
          backgroundColor: '#0955fa',
          isImportant: true,
          ringtonePath: 'system_ringtone_default',
          incomingCallNotificationChannelName: "Incoming Call",
          missedCallNotificationChannelName: "Missed Call",
          isShowLogo: false,
        ),
        ios: IOSParams(
          supportsVideo: true,
          ringtonePath: 'system_ringtone_default',
          audioSessionMode: 'default',
          handleType: 'generic',

        ),
      ));
    }
  });


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Firebase Auth',
      initialRoute: '/signin',
      initialBinding: AppBindings(),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/signin', page: () => SignInPage()),
        GetPage(name: '/signup', page: () => SignUpPage()),
        GetPage(name: '/home', page: () => HomePage()),
        // Add home page route here
      ],
    );
  }
}
