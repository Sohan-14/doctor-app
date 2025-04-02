import 'package:doctor_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final AuthController authController = Get.put(AuthController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
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
                await authController.signUp(emailController.text, passwordController.text, nameController.text);
              },
              child: Text('Sign Up'),
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
              onPressed: () => Get.toNamed('/signin'), // Navigate to Sign In
              child: Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
