import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:shadow_chat/view/screens/user_chat_screen.dart';

class UserCard extends StatelessWidget {
  final UserModel data;

  const UserCard({super.key, required this.data});

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
                builder: (context) => UserChatScreen(userData: data),
              ),
            );
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: data.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Icon(Icons.person),
              errorWidget: (context, url, error) => Icon(Icons.person),
            ),
          ),
          title: Text(
            data.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Text(
            data.isOnline ? 'Online' : data.about,
            style: TextStyle(color: Colors.grey, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.lastActive.toString(),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 6),
              CircleAvatar(
                radius: 9,
                backgroundColor: Colors.green,
                child: const Text(
                  '2',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
