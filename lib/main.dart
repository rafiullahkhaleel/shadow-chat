import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/contants/constants.dart';
import 'package:shadow_chat/screens/auth/home_screen.dart';
import 'package:shadow_chat/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
      home: const LoginScreen(),
    ));
  }
}
