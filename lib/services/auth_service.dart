class AuthService {
  static Future<bool> signIn(String email, String password) async {
    // Placeholder implementation
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && password.isNotEmpty;
  }

  static Future<bool> signUp(String email, String password, String name) async {
    // Placeholder implementation
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && password.isNotEmpty && name.isNotEmpty;
  }

  static Future<void> signOut() async {
    // Placeholder implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<bool> isSignedIn() async {
    // Placeholder implementation
    return false;
  }

  static Future<String?> getCurrentUser() async {
    // Placeholder implementation
    return null;
  }
}
