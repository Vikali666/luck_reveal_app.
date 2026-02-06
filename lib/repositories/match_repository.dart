class MatchRepository {
  static Future<List<Map<String, dynamic>>> getMatches() async {
    // Placeholder implementation
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': '1', 'name': 'Alice', 'age': 25, 'distance': 2.5},
      {'id': '2', 'name': 'Bob', 'age': 28, 'distance': 5.1},
      {'id': '3', 'name': 'Carol', 'age': 23, 'distance': 1.8},
    ];
  }

  static Future<bool> likeUser(String userId) async {
    // Placeholder implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  static Future<bool> passUser(String userId) async {
    // Placeholder implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  static Future<List<Map<String, dynamic>>> getMutualMatches() async {
    // Placeholder implementation
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': '4', 'name': 'David', 'age': 30, 'matchedAt': '2024-01-15'},
    ];
  }
}
