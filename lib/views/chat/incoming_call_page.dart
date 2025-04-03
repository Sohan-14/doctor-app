// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:doctor_app/controllers/chat_controller.dart';
import 'package:doctor_app/views/chat/call_page.dart' show CallPage;
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

class IncomingCallPage extends StatefulWidget {
  const IncomingCallPage({super.key});

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage> {
  // final AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();


  @override
  void initState() {
    super.initState();
    _playRingtone();
  }
  void _playRingtone() async {
    print("_playRingtone");
    FlutterRingtonePlayer().play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.electronic,
      fromAsset: "assets/call_ringtone.mp3",
      looping: true,
      volume: 1.0,
      asAlarm: false,
    );
  }

  void _stopRingtone() async {
    FlutterRingtonePlayer().stop();

  }

  @override
  void dispose() {
    _stopRingtone();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    final args = Get.arguments;
    chatController.observeCall(callId: args['callId'], chatRoomId: args['roomId'], context: context);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${args['callerName']} is calling...",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "accept",
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.call),
                  onPressed: () {
                    chatController.handleCallAction(callId: args['callId'], chatRoomId: args['roomId'], callAction: 'accept');
                    _stopRingtone();
                    Get.to(CallPage(roomId: args['roomId'], callId: args['callId'],));

                  },
                ),
                FloatingActionButton(
                  heroTag: "decline",
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                  onPressed: () {
                    chatController.handleCallAction(callId: args['callId'], chatRoomId: args['roomId'], callAction: 'decline');
                    _stopRingtone();
                    // Navigator.of(context).pop();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
