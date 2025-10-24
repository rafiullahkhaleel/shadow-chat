import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/core/services/image_service.dart';
import 'package:shadow_chat/core/utils/utils.dart';


final currentUserDataProvider =
    StateNotifierProvider<CurrentUserDataNotifier, CurrentUserDataState>((ref) {
      return CurrentUserDataNotifier();
    });

class CurrentUserDataNotifier extends StateNotifier<CurrentUserDataState> {
  CurrentUserDataNotifier()
    : super(CurrentUserDataState(data: const AsyncValue.loading())) {
    fetchData();
  }
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final nameController = TextEditingController();
  final aboutController = TextEditingController();
  bool isUpdating = false;

  void setImage(ImageSource source,BuildContext context)async{
    final pickedImage = await ImageService().imagePicker(source);
    if (pickedImage != null) {
      state = state.copyWith(image: pickedImage);
      Navigator.pop(context);
    }
  }

  Future<void> fetchData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      state = CurrentUserDataState(data: AsyncValue.data(null));
    }
    final doc = await _firestore.collection('chatUsers').doc(uid).get();
    if (doc.exists) {
      final currentUser = UserModel.fromMap(doc.data()!);
      state = CurrentUserDataState(data: AsyncValue.data(currentUser));
      nameController.text = currentUser.name;
      aboutController.text = currentUser.about;
    } else {
      state = CurrentUserDataState(data: AsyncValue.data(null));
    }
    try {} catch (e, st) {
      state = CurrentUserDataState(data: AsyncValue.error(e, st));
    }
  }

  Future<void> updateData(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      isUpdating = true;
      state = CurrentUserDataState(data: AsyncValue.data(state.data.value));
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

////////////////////////////////

class CurrentUserDataState {
  final AsyncValue<UserModel?> data;
  final File? image;

  CurrentUserDataState({required this.data, this.image});
  CurrentUserDataState copyWith({AsyncValue<UserModel?>? data, File? image}) {
    return CurrentUserDataState(
      data: data ?? this.data,
      image: image ?? this.image,
    );
  }
}
