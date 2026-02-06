class ChatRepository {
  static Future<List<Map<String, dynamic>>> getChats() async {
    // Placeholder implementation
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': '1', 'name': 'Alice', 'lastMessage': 'Hey there!', 'time': '2:30 PM'},
      {'id': '2', 'name': 'Bob', 'lastMessage': 'See you tomorrow', 'time': '1:15 PM'},
    ];
  }

  static Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    // Placeholder implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': '1', 'text': 'Hello!', 'sender': 'other', 'time': '2:00 PM'},
      {'id': '2', 'text': 'Hi there!', 'sender': 'me', 'time': '2:05 PM'},
      {'id': '3', 'text': 'How are you?', 'sender': 'other', 'time': '2:10 PM'},
    ];
  }

  static Future<bool> sendMessage(String chatId, String message) async {
    // Placeholder implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  static Future<bool> markAsRead(String chatId) async {
    // Placeholder implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
