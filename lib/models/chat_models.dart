import 'package:cloud_firestore/cloud_firestore.dart';

enum RelationshipStage {
  iceBreaker,
  gettingToKnow,
  connection,
  deepChat,
  trustBuilt
}

enum ChatType { freeTest, paidFull }

enum MessageType { text, photo, icebreaker, revelation, gift }

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool read;
  final MessageType type;
  final double revelationLevel;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.read = false,
    this.type = MessageType.text,
    this.revelationLevel = 1.0,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, [String? id]) {
    MessageType type = MessageType.text;
    if (map['type'] != null) {
      try {
        type = MessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MessageType.text,
        );
      } catch (_) {}
    }

    return ChatMessage(
      id: id ?? map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: map['read'] ?? false,
      type: type,
      revelationLevel: (map['revelationLevel'] ?? 1.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
      'type': type.name,
      'revelationLevel': revelationLevel,
    };
  }
}

class ChatAnalytics {
  final Set<String> topics;
  final double moodScore;
  final String engagement;
  final Duration averageResponseTime;
  final List<String> suggestions;
  final int compatibilityScore;
  final List<String> commonInterests;
  final String chemistry;

  ChatAnalytics({
    this.topics = const {},
    this.moodScore = 0.5,
    this.engagement = 'media',
    this.averageResponseTime = Duration.zero,
    this.suggestions = const [],
    this.compatibilityScore = 0,
    this.commonInterests = const [],
    this.chemistry = 'Baja 💤',
  });
}

class ChatModel {
  final String id;
  final String? matchId;
  final List<String> participants;
  final RelationshipStage stage;
  final ChatType chatType;
  final DateTime createdAt;
  final DateTime? lastMessageTime;
  final String? lastMessage;
  final Map<String, int> unreadCount;
  final DateTime? testChatExpiresAt;
  final bool isTestChat;
  final Map<String, dynamic> revelationProgress;
  final Map<String, int> dailyTokens;
  final Map<String, int> messageCounts;

  ChatModel({
    required this.id,
    this.matchId,
    required this.participants,
    this.stage = RelationshipStage.iceBreaker,
    this.chatType = ChatType.freeTest,
    required this.createdAt,
    this.lastMessageTime,
    this.lastMessage,
    this.unreadCount = const {},
    this.testChatExpiresAt,
    this.isTestChat = false,
    this.revelationProgress = const {},
    this.dailyTokens = const {},
    this.messageCounts = const {},
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse stage
    RelationshipStage stage = RelationshipStage.iceBreaker;
    if (data['stage'] != null) {
      try {
        stage = RelationshipStage.values.firstWhere(
          (e) => e.name == data['stage'],
          orElse: () => RelationshipStage.iceBreaker,
        );
      } catch (_) {}
    }

    // Parse chatType
    ChatType chatType = ChatType.freeTest;
    if (data['chatType'] != null) {
      try {
        chatType = ChatType.values.firstWhere(
          (e) => e.name == data['chatType'],
          orElse: () => ChatType.freeTest,
        );
      } catch (_) {}
    }

    return ChatModel(
      id: data['id'] ?? doc.id,
      matchId: data['matchId'],
      participants: List<String>.from(data['participants'] ?? []),
      stage: stage,
      chatType: chatType,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessage: data['lastMessage'],
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      testChatExpiresAt: (data['testChatExpiresAt'] as Timestamp?)?.toDate(),
      isTestChat: data['isTestChat'] ?? false,
      revelationProgress:
          Map<String, dynamic>.from(data['revelationProgress'] ?? {}),
      dailyTokens: Map<String, int>.from(data['dailyTokens'] ?? {}),
      messageCounts: Map<String, int>.from(data['messageCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matchId': matchId,
      'participants': participants,
      'stage': stage.name,
      'chatType': chatType.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'testChatExpiresAt': testChatExpiresAt != null
          ? Timestamp.fromDate(testChatExpiresAt!)
          : null,
      'isTestChat': isTestChat,
      'revelationProgress': revelationProgress,
      'dailyTokens': dailyTokens,
      'messageCounts': messageCounts,
    };
  }

  Map<String, dynamic> toFirestore() => toMap();
}
