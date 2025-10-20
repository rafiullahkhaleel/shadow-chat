import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';
import 'package:shadow_chat/view/screens/home_screen.dart';
import 'package:shadow_chat/view/screens/splash_screen.dart';

import 'core/contants/constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          )
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
