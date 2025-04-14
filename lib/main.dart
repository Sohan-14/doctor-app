import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/bindings/app_bindings.dart';
import 'package:doctor_app/views/auth/signin_page.dart';
import 'package:doctor_app/views/auth/signup_page.dart';
import 'package:doctor_app/views/chat/call_page.dart';
import 'package:doctor_app/views/chat/incoming_call_page.dart';
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
        'callId': message.data['callId'],
        'callerId': message.data['recipientId'],
        'callerName': message.data['recipientName'],
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


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'call') {
      print("callId : ${message.data['callId']}");
      Get.to(() => IncomingCallPage(), arguments: {
        "callerName": message.data['recipientName'],
        "roomId": message.data['roomId'],
        "callId": message.data['callId'],
      });
    }
    else{
      FlutterLocalNotificationsPlugin().show(
        0,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new message',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel_id',
            'Default Channel',
            channelDescription: 'Channel for general notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
          ),
        ),
      );
    }
  });


  runApp(MyApp());

  FlutterCallkitIncoming.onEvent.listen((event) async {
    print("🚀 Deley number event");
    Get.snackbar("🚀 Deley number e ", "Deley number e");
    switch (event?.event) {
      case Event.actionCallAccept:
        final roomId = event?.body['extra']['roomId'];
        final callId = event?.body['extra']['callId'];
        final callerName = event?.body['extra']['callerName'];
        print("🚀 Deley number Call accepted: roomId = $roomId, callId = $callId");

        if (roomId != null && callId != null) {
          _navigateToCallPageWhenReady(roomId, callId);
        }
        break;
      case Event.actionCallDecline:
        final roomId = event?.body['extra']['roomId'];
        final callId = event?.body['extra']['callId'];
        if (roomId != null && callId != null) {
          handleCallAction(callId: callId, chatRoomId: roomId);
        }
        break;
      default:
        print("🚀 Deley number  ${event?.event}");
    }
  });
}

void _navigateToCallPageWhenReady(String roomId, String callId) async {
  bool navigated = false;

  for (int i = 0; i < 30; i++) {
    print("🚀 Deley number ${i}");
    await Future.delayed(Duration(milliseconds: 5000));
    print("🚀 Deley number next ${i}");
    if (Get.context != null) {
      print("🚀 Deley number if ${i}");
      Get.snackbar("🚀 Deley number if ", "Deley number ${i}");
      Get.to(() => CallPage(roomId: roomId, callId: callId));
      navigated = true;
      break;
    } else {
      print("🚀 Deley number else ${i}");
      print("⏳ Waiting for context to be ready... ($i)");
    }
  }

  if (!navigated) {
    print("❌ Failed to navigate: context not ready after 3 seconds");
  }
}



Future<void> handleCallAction({
  required String callId,
  required String chatRoomId,
  String callAction = "decline",
}) async{
  await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).collection('calls').doc(callId).update({
    'callAction': callAction,
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("🚀 Deley number app oppeinng");
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
