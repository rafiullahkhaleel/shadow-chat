import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shadow_chat/core/model/message_model.dart';

final messagesProvider = StateNotifierProvider<MessagesNotifier,MessagesState>((ref){
  return MessagesNotifier();
});

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier()
    : super(
        MessagesState(
          data: AsyncValue.data([
            MessageModel(
              fromId: FirebaseAuth.instance.currentUser!.uid,
              toId: 'xyz',
              msg: 'Hello',
              sent: '${DateTime.now().millisecondsSinceEpoch}',
              read: '${DateTime.now().millisecondsSinceEpoch}',
              type: MessageType.text,
            ),
            MessageModel(
              fromId: 'xyz',
              toId: FirebaseAuth.instance.currentUser!.uid,
              msg: 'How are you?',
              sent: '${DateTime.now().millisecondsSinceEpoch}',
              read: '${DateTime.now().millisecondsSinceEpoch}',
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
