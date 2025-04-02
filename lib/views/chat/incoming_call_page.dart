import 'package:doctor_app/views/chat/call_page.dart' show CallPage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomingCallPage extends StatelessWidget {
  const IncomingCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
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
                    Get.off(CallPage(roomId: args['roomId']));
                  },
                ),
                FloatingActionButton(
                  heroTag: "decline",
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                  onPressed: () {
                    Get.back();
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
