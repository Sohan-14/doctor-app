import 'package:doctor_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});
  final AuthController authController = Get.put(AuthController());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            Obx(() => authController.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                await authController.signIn(
                    emailController.text, passwordController.text);
                if (authController.currentUser != null) {
                  Get.offNamed('/home'); // Redirect to home page
                }
              },
              child: Text('Sign In'),
            )),
            SizedBox(height: 20),
            Obx(() => authController.errorMessage.isNotEmpty
                ? Text(
              authController.errorMessage.value,
              style: TextStyle(color: Colors.red),
            )
                : Container()),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.toNamed('/signup'), // Navigate to Sign Up
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
