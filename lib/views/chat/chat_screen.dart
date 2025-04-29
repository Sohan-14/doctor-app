import 'package:doctor_app/controllers/chat_controller.dart';
import 'package:doctor_app/views/chat/call_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String recipientToken;

  const ChatScreen({super.key, required this.recipientId, required this.recipientName, required this.recipientToken});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.put(ChatController());
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    chatController.setChatRoom(widget.recipientId, widget.recipientName);
    chatController.fetchMessages();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.person, size: 32,),
            Text(widget.recipientName)
          ],
        ),

        actions: [
          IconButton(
            onPressed: (){
              chatController.sendAudioCall(widget.recipientToken);
            },
            icon: Icon(Icons.call, size: 32,),
          ),
          SizedBox(width: 12,),

          IconButton(
            onPressed: (){
              chatController.sendCall(widget.recipientToken);
            },
            icon: Icon(Icons.video_call, size: 32,),
          ),
          SizedBox(width: 12,)
        ],

      ),


      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: Obx(() {
              if (chatController.messages.isEmpty) {
                return Center(child: Text('No Message'));
              }
              else if(chatController.isLoading.value){
                return Center(child: CircularProgressIndicator(),);
              }
              else {
                return ListView.builder(
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    var message = chatController.messages[index];
                    return ListTile(
                      title: Text(
                        message['text'],

                        style: TextStyle(
                          // color: message['senderId'] == currentUser?.uid ? Colors.white : Colors.black
                        ),
                        textAlign: message['senderId'] == currentUser?.uid ? TextAlign.end : TextAlign.start,
                      ),
                      // subtitle: Text('Sent by: ${message['senderId']}', textAlign: message['senderId'] == currentUser?.uid ? TextAlign.end : TextAlign.start,),
                    );
                  },
                );
              }
            }),
          ),


          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    chatController.sendMessage(widget.recipientToken);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
