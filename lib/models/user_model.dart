import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserPlan { free, premium, mystic }

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isPremium;
  final int dailyTokens;
  final DateTime? lastTokenUpdate;
  final String? bio;
  final List<String> interests;
  final int age;
  final GeoPoint? location;
  final UserPreferences? preferences;
  final int dailyMatches;
  final DateTime? lastMatchReset;
  final UserPlan plan;

  // Backward compatibility getters
  bool get isPaid => isPremium;
  String? get name => displayName;
  String? get photoUrl => photoURL;
  List<String> get selectedInterests => interests;
  String get nickname => displayName ?? '';
  String get planName => plan.name.toUpperCase();
  DateTime? get lastReset => lastMatchReset;
  String get id => uid;

  // New Getters for Icebreaker / Logic
  bool get isMystic => plan == UserPlan.mystic;

  int get remainingCards => dailyTokens;
  int get dailyCardsLimit => isPremium ? 9999 : 10;
  bool get hasCardsLeft => remainingCards > 0 || isPremium;

  Color get planColor {
    switch (plan) {
      case UserPlan.mystic:
        return Colors.purple;
      case UserPlan.premium:
        return Colors.amber; // 'Gold' equivalent or Orange
      case UserPlan.free:
        return Colors.blue;
    }
  }

  IconData get planIcon {
    switch (plan) {
      case UserPlan.mystic:
        return Icons.auto_awesome;
      case UserPlan.premium:
        return Icons.star;
      case UserPlan.free:
        return Icons.person;
    }
  }

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isPremium = false,
    this.dailyTokens = 0,
    this.lastTokenUpdate,
    this.bio,
    this.interests = const [],
    this.age = 18,
    this.location,
    this.preferences,
    this.dailyMatches = 0,
    this.lastMatchReset,
    this.plan = UserPlan.free,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, [String? uid]) {
    // If uid is not provided, try to find it in the map
    final String userId = uid ?? map['uid'] as String? ?? '';

    // Parse plan from string if available
    UserPlan parsedPlan = UserPlan.free;
    if (map['plan'] != null) {
      try {
        parsedPlan = UserPlan.values.firstWhere(
          (e) => e.name == map['plan'],
          orElse: () => UserPlan.free,
        );
      } catch (_) {}
    } else {
      // Fallback: if isPremium is true but no plan, assume premium
      if (map['isPremium'] == true || map['isPaid'] == true) {
        parsedPlan = UserPlan.premium;
      }
    }

    return UserModel(
      uid: userId,
      email: map['email'],
      displayName: map['displayName'] ?? map['name'],
      photoURL: map['photoURL'] ?? map['photoUrl'],
      isPremium: map['isPremium'] ?? map['isPaid'] ?? false,
      dailyTokens: map['dailyTokens'] ?? 0,
      lastTokenUpdate: (map['lastTokenUpdate'] as Timestamp?)?.toDate(),
      bio: map['bio'],
      interests:
          List<String>.from(map['interests'] ?? map['selectedInterests'] ?? []),
      age: map['age'] ?? 18,
      location: map['location'] as GeoPoint?,
      preferences: map['preferences'] != null
          ? UserPreferences.fromMap(map['preferences'])
          : null,
      dailyMatches: map['dailyMatches'] ?? 0,
      lastMatchReset: (map['lastMatchReset'] as Timestamp?)?.toDate(),
      plan: parsedPlan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isPremium': isPremium,
      'dailyTokens': dailyTokens,
      'lastTokenUpdate':
          lastTokenUpdate != null ? Timestamp.fromDate(lastTokenUpdate!) : null,
      'bio': bio,
      'interests': interests,
      'age': age,
      'location': location,
      'preferences': preferences?.toMap(),
      'dailyMatches': dailyMatches,
      'lastMatchReset':
          lastMatchReset != null ? Timestamp.fromDate(lastMatchReset!) : null,
      'plan': plan.name,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isPremium,
    int? dailyTokens,
    DateTime? lastTokenUpdate,
    String? bio,
    List<String>? interests,
    int? age,
    GeoPoint? location,
    UserPreferences? preferences,
    int? dailyMatches,
    DateTime? lastMatchReset,
    UserPlan? plan,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isPremium: isPremium ?? this.isPremium,
      dailyTokens: dailyTokens ?? this.dailyTokens,
      lastTokenUpdate: lastTokenUpdate ?? this.lastTokenUpdate,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      age: age ?? this.age,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      dailyMatches: dailyMatches ?? this.dailyMatches,
      lastMatchReset: lastMatchReset ?? this.lastMatchReset,
      plan: plan ?? this.plan,
    );
  }
}

class UserPreferences {
  final int minAge;
  final int maxAge;
  final double maxDistance;
  final List<String> interests;
  final String intent;
  final bool hasAdvancedFilters;
  final AdvancedFilters? advancedFilters;

  UserPreferences({
    this.minAge = 18,
    this.maxAge = 100,
    this.maxDistance = 0,
    this.interests = const [],
    this.intent = '',
    this.hasAdvancedFilters = false,
    this.advancedFilters,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      minAge: map['minAge'] ?? 18,
      maxAge: map['maxAge'] ?? 100,
      maxDistance: (map['maxDistance'] ?? 0).toDouble(),
      interests: List<String>.from(map['interests'] ?? []),
      intent: map['intent'] ?? '',
      hasAdvancedFilters: map['hasAdvancedFilters'] ?? false,
      advancedFilters: map['advancedFilters'] != null
          ? AdvancedFilters.fromMap(map['advancedFilters'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minAge': minAge,
      'maxAge': maxAge,
      'maxDistance': maxDistance,
      'interests': interests,
      'intent': intent,
      'hasAdvancedFilters': hasAdvancedFilters,
      'advancedFilters': advancedFilters?.toMap(),
    };
  }
}

class AdvancedFilters {
  final int? minHeight;
  final int? maxHeight;
  final bool? exercises;
  final bool? smoker;
  final String? educationLevel;
  final String? religion;

  AdvancedFilters({
    this.minHeight,
    this.maxHeight,
    this.exercises,
    this.smoker,
    this.educationLevel,
    this.religion,
  });

  factory AdvancedFilters.fromMap(Map<String, dynamic> map) {
    return AdvancedFilters(
      minHeight: map['minHeight'],
      maxHeight: map['maxHeight'],
      exercises: map['exercises'],
      smoker: map['smoker'],
      educationLevel: map['educationLevel'],
      religion: map['religion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minHeight': minHeight,
      'maxHeight': maxHeight,
      'exercises': exercises,
      'smoker': smoker,
      'educationLevel': educationLevel,
      'religion': religion,
    };
  }
}
