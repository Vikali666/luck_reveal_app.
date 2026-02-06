import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luck_reveal_app/models/icebreaker_card.dart';

class GeminiIcebreakerService {
  static const String _apiKey = "AIzaSyCwUxmEu0wVbY-Paa8P-s6CoXI-1GMUX6c";
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  Future<IcebreakerCard> generateDynamicCard(CardCategory category) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Genera una pregunta para romper el hielo en una app de citas. "
                      "Categoría: ${_getCategoryName(category)}. "
                      "Tono: Místico, moderno, intrigante. "
                      "Devuelve JSON con formato: {\"text\": \"pregunta\", \"emoji\": \"emoji\"}"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText = data['candidates'][0]['content']['parts'][0]['text'];
        final cleanJson =
            rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonData = jsonDecode(cleanJson);

        return IcebreakerCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: jsonData['text'],
          category: category,
          emoji: jsonData['emoji'],
          isPremium: category == CardCategory.picante,
          isAIGenerated: true,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      print("Error IA: $e");
    }

    return _getFallbackCard(category);
  }

  String _getCategoryName(CardCategory category) {
    switch (category) {
      case CardCategory.inicio:
        return 'rompehielos (preguntas ligeras)';
      case CardCategory.medio:
        return 'profundizando (preguntas personales)';
      case CardCategory.picante:
        return 'picante (preguntas atrevidas)';
    }
  }

  IcebreakerCard _getFallbackCard(CardCategory category) {
    final fallbacks = {
      CardCategory.inicio: IcebreakerCard(
        id: 'fallback_1',
        text: '¿Qué superpoder elegirías para una primera cita?',
        category: category,
        emoji: '⚡',
        createdAt: DateTime.now(),
      ),
      CardCategory.medio: IcebreakerCard(
        id: 'fallback_2',
        text: '¿A qué lugar del mundo llevarías a alguien especial?',
        category: category,
        emoji: '🌎',
        createdAt: DateTime.now(),
      ),
      CardCategory.picante: IcebreakerCard(
        id: 'fallback_3',
        text: '¿Verdad o reto con un toque de misterio?',
        category: category,
        emoji: '😏',
        isPremium: true,
        createdAt: DateTime.now(),
      ),
    };

    return fallbacks[category] ??
        IcebreakerCard(
          id: 'default',
          text: '¿Qué te gusta hacer en tu tiempo libre?',
          category: category,
          emoji: '🎯',
          createdAt: DateTime.now(),
        );
  }
}
