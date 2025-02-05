import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: FirebaseAuth.instance.signOut,
          ),
        ],
      ),
      body: Center(
        child: const Text('Chat Screen'),
      ),
    );
  }
}
