import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shadow_chat/utils/utils.dart';
import 'package:shadow_chat/view/screens/home_screen.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthNotifier() : super(FirebaseAuth.instance.currentUser);

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
     // await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return; // User cancelled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      var user = userCredential.user;
      state = user;
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
            'pushToken': '',
          });
        } else {
          await userDoc.update({
            'name': user.displayName,
            'email': user.email,
            'image': user.photoURL,
          });
        }
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      SnackBarHelper.showError(
        context,
        'Something went wrong (Check Internet!',
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    state = null;
  }
}
