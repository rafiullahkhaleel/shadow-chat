import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';
import 'package:shadow_chat/core/model/user_model.dart';

class UserProfileView extends StatelessWidget {
  final UserModel userData;
  const UserProfileView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: context.width, height: context.height * .1),
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: userData.imageUrl,
              fit: BoxFit.cover,
              width: context.width * 0.4,
              height: context.width * 0.4,
              placeholder:
                  (context, url) =>
                      Icon(Icons.person, size: context.width * 0.2),
              errorWidget:
                  (context, url, error) =>
                      Icon(Icons.person, size: context.width * 0.2),
            ),
          ),
          SizedBox(height: context.height * 0.03),
          Text(
            userData.name,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
          ),
          SizedBox(height: context.height * 0.03),
          Text(
            userData.email,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
          ),
          SizedBox(height: context.height * 0.03),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: 'About:  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: userData.about,
                      style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Spacer(),
          RichText(
            text: TextSpan(
              text: 'Join On: ',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
              children: [
                if (userData.createdAt != null)
                  TextSpan(
                    text: DateFormat('dd/MM/yyyy').format(userData.createdAt!),
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: context.height * 0.013),
        ],
      ),
    );
  }
}
