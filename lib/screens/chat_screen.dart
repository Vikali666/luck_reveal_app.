import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final bool isTestChat;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.isTestChat = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUserPhotoUrl != null
                  ? NetworkImage(widget.otherUserPhotoUrl!)
                  : null,
              child: widget.otherUserPhotoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUserName,
                      style: const TextStyle(fontSize: 16)),
                  if (widget.isTestChat)
                    const Text('Chat de prueba',
                        style: TextStyle(fontSize: 12, color: Colors.orange)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('Los mensajes aparecerán aquí'),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.grey[900],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              // Action to send message
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
