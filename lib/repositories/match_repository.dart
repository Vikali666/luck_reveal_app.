// lib/repositories/match_repository.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class MatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  Future<Map<String, dynamic>> getFreeMatch(String currentUserId) async {
    try {
      // 1. Get current user
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        return {'error': 'Usuario no encontrado'};
      }

      final currentUser = UserModel.fromMap(userDoc.data()!);

      // 2. Check daily limit for free users
      if (!currentUser.isPaid) {
        if (!_canMatchToday(currentUser)) {
          return {
            'error':
                'Límite diario alcanzado. Vuelve mañana o actualiza a PAID.',
          };
        }
      }

      // 3. Get potential matches
      List<UserModel> potentialMatches;

      if (currentUser.isPaid && currentUser.preferences != null) {
        // PAID: Apply filters
        potentialMatches = await _getFilteredMatches(currentUser);
      } else {
        // FREE: Get random users
        potentialMatches = await _getRandomUsers(currentUserId);
      }

      if (potentialMatches.isEmpty) {
        return {'error': 'No hay usuarios disponibles en este momento'};
      }

      // 4. Select match
      final matchedUser =
          potentialMatches[_random.nextInt(potentialMatches.length)];

      // 5. Create match record
      final matchId = _firestore.collection('matches').doc().id;
      await _firestore.collection('matches').doc(matchId).set({
        'id': matchId,
        'users': [currentUserId, matchedUser.uid],
        'createdAt': Timestamp.now(),
        'isFreeMatch': !currentUser.isPaid,
        'requiresAd': !currentUser.isPaid,
        'status': 'pending',
      });

      // 6. Update user's daily count if free
      if (!currentUser.isPaid) {
        await _firestore.collection('users').doc(currentUserId).update({
          'dailyMatches': FieldValue.increment(1),
          'lastMatchReset': Timestamp.now(),
        });
      }

      // 7. Create chat
      final chatId = await _createChat(matchId, currentUserId, matchedUser.uid);

      return {
        'success': true,
        'matchId': matchId,
        'chatId': chatId,
        'matchedUser': matchedUser,
        'requiresAd': !currentUser.isPaid,
        'isFreeMatch': !currentUser.isPaid,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting match: $e');
      }
      return {'error': 'Error al buscar match: $e'};
    }
  }

  Future<List<UserModel>> _getFilteredMatches(UserModel currentUser) async {
    final prefs = currentUser.preferences!;

    try {
      // Primero obtenemos todos los usuarios (excepto el actual)
      final snapshot = await _firestore
          .collection('users')
          .where('uid', isNotEqualTo: currentUser.uid)
          .limit(200) // Más usuarios para filtrar después
          .get();

      // Filtramos manualmente
      final filteredUsers = snapshot.docs.where((doc) {
        final userData = doc.data();

        // 1. Filtro de edad
        final userAge = userData['age'] as int? ?? 0;
        if (userAge < prefs.minAge || userAge > prefs.maxAge) {
          return false;
        }

        // 2. Filtro de distancia
        if (prefs.maxDistance > 0 && currentUser.location != null) {
          final userLocation = userData['location'] as GeoPoint?;
          if (userLocation == null) return false;

          final distance = _calculateDistance(
            currentUser.location!.latitude,
            currentUser.location!.longitude,
            userLocation.latitude,
            userLocation.longitude,
          );

          if (distance > prefs.maxDistance) {
            return false;
          }
        }

        // 3. Filtro de intereses (si hay intereses seleccionados)
        if (prefs.interests.isNotEmpty) {
          final userInterests = List<String>.from(
            userData['selectedInterests'] ?? [],
          );
          final hasCommonInterest = userInterests.any(
            (interest) => prefs.interests.contains(interest),
          );
          if (!hasCommonInterest) {
            return false;
          }
        }

        // 4. Filtro de intención
        if (prefs.intent.isNotEmpty) {
          final userPrefs = userData['preferences'] as Map<String, dynamic>?;
          final userIntent = userPrefs?['intent'] as String? ?? '';
          if (userIntent != prefs.intent) {
            return false;
          }
        }

        // 5. Filtros avanzados (solo para PAID)
        if (prefs.hasAdvancedFilters && prefs.advancedFilters != null) {
          final adv = prefs.advancedFilters!;

          // Filtro de altura
          if (adv.minHeight != null || adv.maxHeight != null) {
            final userHeight = userData['height'] as int?;
            if (userHeight == null) return false;

            if (adv.minHeight != null && userHeight < adv.minHeight!) {
              return false;
            }
            if (adv.maxHeight != null && userHeight > adv.maxHeight!) {
              return false;
            }
          }

          // Filtro de ejercicio
          if (adv.exercises != null) {
            final userExercises = userData['exercises'] as bool?;
            if (userExercises != adv.exercises) {
              return false;
            }
          }

          // Filtro de fumador
          if (adv.smoker != null) {
            final userSmoker = userData['smoker'] as bool?;
            if (userSmoker != adv.smoker) {
              return false;
            }
          }

          // Filtro de educación
          if (adv.educationLevel != null && adv.educationLevel!.isNotEmpty) {
            final userEducation = userData['educationLevel'] as String? ?? '';
            if (userEducation != adv.educationLevel) {
              return false;
            }
          }

          // Filtro de religión
          if (adv.religion != null && adv.religion!.isNotEmpty) {
            final userReligion = userData['religion'] as String? ?? '';
            if (userReligion != adv.religion) {
              return false;
            }
          }
        }

        return true;
      }).map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();

      return filteredUsers;
    } catch (e) {
      if (kDebugMode) {
        print('Error filtering matches: $e');
      }
      return [];
    }
  }

  Future<List<UserModel>> _getRandomUsers(String currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting random users: $e');
      }
      return [];
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  bool _canMatchToday(UserModel user) {
    final now = DateTime.now();
    final lastReset = user.lastMatchReset;

    if (lastReset == null) return true; // Never matched before

    // Reset counter if it's a new day
    if (now.day != lastReset.day ||
        now.month != lastReset.month ||
        now.year != lastReset.year) {
      return true;
    }

    return user.dailyMatches < 3;
  }

  Future<String> _createChat(
    String matchId,
    String user1Id,
    String user2Id,
  ) async {
    final chatId = _firestore.collection('chats').doc().id;

    await _firestore.collection('chats').doc(chatId).set({
      'id': chatId,
      'matchId': matchId,
      'participants': [user1Id, user2Id],
      'createdAt': Timestamp.now(),
      'lastMessage': '',
      'lastMessageTime': Timestamp.now(),
      'unreadCount': {user1Id: 0, user2Id: 0},
    });

    // Update match with chat ID
    await _firestore.collection('matches').doc(matchId).update({
      'chatId': chatId,
    });

    return chatId;
  }

  // Método para usuarios cercanos (Cerca de ti)
  Future<List<UserModel>> getNearbyUsers(
    String currentUserId,
    GeoPoint location,
    int radiusKm,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .limit(100)
          .get();

      // Filtramos por distancia
      final nearbyUsers = snapshot.docs.where((doc) {
        final userData = doc.data();
        final userLocation = userData['location'] as GeoPoint?;

        if (userLocation == null) return false;

        final distance = _calculateDistance(
          location.latitude,
          location.longitude,
          userLocation.latitude,
          userLocation.longitude,
        );

        return distance <= radiusKm;
      }).map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();

      // Ordenamos por distancia más cercana
      nearbyUsers.sort((a, b) {
        if (a.location == null) return 1;
        if (b.location == null) return -1;

        final distanceA = _calculateDistance(
          location.latitude,
          location.longitude,
          a.location!.latitude,
          a.location!.longitude,
        );

        final distanceB = _calculateDistance(
          location.latitude,
          location.longitude,
          b.location!.latitude,
          b.location!.longitude,
        );

        return distanceA.compareTo(distanceB);
      });

      return nearbyUsers;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nearby users: $e');
      }
      return [];
    }
  }

  Future<void> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'preferences': preferences.toMap(),
    });
  }

  Future<int> getRemainingFreeMatches(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return 0;

    final user = UserModel.fromMap(userDoc.data()!);

    if (user.isPaid) {
      return 999; // Unlimited for paid
    }

    if (!_canMatchToday(user)) {
      return 0;
    }

    return 3 - user.dailyMatches;
  }

  // Método para actualizar la ubicación del usuario
  Future<void> updateUserLocation(String userId, GeoPoint location) async {
    await _firestore.collection('users').doc(userId).update({
      'location': location,
      'lastLocationUpdate': Timestamp.now(),
    });
  }

  // Método para obtener matches activos de un usuario
  Future<List<Map<String, dynamic>>> getUserMatches(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('users', arrayContains: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final matches = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final matchData = doc.data();
        final otherUserId = (matchData['users'] as List).firstWhere(
          (id) => id != userId,
          orElse: () => null,
        );

        if (otherUserId == null) continue;

        // Get other user info
        final otherUserDoc =
            await _firestore.collection('users').doc(otherUserId).get();
        if (otherUserDoc.exists) {
          matches.add({
            'matchId': doc.id,
            'matchData': matchData,
            'otherUser': UserModel.fromMap(otherUserDoc.data()!),
          });
        }
      }

      return matches;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user matches: $e');
      }
      return [];
    }
  }

  // Método para aceptar/rechazar match
  Future<void> updateMatchStatus(String matchId, String status) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }
}
