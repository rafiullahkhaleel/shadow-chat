import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/contants/constants.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';
import 'package:shadow_chat/core/model/user_model.dart';
import 'package:shadow_chat/core/provider/auth/auth_state.dart';
import 'package:shadow_chat/view/widgets/custom_text_field.dart';

import '../../core/provider/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final UserModel userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: context.width),
          Stack(
            children: [
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
              Positioned(
                bottom: 10,
                right: -20,
                child: MaterialButton(
                  onPressed: () {},
                  color: AppColors.mainColor,
                  shape: CircleBorder(),
                  child: Icon(Icons.edit, color: AppColors.white),
                ),
              ),
            ],
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
            onPressed: () {},
            label: Text('Update Profile'),
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed:
            isLoading
                ? null
                : () => ref.read(authProvider.notifier).signOut(context),
        label:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Text('Logout'),
        icon: isLoading ? const SizedBox() : const Icon(Icons.logout),
      ),
    );
  }
}
