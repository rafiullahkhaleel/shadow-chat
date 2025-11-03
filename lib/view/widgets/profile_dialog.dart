import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadow_chat/core/contants/constants.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:shadow_chat/view/screens/profile_screen.dart';
import 'package:shadow_chat/view/screens/user_profile_view.dart';

class ProfileDialog extends StatelessWidget {
  final UserModel userData;
  const ProfileDialog({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    userData.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => UserProfileView(userData: userData),
                      ),
                    );
                  },
                  child: Icon(Icons.info_outline, color: AppColors.mainColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: userData.imageUrl,
                width: context.width * .45,
                height: context.height * .2,
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(Icons.person),
                errorWidget: (context, url, error) => Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
