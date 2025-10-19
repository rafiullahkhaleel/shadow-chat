import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:shadow_chat/view/widgets/custom_text_field.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: context.width),
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: userData.image,
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
          CustomTextField(
            labelText: 'Name',
            controller: TextEditingController(text: userData.name),
          ),
          SizedBox(height: context.height * 0.02),
          CustomTextField(
            labelText: 'About',
            controller: TextEditingController(text: userData.about),
          ),
          SizedBox(height: context.height * 0.03),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(

            ),
            onPressed: () {},
            label: Text('Update Profile'),
            icon: Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
