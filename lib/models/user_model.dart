import 'package:flutter/material.dart';

enum UserPlan { free, premium, mystic }

class UserModel {
  final String id;
  final String uid;
  final String nickname;
  final String displayName;
  final UserPlan plan;
  final int dailyCardsLimit;
  final int remainingCards;
  final DateTime lastReset;
  final String? avatarUrl;
  final String? bio;
  final int? age;
  final List<String>? interests;

  UserModel({
    required this.id,
    required this.uid,
    this.nickname = "Viajero del Destino",
    this.displayName = "Viajero del Destino",
    this.plan = UserPlan.free,
    this.dailyCardsLimit = 10,
    this.remainingCards = 10,
    required this.lastReset,
    this.avatarUrl,
    this.bio = "Explorando conexiones misteriosas del destino",
    this.age,
    this.interests,
  });

  // Constructor para nuevo usuario
  factory UserModel.newUser(String id) {
    return UserModel(
      id: id,
      uid: id,
      lastReset: DateTime.now(),
    );
  }

  // CopyWith
  UserModel copyWith({
    UserPlan? plan,
    int? remainingCards,
    int? dailyCardsLimit,
    String? nickname,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? age,
    List<String>? interests,
    DateTime? lastReset,
  }) {
    return UserModel(
      id: id,
      uid: uid,
      nickname: nickname ?? this.nickname,
      displayName: displayName ?? this.displayName,
      plan: plan ?? this.plan,
      remainingCards: remainingCards ?? this.remainingCards,
      dailyCardsLimit: dailyCardsLimit ?? this.dailyCardsLimit,
      lastReset: lastReset ?? this.lastReset,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      interests: interests ?? this.interests,
    );
  }

  // Métodos de negocio
  bool needsDailyReset() {
    final now = DateTime.now();
    return now.day > lastReset.day ||
        now.month > lastReset.month ||
        now.year > lastReset.year;
  }

  UserModel resetDailyCards() {
    return copyWith(
      remainingCards: dailyCardsLimit,
      lastReset: DateTime.now(),
    );
  }

  UserModel useCard() {
    return copyWith(
      remainingCards: remainingCards - 1,
    );
  }

  UserModel addCards(int amount) {
    return copyWith(
      remainingCards: remainingCards + amount,
    );
  }

  UserModel upgradeToPremium() {
    return copyWith(
      plan: UserPlan.premium,
      dailyCardsLimit: 999,
      remainingCards: 999,
    );
  }

  UserModel upgradeToMystic() {
    return copyWith(
      plan: UserPlan.mystic,
      dailyCardsLimit: 9999,
      remainingCards: 9999,
    );
  }

  // Properties computadas
  bool get isPremium => plan == UserPlan.premium || plan == UserPlan.mystic;
  bool get isMystic => plan == UserPlan.mystic;
  bool get hasCardsLeft => remainingCards > 0 || isPremium;

  String get planName {
    switch (plan) {
      case UserPlan.free:
        return 'Free';
      case UserPlan.premium:
        return 'Premium ⭐';
      case UserPlan.mystic:
        return 'Mystic 🔮';
    }
  }

  Color get planColor {
    switch (plan) {
      case UserPlan.free:
        return Colors.grey;
      case UserPlan.premium:
        return Colors.orange;
      case UserPlan.mystic:
        return Colors.purple;
    }
  }

  IconData get planIcon {
    switch (plan) {
      case UserPlan.free:
        return Icons.person;
      case UserPlan.premium:
        return Icons.workspace_premium;
      case UserPlan.mystic:
        return Icons.auto_awesome;
    }
  }
}
