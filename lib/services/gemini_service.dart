import 'dart:math';
import '../models/icebreaker_card.dart';

class GeminiIcebreakerService {
  final _random = Random();

  Future<IcebreakerCard> generateDynamicCard(CardCategory category) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final templates = {
      CardCategory.inicio: [
        'Si pudieras viajar a cualquier lugar hoy mismo, ¿a dónde irías?',
        '¿Cuál es el mejor cumplido que has recibido?',
        '¿Qué es lo más aventurero que has hecho?',
        '¿Cuál es tu recuerdo de infancia más divertido?',
      ],
      CardCategory.medio: [
        '¿Qué es lo que más valoras en una amistad?',
        '¿Cuál es tu mayor miedo y cómo lo enfrentas?',
        '¿Qué legado te gustaría dejar en el mundo?',
        '¿Cuál ha sido el desafío más difícil que has superado?',
      ],
      CardCategory.picante: [
        '¿Qué es lo primero que notas en alguien que te atrae?',
        '¿Cuál es tu idea de una cita perfecta e inolvidable?',
        '¿Qué es lo más atrevido que has hecho por amor?',
        '¿Qué cualidad te parece irresistible en una persona?',
      ],
    };

    final emojis = {
      CardCategory.inicio: ['🌍', '✨', '🚀', '🎈'],
      CardCategory.medio: ['🧠', '💎', '🌊', '🕯️'],
      CardCategory.picante: ['🔥', '🌶️', '💄', '⚡'],
    };

    final categoryTemplates = templates[category]!;
    final categoryEmojis = emojis[category]!;

    return IcebreakerCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: categoryTemplates[_random.nextInt(categoryTemplates.length)],
      category: category,
      emoji: categoryEmojis[_random.nextInt(categoryEmojis.length)],
      isAIGenerated: true,
      createdAt: DateTime.now(),
    );
  }
}
