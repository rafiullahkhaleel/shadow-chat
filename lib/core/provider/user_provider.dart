import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user_model.dart';


final userProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance.collection('chatUsers').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  });
});
