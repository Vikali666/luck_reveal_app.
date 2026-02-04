import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class ChatProvider extends ChangeNotifier {
  // --- Estado de la Interfaz ---
  List<ChatModel> _chats = [];
  bool _isLoading = false;

  // --- Mapas de Datos Profundos (Pilares de Luck Reveal) ---
  final Map<String, List<ChatMessage>> _chatMessages = {};
  final Map<String, ChatAnalytics> _chatAnalytics = {};

  // Getters
  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;

  // ========== GESTIÓN DE LISTA DE CHATS ==========

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setChats(List<ChatModel> chats) {
    _chats = chats;
    notifyListeners();
  }

  void addChat(ChatModel chat) {
    // Evitamos duplicados por ID
    _chats.removeWhere((c) => c.id == chat.id);
    _chats.insert(0, chat);
    notifyListeners();
  }

  void updateChat(String chatId, ChatModel updatedChat) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      _chats[index] = updatedChat;
      notifyListeners();
    }
  }

  // ========== GESTIÓN DE MENSAJES Y REVELACIÓN ==========

  void addMessage(String chatId, ChatMessage message) {
    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }
    // Insertamos al inicio para el ScrollView
    _chatMessages[chatId]!.insert(0, message);
    notifyListeners();
  }

  List<ChatMessage> getMessages(String chatId) => _chatMessages[chatId] ?? [];

  // ========== ANALÍTICA Y QUÍMICA (Bling Bling) ==========

  void updateAnalytics(String chatId, ChatAnalytics analytics) {
    _chatAnalytics[chatId] = analytics;
    notifyListeners();
  }

  ChatAnalytics? getAnalytics(String chatId) => _chatAnalytics[chatId];

  // ========== LIMPIEZA DE SESIÓN ==========

  void clear() {
    _chats.clear();
    _chatMessages.clear();
    _chatAnalytics.clear();
    _isLoading = false;
    notifyListeners();
  }
}
