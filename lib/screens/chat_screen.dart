import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserPhotoUrl;

  const ChatScreen({
    super.key,
    this.chatId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text(
          'Chat Screen - Coming Soon',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
