import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PushNotification{
  PushNotification._();

  static Future<String> getAccessToken() async {
    // Load your service account credentials (replace with your actual file path)
    final jsonString = await rootBundle.loadString('assets/firebase-service-account.json');

    final credentials = ServiceAccountCredentials.fromJson(jsonString);


    const scope = 'https://www.googleapis.com/auth/firebase.messaging';

    final client = await clientViaServiceAccount(credentials, [scope]);

    final authHeaders = client.credentials.accessToken;

    return authHeaders.data; // return the token data
  }

  static Future<void> sendNotification({
    required String recipientToken,
    required String message,
    required String roomId,
    required String recipientName,
    required String recipientId,
    String? title,
    String type = "message",
}) async {
    final accessToken = await getAccessToken();
    if (accessToken.isEmpty) {
      print("Failed to retrieve access token");
      return;
    }

    // Firebase project ID
    const String projectId = 'doctor-app-3f4bb';
    final String url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "message": {
          "token": recipientToken,
          "notification": {
            "title": title ?? "New Message",
            "body": message,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "type": type,
            "roomId": roomId,
            "recipientId": recipientId,
            "recipientName": recipientName,
            "token": recipientToken,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}