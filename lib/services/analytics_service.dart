import 'package:flutter/foundation.dart';
import 'package:luck_reveal_app/models/icebreaker_card.dart';

class IcebreakerAnalytics {
  // Rastrea cuando se genera o muestra una carta
  void trackCardGenerated(CardCategory category, bool isAI) {
    // Aquí es donde en el futuro conectarás con Firebase
    debugPrint(
        '📊 [ANALYTICS] Carta mostrada: Categoría: ${category.name}, Generada por IA: $isAI');
  }

  // Rastrea cuando el usuario comparte una carta
  void trackCardShared(IcebreakerCard card) {
    debugPrint('📊 [ANALYTICS] Carta compartida: ${card.id}');
  }

  // Rastrea cuando alguien hace clic en "Hacerme Premium"
  void trackPremiumClick() {
    debugPrint('📊 [ANALYTICS] Intento de conversión a Premium');
  }
}
