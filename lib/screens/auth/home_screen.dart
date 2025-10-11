import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.home),
        title: Text('Shadow Chat'),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search))
        ],
      ),
    );
  }
}
