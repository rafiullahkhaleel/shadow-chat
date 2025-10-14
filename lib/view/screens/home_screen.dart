import 'package:flutter/material.dart';
import 'package:shadow_chat/view/widgets/bg_color.dart';
import 'package:shadow_chat/view/widgets/user_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.orange.shade100,
      appBar: AppBar(
        leading: Icon(Icons.home),
        title: Text('Shadow Chat'),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search))
        ],
      ),
      body: ListView.builder(
          itemCount: 50,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context,index){
        return UserCard();
      }),
    );
  }
}
