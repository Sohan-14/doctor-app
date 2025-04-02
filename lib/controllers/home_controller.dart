import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxList<UserModel> users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
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
