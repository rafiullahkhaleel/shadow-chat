import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadow_chat/core/model/message_model.dart';
import 'package:shadow_chat/core/services/image_service.dart';

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
        'type': MessageType.text.name,
      });
      messageController.clear();
    } catch (e) {
      debugPrint('ERROR OCCURRED$e');
    }
  }

  Future<void> sendImage(ImageSource source) async {
    final pickedImage = await ImageService().imagePicker(source);
    if (pickedImage == null) return;

    // Generate temporary ID for the message
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // Create temporary message with local image path
    final tempMessage = MessageModel(
      docsId: tempId,
      fromId: currentUser.uid,
      toId: receiverId,
      msg: pickedImage.path, // Local path temporarily
      type: MessageType.image,
      send: DateTime.now(),
      read: null,
      uploadProgress: 0.0,
      isUploading: true,
      localImagePath: pickedImage.path,
    );

    // Add temporary message to UI immediately
    _addTempMessageToUI(tempMessage);

    try {
      final filePath =
          'chat/${getConversationId(receiverId)}/${DateTime.now().millisecondsSinceEpoch}';
      // Upload with progress tracking
      final imageUrl = await ImageService().uploadImageWithProgress(
        pickedImage,
        filePath,
        onProgress: (progress) {
          _updateUploadProgress(tempId, progress);
        },
      );
      DocumentReference docRef =
          _firestore
              .collection('chat/${getConversationId(receiverId)}/messages')
              .doc();
      await docRef.set({
        'toId': receiverId,
        'docsId': docRef.id,
        'fromId': currentUser.uid,
        'msg': imageUrl,
        'send': FieldValue.serverTimestamp(),
        'type': MessageType.image.name,
      });
      // Remove temporary message (Firestore will add the real one)
      _removeTempMessage(tempId);
    } catch (e) {
      debugPrint('ERROR OCCURRED$e');
      // Mark message as failed
      _markMessageAsFailed(tempId);
    }
  }

  void _addTempMessageToUI(MessageModel message) {
    state.data.whenData((messages) {
      final updatedMessages = [message, ...messages];
      state = state.copyWith(data: AsyncValue.data(updatedMessages));
    });
  }

  void _updateUploadProgress(String tempId, double progress) {
    state.data.whenData((messages) {
      final updatedMessages =
          messages.map((msg) {
            if (msg.docsId == tempId) {
              return MessageModel(
                docsId: msg.docsId,
                fromId: msg.fromId,
                toId: msg.toId,
                msg: msg.msg,
                type: msg.type,
                send: msg.send,
                read: msg.read,
                uploadProgress: progress,
                isUploading: true,
                localImagePath: msg.localImagePath,
              );
            }
            return msg;
          }).toList();
      state = state.copyWith(data: AsyncValue.data(updatedMessages));
    });
  }

  void _removeTempMessage(String tempId) {
    state.data.whenData((messages) {
      final updatedMessages =
          messages.where((msg) => msg.docsId != tempId).toList();
      state = state.copyWith(data: AsyncValue.data(updatedMessages));
    });
  }

  void _markMessageAsFailed(String tempId) {
    state.data.whenData((messages) {
      final updatedMessages =
          messages.map((msg) {
            if (msg.docsId == tempId) {
              return MessageModel(
                docsId: msg.docsId,
                fromId: msg.fromId,
                toId: msg.toId,
                msg: msg.msg,
                type: msg.type,
                send: msg.send,
                read: msg.read,
                uploadProgress: null,
                isUploading: false,
                localImagePath: msg.localImagePath,
                uploadFailed: true,
              );
            }
            return msg;
          }).toList();
      state = state.copyWith(data: AsyncValue.data(updatedMessages));
    });
  }

  Future<void> retryUpload(MessageModel message) async {
    if (message.localImagePath == null) return;

    _updateUploadProgress(message.docsId, 0.0);

    try {
      final filePath =
          'chat/${getConversationId(receiverId)}/${DateTime.now().millisecondsSinceEpoch}';

      final imageUrl = await ImageService().uploadImageWithProgress(
        File(message.localImagePath!),
        filePath,
        onProgress: (progress) {
          _updateUploadProgress(message.docsId, progress);
        },
      );

      DocumentReference docRef =
          _firestore
              .collection('chat/${getConversationId(receiverId)}/messages')
              .doc();

      await docRef.set({
        'toId': receiverId,
        'docsId': docRef.id,
        'fromId': currentUser.uid,
        'msg': imageUrl,
        'send': FieldValue.serverTimestamp(),
        'type': MessageType.image.name,
      });

      _removeTempMessage(message.docsId);
    } catch (e) {
      debugPrint('RETRY ERROR: $e');
      _markMessageAsFailed(message.docsId);
    }
  }

  Future<void> updateMessageStatus(MessageModel message) async {
    _firestore
        .collection('chat/${getConversationId(message.fromId)}/messages')
        .doc(message.docsId)
        .update({'read': FieldValue.serverTimestamp()});
  }

  Future<void> deleteMessage(MessageModel message) async {
    await _firestore
        .collection('chat/${getConversationId(message.toId)}/messages')
        .doc(message.docsId)
        .delete();
    if (message.type == MessageType.image) {
      await FirebaseStorage.instance.refFromURL(message.msg).delete();
      debugPrint('Image deleted from storage');
    }
  }

  forUpdate(BuildContext context,MessageModel editMessage) {
    FocusScope.of(context).requestFocus(focusNode);
    state = state.copyWith(isEdit: true, editedMessage: editMessage);
    messageController.text = editMessage.msg;
  }

  Future<void> updateMessage(MessageModel message) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    try {
      await _firestore
          .collection('chat/${getConversationId(message.toId)}/messages')
          .doc(message.docsId)
          .update({'msg': text});
      messageController.clear();
      state = state.copyWith(isEdit: false,editedMessage: null);
    } catch (e) {
      debugPrint('ERROR OCCURRED $e');
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
  final bool isEdit;
  final MessageModel? editedMessage;

  MessagesState({
    required this.data,
    this.lastMessage,
    this.showEmoji = false,
    this.isEdit = false,
    this.editedMessage,
  });

  MessagesState copyWith({
    AsyncValue<List<MessageModel>>? data,
    AsyncValue<MessageModel>? lastMessage,
    bool? showEmoji,
    bool? isEdit,
    MessageModel? editedMessage,
  }) {
    return MessagesState(
      data: data ?? this.data,
      lastMessage: lastMessage ?? this.lastMessage,
      showEmoji: showEmoji ?? this.showEmoji,
      isEdit: isEdit ?? this.isEdit,
      editedMessage: editedMessage ?? this.editedMessage,
    );
  }
}
