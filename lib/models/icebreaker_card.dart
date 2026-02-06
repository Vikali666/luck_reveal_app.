enum CardCategory {
  inicio,
  medio,
  picante,
}

class IcebreakerCard {
  final String id;
  final String text;
  final CardCategory category;
  final String emoji;
  final bool? isPremium;
  final bool? isAIGenerated;
  final DateTime? createdAt;

  IcebreakerCard({
    required this.id,
    required this.text,
    required this.category,
    required this.emoji,
    this.isPremium,
    this.isAIGenerated,
    this.createdAt,
  });

  IcebreakerCard copyWith({
    String? id,
    String? text,
    CardCategory? category,
    String? emoji,
    bool? isPremium,
    bool? isAIGenerated,
    DateTime? createdAt,
  }) {
    return IcebreakerCard(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      isPremium: isPremium ?? this.isPremium,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category.name,
      'emoji': emoji,
      'isPremium': isPremium,
      'isAIGenerated': isAIGenerated,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory IcebreakerCard.fromJson(Map<String, dynamic> json) {
    return IcebreakerCard(
      id: json['id'],
      text: json['text'],
      category: CardCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => CardCategory.inicio,
      ),
      emoji: json['emoji'] ?? '🎯',
      isPremium: json['isPremium'],
      isAIGenerated: json['isAIGenerated'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
