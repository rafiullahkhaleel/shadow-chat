import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/provider/auth/notification_provider.dart';
import 'package:shadow_chat/core/provider/current_user_data.dart';
import 'package:shadow_chat/view/screens/auth/login_screen.dart';
import 'package:shadow_chat/view/screens/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    ref.read(currentUserDataProvider);
    ref.read(notificationProvider.notifier).initToken();
    Future.delayed(Duration(seconds: 3), () {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset('assets/app_icon.png'),
            Text(
              'WELCOME  💖',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
