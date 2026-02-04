import 'package:flutter/material.dart';

enum CardCategory { inicio, medio, picante }

class IcebreakerCard {
  final String id;
  final String text;
  final CardCategory category;
  final String emoji;
  final bool isPremium;
  final bool isAIGenerated;
  final DateTime createdAt;

  IcebreakerCard({
    required this.id,
    required this.text,
    required this.category,
    required this.emoji,
    this.isPremium = false,
    this.isAIGenerated = false,
    required this.createdAt,
  });

  String get categoryName {
    switch (category) {
      case CardCategory.inicio:
        return 'ROMPEHIELOS';
      case CardCategory.medio:
        return 'PROFUNDIZANDO';
      case CardCategory.picante:
        return 'CALENTANDO 🔥';
    }
  }

  Color get categoryColor {
    switch (category) {
      case CardCategory.inicio:
        return Colors.blue;
      case CardCategory.medio:
        return Colors.purple;
      case CardCategory.picante:
        return Colors.pink;
    }
  }
}
