import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/views/chat/call_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  RxList<UserModel> users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> getStoredCallData() async {
    final prefs = await SharedPreferences.getInstance();
    final roomId = prefs.getString('call_room_id');
    final callId = prefs.getString('call_call_id');

    await prefs.remove('call_room_id');
    await prefs.remove('call_call_id');

    print("call_room_id $roomId");


    if(roomId != null && callId != null){
      Get.to(() => CallPage(roomId: roomId, callId: callId));
    }
  }

  Future<void> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      List<UserModel> fetchedUsers = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      users.value = fetchedUsers; // Update the reactive list
    } catch (e) {
      print("Error fetching users: $e");
    }
  }
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final Timestamp createdAt;
  final String fcmToken;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      name: data['name'],
      email: data['email'],
      userId: data['userId'],
      createdAt: data['created_at'],
      fcmToken: data['fcm_token'],
    );
  }
}
