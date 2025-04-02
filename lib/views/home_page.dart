import 'package:doctor_app/controllers/home_controller.dart';
import 'package:doctor_app/views/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final HomeController userController = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.offNamed('/signin');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: currentUser != null
                ? Text('Welcome, ${currentUser.email}')
                : Text('You are not logged in.'),
          ),
          const SizedBox(height: 32),
          Obx(() {
            if (userController.users.isEmpty) {
              return Center(child: CircularProgressIndicator());
            } else {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: userController.users.length,
                itemBuilder: (context, index) {
                  UserModel user = userController.users[index];
                  if(user.email == currentUser?.email){
                    return SizedBox();
                  }
                  else{
                    return ListTile(
                      leading: Icon(Icons.person, size: 32,),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      onTap: (){
                        Get.to(
                          ChatScreen(
                            recipientId: user.userId,
                            recipientName: user.name,
                            recipientToken: user.fcmToken,
                          ),
                        );
                      },
                    );
                  }
                },
              );
            }
          }),
        ],
      ),
    );
  }
}
