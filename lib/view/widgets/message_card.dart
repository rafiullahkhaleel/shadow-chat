import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/model/message_model.dart';
import 'package:intl/intl.dart';
import '../../core/provider/messages_provider.dart';

class MessageCard extends ConsumerWidget {
  final MessageModel data;
  const MessageCard({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isMe = FirebaseAuth.instance.currentUser!.uid == data.fromId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child:
            isMe ? _sentMessage(context, ref) : _receivedMessage(context, ref),
      ),
    );
  }

  Widget _receivedMessage(BuildContext context, WidgetRef ref) {
    if (data.read == null && !data.isUploading) {
      ref
          .read(messagesProvider(data.fromId).notifier)
          .updateMessageStatus(data);
    }
    return Container(
      padding:
          data.type == MessageType.image
              ? EdgeInsets.all(4)
              : EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          data.type == MessageType.image
              ? _buildWhatsAppImage(context, ref, data.msg, isMe: false)
              : Text(
                data.msg,
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
          SizedBox(height: 4),
          Padding(
            padding:
                data.type == MessageType.image
                    ? EdgeInsets.only(right: 8, bottom: 4)
                    : EdgeInsets.zero,
            child: Text(
              _formatTime(data.send),
              style: TextStyle(
                color:
                    data.type == MessageType.image
                        ? Colors.white
                        : Colors.grey.shade600,
                fontSize: 11,
                shadows:
                    data.type == MessageType.image
                        ? [Shadow(color: Colors.black54, blurRadius: 3)]
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sentMessage(BuildContext context, WidgetRef ref) {
    return Container(
      padding:
          data.type == MessageType.image
              ? EdgeInsets.all(4)
              : EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFDCF8C6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          data.type == MessageType.image
              ? _buildWhatsAppImage(context, ref, data.msg, isMe: true)
              : Text(
                data.msg,
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
          SizedBox(height: 4),
          Padding(
            padding:
                data.type == MessageType.image
                    ? EdgeInsets.only(right: 8, bottom: 4)
                    : EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(data.send),
                  style: TextStyle(
                    color:
                        data.type == MessageType.image
                            ? Colors.white
                            : Colors.grey.shade700,
                    fontSize: 11,
                    shadows:
                        data.type == MessageType.image
                            ? [Shadow(color: Colors.black54, blurRadius: 3)]
                            : null,
                  ),
                ),
                SizedBox(width: 4),
                // Show clock icon for uploading, checkmarks for sent
                _buildMessageStatusIcon(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatusIcon() {
    if (data.isUploading) {
      return Icon(
        Icons.access_time,
        size: 16,
        color:
            data.type == MessageType.image
                ? Colors.white70
                : Colors.grey.shade600,
      );
    } else if (data.uploadFailed) {
      return Icon(Icons.error_outline, size: 16, color: Colors.red.shade400);
    } else {
      return Icon(
        Icons.done_all,
        size: 16,
        color:
            data.read != null
                ? Colors.blue.shade400
                : (data.type == MessageType.image
                    ? Colors.white70
                    : Colors.grey.shade600),
      );
    }
  }

  Widget _buildWhatsAppImage(
    BuildContext context,
    WidgetRef ref,
    String imagePath, {
    required bool isMe,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Show local image if uploading, otherwise network image
          if (data.isUploading && data.localImagePath != null)
            _buildLocalImage(data.localImagePath!)
          else if (!data.uploadFailed)
            _buildNetworkImage(context, imagePath)
          else
            _buildFailedImage(context, ref),

          // Upload progress overlay
          if (data.isUploading && data.uploadProgress != null)
            _buildUploadProgressOverlay(),

          // Retry button for failed uploads
          if (data.uploadFailed && isMe) _buildRetryButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildLocalImage(String localPath) {
    return Image.file(
      File(localPath),
      width: 250,
      height: 250,
      fit: BoxFit.cover,
    );
  }

  Widget _buildNetworkImage(BuildContext context, String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 250,
      height: 250,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            width: 250,
            height: 250,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            width: 250,
            height: 250,
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: Colors.grey.shade600,
                ),
                SizedBox(height: 8),
                Text(
                  'Failed to load',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
      imageBuilder:
          (context, imageProvider) => GestureDetector(
            onTap: () => _openImageFullScreen(context, imageUrl),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildUploadProgressOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black38,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: data.uploadProgress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Icon(Icons.upload, color: Colors.white, size: 28),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(data.uploadProgress! * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFailedImage(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      height: 250,
      color: Colors.grey.shade300,
      child:
          data.localImagePath != null
              ? Stack(
                children: [
                  Image.file(
                    File(data.localImagePath!),
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: 250,
                    height: 250,
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload Failed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload Failed',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildRetryButton(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            ref.read(messagesProvider(data.toId).notifier).retryUpload(data);
          },
          icon: Icon(Icons.refresh, size: 18),
          label: Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  void _openImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                    icon: Icon(Icons.download),
                    onPressed: () {
                      // Implement download
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // Implement share
                    },
                  ),
                ],
              ),
              body: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder:
                        (context, url) => CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) =>
                            Icon(Icons.error, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) {
      return 'Sending....';
    }
    try {
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays == 0) {
        return DateFormat('hh:mm a').format(timestamp);
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(timestamp);
      } else {
        return DateFormat('dd/MM/yyyy').format(timestamp);
      }
    } catch (e) {
      return '';
    }
  }
}
