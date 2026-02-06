import 'package:flutter/foundation.dart';
import 'package:luck_reveal_app/repositories/match_repository.dart';

class MatchProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _mutualMatches = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get matches => _matches;
  List<Map<String, dynamic>> get mutualMatches => _mutualMatches;
  bool get isLoading => _isLoading;

  Future<void> loadMatches() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _matches = await MatchRepository.getMatches();
    } catch (e) {
      debugPrint('Error loading matches: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMutualMatches() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _mutualMatches = await MatchRepository.getMutualMatches();
    } catch (e) {
      debugPrint('Error loading mutual matches: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> likeUser(String userId) async {
    try {
      final result = await MatchRepository.likeUser(userId);
      if (result) {
        _matches.removeWhere((match) => match['id'] == userId);
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Error liking user: $e');
      return false;
    }
  }

  Future<bool> passUser(String userId) async {
    try {
      final result = await MatchRepository.passUser(userId);
      if (result) {
        _matches.removeWhere((match) => match['id'] == userId);
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Error passing user: $e');
      return false;
    }
  }
}
