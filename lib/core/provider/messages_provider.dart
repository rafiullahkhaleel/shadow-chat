import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shadow_chat/core/model/message_model.dart';

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier()
    : super(
        MessagesState(
          data: AsyncValue.data([
            MessageModel(
              fromId: FirebaseAuth.instance.currentUser!.uid,
              toId: 'xyz',
              msg: 'Hello',
              sent: 'How are you',
              read: '12:00 PM',
              type: MessageType.text,
            ),
            MessageModel(
              fromId: 'xyz',
              toId: FirebaseAuth.instance.currentUser!.uid,
              msg: 'How are you?',
              sent: 'How are you',
              read: '12:00 PM',
              type: MessageType.text,
            ),
          ]),
        ),
      );
}

class MessagesState {
  final AsyncValue<List<MessageModel>> data;

  MessagesState({required this.data});

  MessagesState copyWith({AsyncValue<List<MessageModel>>? data}) {
    return MessagesState(data: data ?? this.data);
  }
}
