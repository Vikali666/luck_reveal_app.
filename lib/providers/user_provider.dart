import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luck_reveal_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  UserModel? get currentUser =>
      _user; // Alias para compatibilidad con tus pantallas
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== CARGA Y GESTIÓN INICIAL ==========

  Future<void> setUser(UserModel user) async {
    _user = user;
    // Verificamos si al entrar a la app necesita recargar sus tokens diarios
    await _checkAndPerformDailyReset();
    notifyListeners();
  }

  Future<void> setLoading(bool loading) async {
    _isLoading = loading;
    notifyListeners();
  }

  // ========== SISTEMA DE TOKENS (Economía de la App) ==========

  // Usar una carta (Icebreaker)
  Future<bool> useCard() async {
    if (_user == null) return false;

    // Si es Premium/Mystic tiene paso libre, si no, verificamos tokens
    if (_user!.isPremium || _user!.dailyTokens > 0) {
      if (!_user!.isPremium) {
        int newTokens = _user!.dailyTokens - 1;
        await _syncTokensToFirebase(newTokens);
      }
      return true;
    }
    return false; // No tiene tokens ni es premium
  }

  // Ganar cartas extra (por anuncios/actividades)
  Future<void> addCards(int amount) async {
    if (_user == null) return;
    int newTokens = _user!.dailyTokens + amount;
    await _syncTokensToFirebase(newTokens);
  }

  // Sincronización real con Firebase
  Future<void> _syncTokensToFirebase(int tokens) async {
    try {
      // 1. Actualización local inmediata (UX Fluida)
      _user = _user!.copyWith(dailyTokens: tokens);
      notifyListeners();

      // 2. Sincronización con la nube (Seguridad)
      await _firestore.collection('users').doc(_user!.uid).update({
        'dailyTokens': tokens,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Error al sincronizar tokens: $e");
    }
  }

  // ========== GESTIÓN DE PLANES (UPGRADES) ==========

  Future<void> upgradeToPremium() async {
    if (_user == null) return;
    await _updatePlan(UserPlan.premium);
  }

  Future<void> upgradeToMystic() async {
    if (_user == null) return;
    await _updatePlan(UserPlan.mystic);
  }

  Future<void> _updatePlan(UserPlan plan) async {
    try {
      _user = _user!.copyWith(plan: plan);
      notifyListeners();

      await _firestore.collection('users').doc(_user!.uid).update({
        'plan': plan.name,
      });
    } catch (e) {
      debugPrint("❌ Error al subir de plan: $e");
    }
  }

  // ========== PERFIL Y MANTENIMIENTO ==========

  Future<void> updateProfile({
    String? nickname,
    String? bio,
    int? age,
    List<String>? interests,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      displayName: nickname,
      bio: bio,
      age: age,
      interests: interests,
    );
    notifyListeners();

    await _firestore.collection('users').doc(_user!.uid).update(_user!.toMap());
  }

  // Reset diario: si el usuario entra un día distinto, le damos 10 tokens
  Future<void> _checkAndPerformDailyReset() async {
    if (_user == null || _user!.lastTokenUpdate == null) return;

    final now = DateTime.now();
    final lastUpdate = _user!.lastTokenUpdate!;

    if (now.day != lastUpdate.day ||
        now.month != lastUpdate.month ||
        now.year != lastUpdate.year) {
      await _syncTokensToFirebase(10);
    }
  }

  // Fetch user from Firestore
  Future<void> fetchUser(String uid) async {
    try {
      setLoading(true);
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!, uid);
        await _checkAndPerformDailyReset();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error al cargar perfil: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }

  // Método para actualizar todo el modelo de golpe
  Future<void> updateUser(UserModel user) async {
    _user = user;
    notifyListeners();
    await _firestore.collection('users').doc(_user!.uid).update(_user!.toMap());
  }
}
