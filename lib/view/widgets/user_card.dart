import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/core/model/message_model.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:shadow_chat/core/utils/date_time_helper.dart';
import 'package:shadow_chat/view/screens/user_chat_screen.dart';
import 'package:shadow_chat/view/widgets/profile_dialog.dart';

class UserCard extends StatelessWidget {
  final UserModel userData;
  final MessageModel? lastMessage;

  const UserCard({super.key, required this.userData, this.lastMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        color: Colors.white,
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserChatScreen(userData: userData),
              ),
            );
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          leading: InkWell(
            onTap: (){
              showDialog(context: context, builder: (context)=>ProfileDialog(userData: userData));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: userData.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(Icons.person),
                errorWidget: (context, url, error) => Icon(Icons.person),
              ),
            ),
          ),
          title: Text(
            userData.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Text(
            lastMessage?.msg ?? '',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateTimeHelper.formatTime(lastMessage?.send),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 6),
              lastMessage != null && lastMessage?.read == null &&
                      lastMessage?.fromId !=
                          FirebaseAuth.instance.currentUser!.uid
                  ? CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.green,
                  )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
