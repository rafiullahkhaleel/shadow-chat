import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/provider/auth_provider.dart';
import 'package:shadow_chat/provider/user_provider.dart';
import 'package:shadow_chat/view/widgets/user_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: Colors.orange.shade100,
      appBar: AppBar(
        leading: Icon(Icons.home),
        title: Text('Shadow Chat'),
        actions: [IconButton(onPressed: () {
          ref.read(authProvider.notifier).signOut();
        }, icon: Icon(Icons.search))],
      ),
      body: provider.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: data.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final user = data[index];
              return UserCard(
                name: user.name,
                imageUrl: user.image,
                isOnline: user.isOnline,
                lastActive: user.lastActive,
                about: user.about,
              );
            },
          );
        },
        error: (error, stack) => Text('ERROR OCCURRED $error'),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

