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
    fetchLastMessage(receiverId);
    initFocusListener();
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
        'docsId': docRef.id,
        'fromId': currentUser.uid,
        'msg': text,
        'send': FieldValue.serverTimestamp(),
        'type': 'text',
      });
      messageController.clear();
    } catch (e) {
      debugPrint('ERROR OCCURRED$e');
    }
  }

  Future<void> updateMessageStatus(MessageModel message) async {
    _firestore
        .collection('chat/${getConversationId(message.fromId)}/messages')
        .doc(message.docsId)
        .update({'read': FieldValue.serverTimestamp()});
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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _lastMessageSubscription;
  Future<void> fetchLastMessage(String fromId) async {
    await _lastMessageSubscription?.cancel();
    _lastMessageSubscription = _firestore
        .collection('chat/${getConversationId(fromId)}/messages')
        .orderBy('send', descending: true)
        .limit(1)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final lastMessage = MessageModel.fromMap(
                snapshot.docs.first.data(),
              );
              state = state.copyWith(lastMessage: AsyncValue.data(lastMessage));
            }
          },
          onError: (error, stack) {
            state = state.copyWith(lastMessage: AsyncValue.error(error, stack));
          },
        );
  }

  final FocusNode focusNode = FocusNode();

  void initFocusListener() {
    focusNode.addListener(() {
      if (focusNode.hasFocus && state.showEmoji) {
        state = state.copyWith(showEmoji: false);
      }
    });
  }

  void toggleEmoji(BuildContext context) async {
    if (!state.showEmoji) {
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      FocusScope.of(context).requestFocus(focusNode);
    }
    state = state.copyWith(showEmoji: !state.showEmoji);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    messageController.dispose();
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

class MessagesState {
  final AsyncValue<List<MessageModel>> data;
  final AsyncValue<MessageModel>? lastMessage;
  final bool showEmoji;

  MessagesState({required this.data, this.lastMessage, this.showEmoji = false});

  MessagesState copyWith({
    AsyncValue<List<MessageModel>>? data,
    AsyncValue<MessageModel>? lastMessage,
    bool? showEmoji,
  }) {
    return MessagesState(
      data: data ?? this.data,
      lastMessage: lastMessage ?? this.lastMessage,
      showEmoji: showEmoji ?? this.showEmoji,
    );
  }
}
