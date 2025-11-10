import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';
import 'package:shadow_chat/core/services/online_status_handler.dart';
import 'package:shadow_chat/view/screens/splash_screen.dart';

import 'core/contants/constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await _setupNotificationChannel();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(OnlineStatusHandler(child: const MyApp()));
}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Shadow Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          appBarTheme: AppBarTheme(
            color: AppColors.mainColor,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white, size: 30),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 22,
              letterSpacing: 1.5,
            ),
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: context.width * 0.05,
                vertical: context.height * 0.015,
              ),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(foregroundColor: AppColors.mainColor),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

Future<void> _setupNotificationChannel() async {
  try {
    final result = await FlutterNotificationChannel().registerNotificationChannel(
      id: 'chats',
      name: 'Chats',
      description: 'For showing Message Notification',
      importance: NotificationImportance.IMPORTANCE_HIGH,
    );

    debugPrint('✅ Notification Channel Registered Successfully: $result');
  } catch (e) {
    debugPrint('❌ Failed to register notification channel: $e');
  }
}

