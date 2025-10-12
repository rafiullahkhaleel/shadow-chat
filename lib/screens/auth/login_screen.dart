import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    ref.read(loginAnimationProvider).initAnimation(this);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(loginAnimationProvider);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AlignTransition(
              alignment: provider.animation,
              child: Image.asset('assets/app_icon.png'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade200,
                fixedSize: Size(width * .8, height * .065),
              ),
              onPressed: () {},
              label: const Text(
                'Sign In with Google',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('assets/google.png', height: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
