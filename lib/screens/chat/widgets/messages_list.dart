import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/chat/widgets/message_bubble.dart';

class MessagesList extends StatelessWidget {
  const MessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred!'),
            );
          }

          final messages = snapshot.data!.docs;

          if (!snapshot.hasData || messages.isEmpty) {
            return const Center(
              child: Text('No messages yet!'),
            );
          }

          return ListView.separated(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index].data();
              final nextMessage = index + 1 < messages.length
                  ? messages[index + 1].data()
                  : null;

              final isNextMessageSameUser = nextMessage != null &&
                  nextMessage['userId'] == message['userId'];
              final isMe = message['userId'] == userId;

              if (isNextMessageSameUser) {
                return MessageBubble.next(
                    message: message['message'], isMe: isMe);
              } else {
                return MessageBubble.first(
                  userImage: message['userImage'],
                  username: message['userName'],
                  message: message['message'],
                  isMe: isMe,
                );
              }
            },
          );
        },
      ),
    );
  }
}
