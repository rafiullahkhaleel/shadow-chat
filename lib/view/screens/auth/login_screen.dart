import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';

import '../../../core/provider/animation_provider.dart';
import '../../../core/provider/auth/auth_provider.dart';

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
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
                fixedSize: Size(context.width * .8, context.height * .065),
              ),
              onPressed:
                  isLoading
                      ? null // Disable button during loading
                      : () {
                        ref
                            .read(authProvider.notifier)
                            .signInWithGoogle(context);
                      },
              label:
                  isLoading
                      ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                      : const Text(
                        'Sign In with Google',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              icon:
                  isLoading
                      ? const SizedBox()
                      : Padding(
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
