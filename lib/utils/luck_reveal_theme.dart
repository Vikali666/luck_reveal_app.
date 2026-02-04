import 'package:flutter/material.dart';

class LuckRevealTheme {
  static const Color primary = Color(0xFF6A11CB); // Púrpura eléctrico
  static const Color secondary = Color(0xFF2575FC); // Azul brillante
  static const Color accent =
      Color(0xFFFFD700); // Oro/Dorado (Adjusted to safer gold)
  static const Color background = Color(0xFF0F0B1E); // Negro azulado
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0A0C0);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCFB53B), // Old Gold
      Color(0xFFFFD700), // Bright Gold
      Color(0xFFFBF5DF), // White Gold
      Color(0xFFDAA520), // Goldenrod
    ],
  );
}
