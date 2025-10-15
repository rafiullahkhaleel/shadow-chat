import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/contants/constants.dart';
import 'package:shadow_chat/view/screens/home_screen.dart';
import 'package:shadow_chat/view/screens/splash_screen.dart';

import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: MaterialApp(
      title: 'Shadow Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        appBarTheme: AppBarTheme(color: AppColors.mainColor, centerTitle: true,
            iconTheme: IconThemeData(
                color: Colors.white,
                size: 30
            ),
            titleTextStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 22,letterSpacing: 1.5
            ),
            foregroundColor: Colors.white

        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    ));
  }
}
