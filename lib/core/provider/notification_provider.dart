import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, String?>((ref) {
      return NotificationNotifier();
    });

class NotificationNotifier extends StateNotifier<String?> {
  NotificationNotifier() : super(null);
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initToken() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      String? token = await _messaging.getToken();
      state = token;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (token != null && userId != null) {
        await FirebaseFirestore.instance
            .collection('chatUsers')
            .doc(userId)
            .update({'fcmToken': token});
      }
      _messaging.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('chatUsers')
            .doc(userId)
            .update({'fcmToken': newToken});
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<AccessCredentials> _getAccessToken() async {
    final serviceAccountPath = dotenv.env['PATH_TO_SECRET'];
    debugPrint('✅ Service account path: $serviceAccountPath');
    String serviceAccountJson = await rootBundle.loadString(
      serviceAccountPath!,
    );
    final serviceAccount = ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(serviceAccount, scopes);
    return client.credentials;
  }

  Future<bool> sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (deviceToken.isEmpty) {
      debugPrint('❌ Device token is empty!');
      return false;
    }
    final credentials = await _getAccessToken();
    final accessToken = credentials.accessToken.data;
    final projectId = dotenv.env['PROJECT_ID'];
    debugPrint('Access Token: $accessToken');
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'
      ,
    );
    final message = {
      'message': {
        'token': deviceToken,
        'notification': {'title': title, 'body': body},
        'data': data ?? {},
      },
    };
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      debugPrint('Notification sent successfully');
      return true;
    } else {
      debugPrint('Failed to send notification: ${response.body}');
      return false;
    }
  }
}
