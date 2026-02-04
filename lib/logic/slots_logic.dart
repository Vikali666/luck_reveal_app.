class SlotsLogic {
  static const List<String> symbols = ['🍀', '💖', '💎', '🍋', '🔔', '⭐'];
  static const String winningSymbol = '🍀';
  static const List<double> probabilities = [0.50, 0.25, 0.05];

  static int _currentAttempt = 0;

  static int get currentAttempt => _currentAttempt;

  static bool get needsAd => _currentAttempt > 0;

  static String get adButtonText {
    switch (_currentAttempt) {
      case 1:
        return 'VER SIMULACIÓN DE AD';
      case 2:
        return 'VER SEGUNDO AD';
      default:
        return 'JUGAR';
    }
  }

  static List<String> spin() {
    final probability = _currentAttempt < probabilities.length
        ? probabilities[_currentAttempt]
        : 0.05;

    final results = List.generate(4, (_) {
      if (probability == 0.50 && DateTime.now().millisecond % 2 == 0) {
        return winningSymbol;
      }
      if (probability == 0.25 && DateTime.now().millisecond % 4 == 0) {
        return winningSymbol;
      }
      if (probability == 0.05 && DateTime.now().millisecond % 20 == 0) {
        return winningSymbol;
      }
      return symbols[(DateTime.now().microsecondsSinceEpoch % symbols.length)
          .toInt()];
    });

    _currentAttempt++;
    if (_currentAttempt > 2) _currentAttempt = 2;

    return results;
  }

  static bool checkWin(List<String> results) {
    return results.every((symbol) => symbol == winningSymbol);
  }

  static void resetAttempts() {
    _currentAttempt = 0;
  }
}
