import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/utils/push_notification.dart';
import 'package:doctor_app/views/chat/call_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String chatRoomId;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final TextEditingController messageController = TextEditingController();
  RxBool isLoading = false.obs;
  late User _currentUser;
  late String _recipientId;
  late String _recipientName;

  @override
  void onInit() {
    super.onInit();
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  void setChatRoom(String recipientId, String recipientName) {
    _recipientId = recipientId;
    _recipientName = recipientName;
    chatRoomId = generateChatId(_currentUser.uid, recipientId);
    fetchMessages();
  }

  String generateChatId(String senderId, String receiverId) {
    List<String> users = [senderId, receiverId];
    users.sort();
    return '${users[0]}_${users[1]}';
  }




  void fetchMessages() {
    print("room : $chatRoomId");
    isLoading.value = true;
    _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      var fetchedMessages = snapshot.docs
          .map((doc) => {
        'text': doc['text'],
        'senderId': doc['senderId'],
        'timestamp': doc['timestamp'],
      })
          .toList();
      isLoading.value = false;
      messages.value = fetchedMessages;

    });
  }



  Future<void> sendMessage(String recipientToken) async {
    if (messageController.text.isEmpty) return;

    await _firestore.collection('chats').doc(chatRoomId).collection('messages').add({
      'senderId': _currentUser.uid,
      'text': messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text', // You can use other types like 'image', etc.
    });

    PushNotification.sendNotification(
        recipientToken: recipientToken,
        message: messageController.text,
        roomId: chatRoomId,
        title: _recipientName,
        recipientId: _recipientId,
        recipientName: _recipientName,
    );
    messageController.clear();
  }


  Future<void> sendCall(String recipientToken) async {
    final docRef = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('calls')
        .doc();

    await docRef.set({
      'callId': docRef.id,
      'senderId': _currentUser.uid,
      'recipientId': _recipientId,
      'callAction': "calling",
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("callId : callId : ${docRef.id}");

    PushNotification.sendNotification(
      recipientToken: recipientToken,
      message: "Call from $_recipientName",
      roomId: chatRoomId,
      callId: docRef.id,
      title: _recipientName,
      recipientId: _recipientId,
      recipientName: _recipientName,
      type: "call"
    );

    messageController.clear();

    Get.to(
      CallPage(
        roomId: chatRoomId,
        callId: docRef.id,
      ),
    );
  }

  Future<void> handleCallAction({
    required String callId,
    required String chatRoomId,
    String callAction = "decline",
  }) async{
    await _firestore.collection('chats').doc(chatRoomId).collection('calls').doc(callId).update({
      'callAction': callAction,
    });
  }


  StreamSubscription<DocumentSnapshot>? _callSubscription;

  Future<void> observeCall({
    required String callId,
    required String chatRoomId,
    required BuildContext context,
  }) async{
    print("call observeCall");

    _callSubscription = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {

        final Map<String, dynamic>?  data = snapshot.data();

        if (data != null && data['callAction'] == 'decline') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("The user declined the call.")),
          );
          Navigator.of(context).pop();

          if(Get.currentRoute == "/IncomingCallPage"){
            Get.back();
          }
          _callSubscription?.cancel();
        }

        else if (data != null && data['callAction'] == 'end') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("The video call end")),
          );
          Navigator.of(context).pop();
          if(Get.currentRoute == "/IncomingCallPage"){
            Get.back();
          }
          _callSubscription?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _callSubscription?.cancel();
  }

  @override
  void onClose() {
    super.onClose();
    _callSubscription?.cancel();
  }

}
