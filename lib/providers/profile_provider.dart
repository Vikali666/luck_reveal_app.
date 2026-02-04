import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'user_provider.dart';

class ProfileProvider extends ChangeNotifier {
  // Logic allows editing the user profile separately from Auth/User providers
  // For now, it acts as a facade or helper for profile-specific operations

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  void setEditing(bool editing) {
    _isEditing = editing;
    notifyListeners();
  }

  Future<void> updateProfile(
      UserProvider userProvider, Map<String, dynamic> data) async {
    // Logic to update user profile
    if (userProvider.user != null) {
      // Create updated model
      UserModel updated = userProvider.user!.copyWith(
          displayName: data['displayName'],
          bio: data['bio'],
          interests: data['interests']);

      // Call user provider to persist
      await userProvider.updateUser(updated);
    }
  }
}
