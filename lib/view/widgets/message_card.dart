import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/core/model/message_model.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatelessWidget {
  final MessageModel data;
  const MessageCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    bool isMe = FirebaseAuth.instance.currentUser!.uid == data.fromId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: isMe ? _sentMessage(context) : _receivedMessage(context),
      ),
    );
  }

  Widget _receivedMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Text(data.msg, style: TextStyle(color: Colors.black87, fontSize: 16)),
          SizedBox(height: 4),
          Text(
            _formatTime(data.send),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sentMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data.msg, style: TextStyle(color: Colors.black87, fontSize: 16)),
              SizedBox(width: 8,),
              Column(
                children: [
                  SizedBox(height: 20,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(data.send),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color:
                        data.read.isNotEmpty
                            ? Colors.blue.shade400
                            : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

        ],
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
