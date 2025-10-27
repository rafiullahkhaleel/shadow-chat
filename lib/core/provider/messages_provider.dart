import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shadow_chat/core/model/message_model.dart';

final messagesProvider =
    StateNotifierProvider.family<MessagesNotifier, MessagesState, String>((
      ref,
      receiverId,
    ) {
      return MessagesNotifier(receiverId);
    });

class MessagesNotifier extends StateNotifier<MessagesState> {
  final String receiverId;
  MessagesNotifier(this.receiverId)
    : super(MessagesState(data: AsyncValue.loading())) {
    fetchMessages(receiverId);
  }
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _firestore = FirebaseFirestore.instance;

  TextEditingController messageController = TextEditingController();
  String getConversationId(String id) {
    return currentUser.uid.hashCode <= id.hashCode
        ? '${currentUser.uid}_$id'
        : '${id}_${currentUser.uid}';
  }

  Future<void> sendMessage(String id) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    try {
      DocumentReference docRef =
          _firestore.collection('chat/${getConversationId(id)}/messages').doc();
      await docRef.set({
        'toId': id,
        'docsId' : docRef.id,
        'fromId': currentUser.uid,
        'msg': text,
        'read': '',
        'send': FieldValue.serverTimestamp(),
        'type': 'text',
      });
      messageController.clear();
    } catch (e) {
      debugPrint('ERROR OCCURRED$e');
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _messagesSubscription;
  Future<void> fetchMessages(String id) async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('chat/${getConversationId(id)}/messages')
        .orderBy('send', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isEmpty) {
              state = state.copyWith(data: AsyncValue.data([]));
            } else {
              final messages =
                  snapshot.docs.map((doc) {
                    return MessageModel.fromMap(doc.data());
                  }).toList();
              state = state.copyWith(data: AsyncValue.data(messages));
            }
          },
          onError: (error, stack) {
            state = state.copyWith(data: AsyncValue.error(error, stack));
          },
        );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    messageController.dispose();
    super.dispose();
  }
}

class MessagesState {
  final AsyncValue<List<MessageModel>> data;

  MessagesState({required this.data});

  MessagesState copyWith({AsyncValue<List<MessageModel>>? data}) {
    return MessagesState(data: data ?? this.data);
  }
}
