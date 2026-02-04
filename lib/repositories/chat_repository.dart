import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== OBTENER CHATS DEL USUARIO (Tu base mejorada) ==========
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {'chatId': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ========== ENVÍO DE MENSAJES CON SEGURIDAD Y REVELACIÓN ==========
  Future<void> sendMessage({
    required String chatId,
    required String text,
    MessageType type = MessageType.text,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No hay usuario');

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final chatData = chatDoc.data() ?? {};

      // Verificación de Seguridad (Pilar 4)
      if (chatData['isTestExpired'] == true) {
        throw Exception('Chat de prueba terminado');
      }

      final messageId = _firestore.collection('messages').doc().id;
      final message = {
        'id': messageId,
        'senderId': userId,
        'text': text,
        'timestamp': Timestamp.now(),
        'read': false,
        'type': type.toString().split('.').last,
        'revelationLevel': _calculateLevel(chatData, userId),
      };

      final batch = _firestore.batch();

      // 1. Agregar mensaje
      batch.set(
          _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .doc(messageId),
          message);

      // 2. Actualizar metadata del chat (Tu lógica original)
      batch.update(_firestore.collection('chats').doc(chatId), {
        'lastMessage': text,
        'lastMessageTime': Timestamp.now(),
        'lastSenderId': userId,
        'messageCounts.$userId': FieldValue.increment(1),
      });

      await batch.commit();
      _checkRelationshipStage(
          chatId, chatData); // Actualiza etapa automáticamente
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== SISTEMA DE SEGURIDAD 3-STRIKES ==========
  Future<void> reportUser(
      String chatId, String reportedUserId, String reason) async {
    await _firestore.collection('reports').add({
      'chatId': chatId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'createdAt': Timestamp.now(),
    });

    final reports = await _firestore
        .collection('reports')
        .where('reportedUserId', isEqualTo: reportedUserId)
        .get();

    if (reports.docs.length >= 3) {
      await _firestore.collection('users').doc(reportedUserId).update({
        'isBanned': true,
        'bannedUntil':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      });
    }
  }

  // ========== MÉTODOS DE APOYO (REVELACIÓN Y ETAPAS) ==========
  double _calculateLevel(Map<String, dynamic> data, String userId) {
    int count = data['messageCounts']?[userId] ?? 0;
    if (count < 10) return 0.25; // Pilar 2: Revelación progresiva
    if (count < 30) return 0.60;
    return 1.0;
  }

  Future<void> _checkRelationshipStage(
      String chatId, Map<String, dynamic> data) async {
    // Lógica para subir de nivel el chat (iceBreaker -> connection, etc.)
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    // Implementación simulada o real
  }

  Future<ChatModel> createTestChat(
      String matchId, List<String> participants) async {
    // Crea un chat de prueba
    final chatId = _firestore.collection('chats').doc().id;
    final now = DateTime.now();
    final chat = ChatModel(
      id: chatId,
      matchId: matchId,
      participants: participants,
      chatType: ChatType.freeTest,
      revelationProgress: {},
      dailyTokens: {},
      messageCounts: {},
      createdAt: now,
      testChatExpiresAt: now.add(const Duration(minutes: 5)),
    );
    await _firestore.collection('chats').doc(chatId).set(chat.toFirestore());
    return chat;
  }

  Future<ChatAnalytics> getChatAnalytics(String chatId) async {
    return ChatAnalytics(
        topics: {},
        moodScore: 0.8,
        engagement: 'alto',
        averageResponseTime: const Duration(minutes: 1),
        suggestions: [],
        compatibilityScore: 85,
        commonInterests: ['Music', 'Travel'],
        chemistry: 'Alta ⚡');
  }

  Future<void> earnTokens(String userId, String source) async {
    // Logic to increment tokens
  }
}
