import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:doctor_app/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "004e78b9715c4733b1541590b261c7a8";
const token = "007eJxTYLjluc7RSFfo17r5jsG/Vc7erjBpPtHQUtnYFX3zuu6NfdkKDAYGJqnmFkmW5oamySbmxsZJhqYmhqaWBklGZobJ5okWYsv/pDcEMjJ8rp/AxMgAgSA+L0Nien5RYnxaTmlJSWoRAwMAxJ0kMw==";
const channel = "agora_flutter";

class CallPage extends StatefulWidget {
  final String roomId;
  final String callId;
  const CallPage({super.key, required this.roomId, required this.callId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final ChatController chatController = Get.put(ChatController());

  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  bool _speakerOn = true;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
    print("init observeCall");
    chatController.observeCall(callId: widget.callId, chatRoomId: widget.roomId, context: context);
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          chatController.handleCallAction(callId: widget.callId, chatRoomId: widget.roomId, callAction: 'end');
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
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

  void _switchCamera() {
    _engine.switchCamera();
  }

  void _endCall() {
    chatController.handleCallAction(callId: widget.callId, chatRoomId: widget.roomId, callAction: 'end');
    print("the current state before is ${Get.currentRoute}");
    Get.back();
    if(Get.currentRoute == "/home"){
      SystemNavigator.pop();
    }
    print("the current state after is ${Get.currentRoute}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Positioned(
            top: 40,
            left: 20,
            child: SizedBox(
              width: 120,
              height: 160,
              child: _localUserJoined
                  ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              )
                  : const Center(child: CircularProgressIndicator()),
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
                  icon: Icons.cameraswitch,
                  color: Colors.white,
                  onTap: _switchCamera,
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

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Waiting for remote user to join...',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      );
    }
  }
}
