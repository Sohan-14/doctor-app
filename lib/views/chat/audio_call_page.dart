import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:doctor_app/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "004e78b9715c4733b1541590b261c7a8";
const token = "007eJxTYFC9MGffLNdHd5/nt+Q0FV/s9N3x1vHQg6e7l5Q/9k+d3CqtwGBgYJJqbpFkaW5ommxibmycZGhqYmhqaZBkZGaYbJ5oIfFJIKMhkJHBdMYxJkYGCATxeRkS0/OLEuPTckpLSlKLGBgAaZolJQ==";
const channel = "agora_flutter";

class AudioCallPage extends StatefulWidget {
  final String roomId;
  final String callId;
  const AudioCallPage({super.key, required this.roomId, required this.callId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  final ChatController chatController = Get.put(ChatController());

  int? _remoteUid;
  bool _muted = false;
  bool _speakerOn = true;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
    chatController.observeCall(callId: widget.callId, chatRoomId: widget.roomId, context: context);
  }

  Future<void> initAgora() async {
    await Permission.microphone.request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          chatController.handleCallAction(callId: widget.callId, chatRoomId: widget.roomId, callAction: 'end');
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    chatController.handleCallAction(callId: widget.callId, chatRoomId: widget.roomId, callAction: 'end');
    await _engine.leaveChannel();
    await _engine.release();
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _engine.muteLocalAudioStream(_muted);
  }

  void _toggleSpeaker() {
    setState(() => _speakerOn = !_speakerOn);
    _engine.setEnableSpeakerphone(_speakerOn);
  }

  void _endCall() {
    chatController.handleCallAction(callId: widget.callId, chatRoomId: widget.roomId, callAction: 'end');
    Get.back();
    if (Get.currentRoute == "/home") {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_in_talk, color: Colors.white, size: 100),
                  const SizedBox(height: 20),
                  Text(
                    _remoteUid != null ? "Connected" : "Calling...",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    color: _muted ? Colors.red : Colors.white,
                    onTap: _toggleMute,
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    onTap: _endCall,
                  ),
                  _buildControlButton(
                    icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
                    color: _speakerOn ? Colors.white : Colors.grey,
                    onTap: _toggleSpeaker,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey.shade800,
      child: IconButton(
        icon: Icon(icon, color: color, size: 28),
        onPressed: onTap,
      ),
    );
  }
}
