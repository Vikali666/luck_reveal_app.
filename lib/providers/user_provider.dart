import 'package:flutter/material.dart';
import 'package:luck_reveal_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel _currentUser = UserModel.newUser('demo_user_001');

  UserModel get currentUser => _currentUser;
  UserModel get user => _currentUser;

  Future<void> loadUser() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser.needsDailyReset()) {
      _currentUser = _currentUser.resetDailyCards();
    }

    notifyListeners();
  }

  void useCard() {
    if (_currentUser.hasCardsLeft && !_currentUser.isPremium) {
      _currentUser = _currentUser.useCard();
      notifyListeners();
    }
  }

  void addCards(int amount) {
    _currentUser = _currentUser.addCards(amount);
    notifyListeners();
  }

  void upgradeToPremium() {
    _currentUser = _currentUser.upgradeToPremium();
    notifyListeners();
  }

  void upgradeToMystic() {
    _currentUser = _currentUser.upgradeToMystic();
    notifyListeners();
  }

  void updateProfile({
    String? nickname,
    String? bio,
    int? age,
    List<String>? interests,
  }) {
    _currentUser = _currentUser.copyWith(
      nickname: nickname,
      bio: bio,
      age: age,
      interests: interests,
    );
    notifyListeners();
  }

  void resetDailyCards() {
    _currentUser = _currentUser.resetDailyCards();
    notifyListeners();
  }
}
