import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/contants/constants.dart';
import 'package:shadow_chat/core/extensions/context_extension.dart';
import 'package:shadow_chat/core/provider/current_user_data.dart';
import 'package:shadow_chat/view/screens/auth/login_screen.dart';
import 'package:shadow_chat/view/widgets/custom_text_field.dart';

import '../../core/provider/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(currentUserDataProvider);
    final userDataAssests = ref.read(currentUserDataProvider.notifier);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: userData.when(
          data: (data) {
            if (data == null) {
              return Center(
                child: Text(
                  'No user data found',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: context.width),
                  Stack(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: data.image,
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
                          onPressed: () {
                            _bottomSheet(context);
                          },
                          color: AppColors.mainColor,
                          shape: CircleBorder(),
                          child: Icon(Icons.edit, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.height * 0.03),
                  Text(
                    userData.asData?.value?.email ?? '',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                  ),
                  SizedBox(height: context.height * 0.03),
                  CustomTextField(
                    labelText: 'Name',
                    controller: userDataAssests.nameController,
                  ),
                  SizedBox(height: context.height * 0.02),
                  CustomTextField(
                    labelText: 'About',
                    controller: userDataAssests.aboutController,
                  ),
                  SizedBox(height: context.height * 0.03),
                  ElevatedButton.icon(
                    onPressed: () {
                      userDataAssests.updateData(context);
                    },
                    label: Text(
                      userDataAssests.isUpdating
                          ? 'Updating...'
                          : 'Update Profile',
                    ),
                    icon:
                        userDataAssests.isUpdating
                            ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Icon(Icons.edit),
                  ),
                ],
              );
            }
          },
          error: (error, stack) => Center(child: Text('$error')),
          loading: () => Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton:
          userData.asData?.value != null
              ? FloatingActionButton.extended(
                backgroundColor: AppColors.mainColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed:
                    isLoading
                        ? null
                        : () =>
                            ref.read(authProvider.notifier).signOut(context),
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
              )
              : FloatingActionButton.extended(
                backgroundColor: AppColors.mainColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (routes) => false,
                  );
                },
                label: const Text('Login'),
                icon: const Icon(Icons.login),
              ),
    );
  }

  _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text(
              'Pick Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                      shape: CircleBorder()
                  ),
                  onPressed: () {},
                  child: Image.asset(
                    'assets/gallery.png',
                    height: context.height * .1,
                    width: context.width * .15,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    shape: CircleBorder()
                  ),
                  onPressed: () {},
                  child: Image.asset(
                    'assets/camera.jpg',
                    height: context.height * .1,
                    width: context.width * .15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
