import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/utils/push_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
    await _firestore.collection('chats').doc(chatRoomId).collection('messages').add({
      'senderId': _currentUser.uid,
      'text': "Call",
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    });

    PushNotification.sendNotification(
      recipientToken: recipientToken,
      message: "Call from $_recipientName",
      roomId: chatRoomId,
      title: _recipientName,
      recipientId: _recipientId,
      recipientName: _recipientName,
      type: "call"
    );
    messageController.clear();

  }
}
