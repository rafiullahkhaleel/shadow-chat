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
        child: isMe ? _sentMessage(context) : _receivedMessage(context, ref),
      ),
    );
  }

  Widget _receivedMessage(BuildContext context, WidgetRef ref) {
    if (data.read == null) {
      // Update message status to read
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
              ? _buildWhatsAppImage(data.msg, isMe: false)
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

  Widget _sentMessage(BuildContext context) {
    return Container(
      padding:
          data.type == MessageType.image
              ? EdgeInsets.all(4)
              : EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFDCF8C6), // WhatsApp green
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
              ? _buildWhatsAppImage(data.msg, isMe: true)
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
                    color: Colors.grey.shade700,
                    fontSize: 11,
                    shadows:
                        data.type == MessageType.image
                            ? [Shadow(color: Colors.black54, blurRadius: 3)]
                            : null,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.done_all,
                  size: 16,
                  color:
                      data.read != null
                          ? Colors.blue.shade400
                          : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppImage(String imageUrl, {required bool isMe}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          CachedNetworkImage(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                        'Failed to load image',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          // Retry logic can be added here
                        },
                        child: Text(
                          'Tap to retry',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            imageBuilder:
                (context, imageProvider) => GestureDetector(
                  onTap: () {
                    // Open image in full screen
                    _openImageFullScreen(context, imageUrl);
                  },
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
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
          ),
          // Download icon overlay (optional)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download, color: Colors.white, size: 18),
            ),
          ),
        ],
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
                      // Implement download functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // Implement share functionality
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
        // Today - show time only
        return DateFormat('hh:mm a').format(timestamp);
      } else if (difference.inDays == 1) {
        // Yesterday
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        // Within a week - show day name
        return DateFormat('EEEE').format(timestamp);
      } else {
        // Older - show date
        return DateFormat('dd/MM/yyyy').format(timestamp);
      }
    } catch (e) {
      return '';
    }
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shadow_chat/core/model/message_model.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/provider/messages_provider.dart';
//
// class MessageCard extends ConsumerWidget {
//   final MessageModel data;
//   const MessageCard({super.key, required this.data});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     bool isMe = FirebaseAuth.instance.currentUser!.uid == data.fromId;
//
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//         child: isMe ? _sentMessage(context) : _receivedMessage(context, ref),
//       ),
//     );
//   }
//
//   Widget _receivedMessage(BuildContext context, WidgetRef ref) {
//     if (data.read == null) {
//       // Update message status to read
//       ref
//           .read(messagesProvider(data.fromId).notifier)
//           .updateMessageStatus(data);
//     }
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//           bottomLeft: Radius.circular(0),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           data.type == MessageType.image
//               ? CachedNetworkImage(imageUrl: data.msg)
//               : Text(
//                 data.msg,
//                 style: TextStyle(color: Colors.black87, fontSize: 16),
//               ),
//           SizedBox(height: 4),
//           Text(
//             _formatTime(data.send),
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sentMessage(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Color(0xFFDCF8C6), // WhatsApp green
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(0),
//           bottomLeft: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           data.type == MessageType.image
//               ? CachedNetworkImage(imageUrl: data.msg)
//               : Text(
//                 data.msg,
//                 style: TextStyle(color: Colors.black87, fontSize: 16),
//               ),
//           SizedBox(width: 4),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 _formatTime(data.send),
//                 style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
//               ),
//               SizedBox(width: 4),
//               Icon(
//                 Icons.done_all,
//                 size: 16,
//                 color:
//                     data.read != null
//                         ? Colors.blue.shade400
//                         : Colors.grey.shade600,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTime(DateTime? timestamp) {
//     if (timestamp == null) {
//       return 'Sending....';
//     }
//     try {
//       final now = DateTime.now();
//       final difference = now.difference(timestamp);
//
//       if (difference.inDays == 0) {
//         // Today - show time only
//         return DateFormat('hh:mm a').format(timestamp);
//       } else if (difference.inDays == 1) {
//         // Yesterday
//         return 'Yesterday';
//       } else if (difference.inDays < 7) {
//         // Within a week - show day name
//         return DateFormat('EEEE').format(timestamp);
//       } else {
//         // Older - show date
//         return DateFormat('dd/MM/yyyy').format(timestamp);
//       }
//     } catch (e) {
//       return '';
//     }
//   }
// }
