import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isOnline;
  final String about;
  final String lastActive;
  const UserCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
    required this.lastActive,
    required this.about,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          leading: CircleAvatar(
            radius: 25,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Icon(Icons.person),
              errorWidget: (context, url, error) => Icon(Icons.person),
            ),
          ),
          title: Text(
            name*10,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Text(
            isOnline ? 'Online' : about,
            style: TextStyle(color: Colors.grey, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                lastActive,
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

// import 'package:flutter/material.dart';
//
// class UserCard extends StatelessWidget {
//   const UserCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundImage: NetworkImage('https://example.com/user_avatar.png'),
//         ),
//         title: Text('Username'),
//         subtitle: Text('Last message preview...'),
//         trailing: Text('2:30 PM'),
//       ),
//     );
//   }
// }
