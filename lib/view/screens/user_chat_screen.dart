import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadow_chat/core/contants/constants.dart';
import 'package:shadow_chat/core/model/user_model.dart';

class UserChatScreen extends StatelessWidget {
  final UserModel data;
  const UserChatScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String time = DateFormat('hh:mm a').format(data.lastActive!);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leadingWidth: 32,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 23,
            backgroundImage: CachedNetworkImageProvider(data.imageUrl),
          ),
          title: Text(
            data.name,
            style: TextStyle(color: AppColors.white, fontSize: 17),
          ),
          subtitle: Text(
            'last seen today at $time',
            style: TextStyle(color: AppColors.white, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
