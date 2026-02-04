import 'package:flutter/material.dart';

class MatchProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get matches => _matches;
  bool get isLoading => _isLoading;

  Future<void> setMatches(List<Map<String, dynamic>> matches) async {
    _matches = matches;
    notifyListeners();
  }

  Future<void> addMatch(Map<String, dynamic> match) async {
    _matches.add(match);
    notifyListeners();
  }

  Future<void> removeMatch(String matchId) async {
    _matches.removeWhere((match) => match['matchId'] == matchId);
    notifyListeners();
  }

  Future<void> setLoading(bool loading) async {
    _isLoading = loading;
    notifyListeners();
  }
}
