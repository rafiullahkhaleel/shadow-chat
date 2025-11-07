import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';

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
}
