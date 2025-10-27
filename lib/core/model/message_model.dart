import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String fromId;
  final String toId;
  final String msg;
  final DateTime? send;
  final String read;
  final MessageType type;

  MessageModel({
    required this.fromId,
    required this.toId,
    required this.msg,
    required this.send,
    required this.read,
    required this.type,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      fromId: map['fromId'] ?? '',
      toId: map['toId'] ?? '',
      msg: map['msg'] ?? '',
      send: map['send'] != null ? (map['send'] as Timestamp).toDate() : null,
      read: map['read'] ?? '',
      type: map['type'] == 'image' ? MessageType.image : MessageType.text,
    );
  }
}

enum MessageType { image, text }
