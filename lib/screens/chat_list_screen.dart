// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';
import '../providers/user_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) {
      return const Scaffold(
          body: Center(child: Text('Inicia sesión para ver tus chats')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luck Reveal Chats',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Colors.amber),
            onPressed: () {}, // Navegar a suscripción
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = ChatModel.fromFirestore(chats[index]);
              final otherUserId =
                  chat.participants.firstWhere((id) => id != user.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(title: Text("Cargando..."));
                  }
                  final otherUserData =
                      userSnap.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUserData['photoUrl'] != null
                          ? NetworkImage(otherUserData['photoUrl'])
                          : null,
                      child: otherUserData['photoUrl'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(otherUserData['name'] ?? 'Usuario'),
                    subtitle: Text(
                      chat.isTestChat
                          ? '⏳ Chat de prueba • ${_getTimeRemaining(chat)}'
                          : '🍀 ${_getStageName(chat.stage)}',
                      style: TextStyle(
                          color:
                              chat.isTestChat ? Colors.orange : Colors.purple),
                    ),
                    trailing: chat.isTestChat
                        ? const Chip(
                            label: Text('TEST',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                            backgroundColor: Colors.orange)
                        : const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chat.id,
                          otherUserId: otherUserId,
                          otherUserName: otherUserData['name'] ?? 'Usuario',
                          otherUserPhotoUrl: otherUserData['photoUrl'],
                          isTestChat: chat.isTestChat,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text('No hay chats aún',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const Text('¡Usa el trébol para encontrar un match!',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _getTimeRemaining(ChatModel chat) {
    if (chat.testChatExpiresAt == null) return '';
    final remaining = chat.testChatExpiresAt!.difference(DateTime.now());
    return remaining.isNegative ? 'Expirado' : '${remaining.inMinutes} min';
  }

  String _getStageName(RelationshipStage stage) {
    switch (stage) {
      case RelationshipStage.iceBreaker:
        return 'Rompehielos';
      case RelationshipStage.gettingToKnow:
        return 'Conociéndose';
      case RelationshipStage.connection:
        return 'Conexión';
      case RelationshipStage.deepChat:
        return 'Chat profundo';
      case RelationshipStage.trustBuilt:
        return 'Confianza';
    }
  }
}
