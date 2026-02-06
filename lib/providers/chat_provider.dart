import 'package:flutter/foundation.dart';
import 'package:luck_reveal_app/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get chats => _chats;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _chats = await ChatRepository.getChats();
    } catch (e) {
      debugPrint('Error loading chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _messages = await ChatRepository.getMessages(chatId);
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String chatId, String message) async {
    try {
      final result = await ChatRepository.sendMessage(chatId, message);
      if (result) {
        _messages.add({
          'id': DateTime.now().toString(),
          'text': message,
          'sender': 'me',
          'time': DateTime.now().toString().substring(11, 16),
        });
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  Future<bool> markAsRead(String chatId) async {
    try {
      return await ChatRepository.markAsRead(chatId);
    } catch (e) {
      debugPrint('Error marking as read: $e');
      return false;
    }
  }
}
