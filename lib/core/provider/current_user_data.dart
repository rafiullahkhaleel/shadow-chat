import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/core/utils/utils.dart';

final currentUserDataProvider =
    StateNotifierProvider<CurrentUserDataNotifier, AsyncValue<UserModel?>>((
      ref,
    ) {
      return CurrentUserDataNotifier();
    });

class CurrentUserDataNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  CurrentUserDataNotifier() : super(AsyncValue.loading()) {
    fetchData();
  }
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final nameController = TextEditingController();
  final aboutController = TextEditingController();
  bool isUpdating = false;

  Future<void> fetchData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      state = const AsyncValue.data(null);
    }
    final doc = await _firestore.collection('chatUsers').doc(uid).get();
    if (doc.exists) {
      final currentUser = UserModel.fromMap(doc.data()!);
      state = AsyncValue.data(currentUser);
      nameController.text = currentUser.name;
      aboutController.text = currentUser.about;
    } else {
      state = const AsyncValue.data(null);
    }
    try {} catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateData(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      isUpdating = true;
      state = AsyncValue.data(state.value);
      await _firestore.collection('chatUsers').doc(uid).update({
        'name': nameController.text.trim(),
        'about': aboutController.text.trim(),
      });
      await fetchData();
      Navigator.of(context).pop();
      SnackBarHelper.showSuccess(context, 'Profile updated successfully!');
    } catch (e) {
      SnackBarHelper.showError(context, 'Failed to update profile: $e');
      rethrow;
    } finally {
      isUpdating = false;
    }
  }


}
