import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen for changes in the user's authentication state
  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Firebase auth state listener
    _auth.authStateChanges().listen((user) {
      this.user.value = user;
      if (user != null) {
        // Ensure we're not navigating to a null or invalid route
        if (Get.currentRoute != '/home') {
          Get.offNamed('/home'); // Navigate to Home when logged in
        }
      } else {
        // Ensure you're not navigating to a null or invalid route
        if (Get.currentRoute != '/signin') {
          Get.offNamed('/signin'); // Navigate to Sign In when logged out
        }
      }
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      // Create user using Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Get the current user
      User? user = userCredential.user;

      // Get FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'userId': user.uid,
          'email': email,
          'created_at': Timestamp.now(),
          'fcm_token': fcmToken, // Store the FCM token
        });

        // Navigate to the Home page or wherever you need
        Get.offNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Auth", "Error during sign-up : ${e.message}", backgroundColor: Colors.redAccent);
      print('Error during sign-up: ${e.message}');
    }
  }

  // Sign-in method
  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Get the current user
      User? user = userCredential.user;


      // Get the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (user != null) {
        // Update Firestore with FCM token after sign-in (use this in case the token changes)
        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcm_token': fcmToken, // Update the FCM token
        });

        // Navigate to the Home page or wherever you need
        Get.offNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Auth", "Error during sign-in: ${e.message}", backgroundColor: Colors.redAccent);
      print('Error during sign-in: ${e.message}');
    }
  }

  // Sign-out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  User? get currentUser => _auth.currentUser;
}
