import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String fromId;
  final String toId;
  final String docsId;
  final String msg;
  final DateTime? send;
  final DateTime? read;
  final MessageType type;
  final double? uploadProgress;
  final bool isUploading;
  final String? localImagePath;
  final bool uploadFailed;

  MessageModel({
    required this.fromId,
    required this.toId,
    required this.docsId,
    required this.msg,
    required this.type,
    this.send,
    this.read,
    this.uploadProgress,
    this.isUploading = false,
    this.localImagePath,
    this.uploadFailed = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      fromId: map['fromId'] ?? '',
      toId: map['toId'] ?? '',
      docsId: map['docsId'] ?? '',
      msg: map['msg'] ?? '',
      send: map['send'] != null ? (map['send'] as Timestamp).toDate() : null,
      read: map['read'] != null ? (map['read'] as Timestamp).toDate() : null,
      type: map['type'] == 'image' ? MessageType.image : MessageType.text,
    );
  }
}

enum MessageType { image, text }
