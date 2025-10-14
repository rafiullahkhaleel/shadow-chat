import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: 6),
      child: Card(
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          leading: const CircleAvatar(
            radius: 25,
            child: Icon(Icons.person,color: Colors.green,),
          ),
          title: const Text(
            'Username',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: const Text(
            'Last message preview...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '2:30 PM',
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


