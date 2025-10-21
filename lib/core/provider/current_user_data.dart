import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/model/user_model.dart';

final currentUserDataProvider = FutureProvider<UserModel?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  final doc =
      await FirebaseFirestore.instance.collection('chatUsers').doc(uid).get();
  if (doc.exists) {
    return UserModel.fromMap(doc.data()!);
  } else {
    return null;
  }
});
