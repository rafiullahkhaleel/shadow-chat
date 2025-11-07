import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shadow_chat/core/provider/auth/auth_state.dart';
import 'package:shadow_chat/core/provider/auth/notification_provider.dart';
import 'package:shadow_chat/core/provider/current_user_data.dart';
import 'package:shadow_chat/core/provider/users_data_provider.dart';
import 'package:shadow_chat/view/screens/home_screen.dart';

import '../../../view/screens/auth/login_screen.dart';
import '../../utils/utils.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Ref ref;
  AuthNotifier(this.ref) : super(AuthState(user: FirebaseAuth.instance.currentUser));

  Future<void> signInWithGoogle(BuildContext context) async {
    state = state.copyWith(isLoading: true);
    try {
      // await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      } // User cancelled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      state = state.copyWith(user: user);
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('chatUsers')
            .doc(user.uid);
        final docSnap = await userDoc.get();
        if (!docSnap.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName,
            'email': user.email,
            'image': user.photoURL,
            'about': 'Available',
            'createdAt': FieldValue.serverTimestamp(),
            'isOnline': true,
            'lastActive': FieldValue.serverTimestamp(),
          });
        } else {
          await userDoc.update({
            'name': user.displayName,
            'email': user.email,
            'image': user.photoURL,
            'about': '2nd Available',
          });
        }
      }
      state = state.copyWith(isLoading: false);
      final container = ProviderScope.containerOf(context, listen: false);
      container.refresh(currentUserDataProvider);
     await container.read(notificationProvider.notifier).initToken();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      SnackBarHelper.showError(
        context,
        'Something went wrong (Check Internet!',
      );
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true);
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      ref.invalidate(currentUserDataProvider);
      ref.invalidate(userDataProvider);
      state = AuthState(user: null, isLoading: false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      SnackBarHelper.showError(context, 'Logout failed!');
      state = state.copyWith(isLoading: false);
    }
  }
}
