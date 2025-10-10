import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset('assets/app_icon.png'),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white60,
                fixedSize: Size(width * .8, height * .1),
              ),
              onPressed: () {},
              label: Text(
                'Sign In with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/google.jpg', height: height * .08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
