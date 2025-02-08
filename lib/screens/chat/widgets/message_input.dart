import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class MessageInput extends StatefulWidget {
  const MessageInput({super.key});

  @override
  State<MessageInput> createState() => _NewMessageState();
}

class _NewMessageState extends State<MessageInput> {
  final _controller = TextEditingController();
  bool _isDisabled = true;

  void _checkMessage(String message) {
    setState(() => _isDisabled = message.trim().isEmpty);
  }

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    _controller.clear();
    setState(() => _isDisabled = true);

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userData = await _firestore.collection('users').doc(userId).get();

    _firestore.collection('chat').add({
      'message': message,
      'createdAt': Timestamp.now(),
      'userId': userId,
      'userName': userData.data()!['name'],
      'userImage': userData.data()!['image_url']
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 16),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autocorrect: true,
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: _checkMessage,
              decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
            onPressed: _isDisabled ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
