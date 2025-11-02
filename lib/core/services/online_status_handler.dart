import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnlineStatusHandler extends StatefulWidget {
  final Widget child;
  const OnlineStatusHandler({super.key, required this.child});

  @override
  State<OnlineStatusHandler> createState() => _OnlineStatusHandlerState();
}

class _OnlineStatusHandlerState extends State<OnlineStatusHandler>
    with WidgetsBindingObserver {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setStatus(true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userId == null) return;

    print('🔄 App State Changed: $state');

    if (state == AppLifecycleState.resumed) {
      print('✅ App resumed → User is online');
      _setStatus(true);
    } else if (state == AppLifecycleState.paused) {
      print('🟠 App paused → User is offline');
      _setStatus(false);
    } else if (state == AppLifecycleState.inactive) {
      print('⚪ App inactive (maybe call/notification)');
      _setStatus(false);
    } else if (state == AppLifecycleState.detached) {
      print('🔴 App detached → closing');
      _setStatus(false);
    }
  }

  Future<void> _setStatus(bool isOnline) async {
    await FirebaseFirestore.instance.collection('chatUsers').doc(userId).update(
      {'isOnline': isOnline, 'lastActive': FieldValue.serverTimestamp()},
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
