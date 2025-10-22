import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadow_chat/core/contants/constants.dart';
import 'package:shadow_chat/view/screens/profile_screen.dart';
import 'package:shadow_chat/view/widgets/user_card.dart';

import '../../core/provider/current_user_data.dart';
import '../../core/provider/users_data_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(userDataProvider);
    final prov = ref.read(userDataProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.orange.shade100,
      appBar: AppBar(
        leading: Icon(Icons.home),
        title:
            provider.isSearching
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(onPressed: (){
                        prov.isSearch();
                      }, icon: Icon(Icons.clear)),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(100)
                      ),
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.black)
                    ),
                    onChanged: (val) {
                      prov.updateSearchText(val);
                    },
                  ),
                )
                : Text('Shadow Chat'),
        actions: [
          if(!provider.isSearching)
          IconButton(
            onPressed: () {
              prov.isSearch();
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: provider.users.when(
        data: (_) {
          final filtered = prov.filteredUsers;
          if (filtered.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.builder(
            itemCount: filtered.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final user = filtered[index];
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
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
