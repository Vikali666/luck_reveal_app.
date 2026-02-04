import 'package:shared_preferences/shared_preferences.dart';

class MatchLogic {
  static const String _dailyMatchesKey = 'matches_remaining';
  static const String _lastPlayDateKey = 'lastPlayDate';
  static const int _freeDailyMatches = 3;

  static Future<int> getRemainingMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastPlayDateKey) ?? '';
    final today = DateTime.now().toString().split(' ')[0];

    if (lastDate != today) {
      await prefs.setString(_lastPlayDateKey, today);
      await prefs.setInt(_dailyMatchesKey, _freeDailyMatches);
      return _freeDailyMatches;
    }
    return prefs.getInt(_dailyMatchesKey) ?? _freeDailyMatches;
  }

  static Future<bool> useMatch() async {
    final remaining = await getRemainingMatches();
    if (remaining > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyMatchesKey, remaining - 1);
      return true;
    }
    return false;
  }

  static Future<void> addMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_dailyMatchesKey) ?? _freeDailyMatches;
    await prefs.setInt(_dailyMatchesKey, current + 1);
  }
}
