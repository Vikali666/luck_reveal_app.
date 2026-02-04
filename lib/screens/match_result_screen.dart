import 'package:flutter/material.dart';
import 'package:luck_reveal_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:luck_reveal_app/models/user_model.dart';

// Añade estos imports si no los tienes
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp si usas Firestore

// Enums necesarios
enum RelationshipStage { iceBreaker, gettingCloser, deepConnection, revelation }

enum ChatType { freeTest, paidFull, premiumUnlimited }

// Clase ChatModel
class ChatModel {
  final String id;
  final String? matchId;
  final List<String> participants;
  final RelationshipStage stage;
  final ChatType chatType;
  final Map<String, Map<String, double>> revelationProgress;
  final Map<String, int> dailyTokens;
  final Map<String, int> messageCounts;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    this.matchId,
    required this.participants,
    required this.stage,
    required this.chatType,
    required this.revelationProgress,
    required this.dailyTokens,
    required this.messageCounts,
    required this.createdAt,
  });

  // Constructor de fábrica desde Firestore
  factory ChatModel.fromFirestore(Map<String, dynamic> data) {
    return ChatModel(
      id: data['id'] ?? '',
      matchId: data['matchId'],
      participants: List<String>.from(data['participants'] ?? []),
      stage: RelationshipStage.values[data['stage'] ?? 0],
      chatType: ChatType.values[data['chatType'] ?? 0],
      revelationProgress: Map<String, Map<String, double>>.from(
        (data['revelationProgress'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            Map<String, double>.from(value),
          ),
        ),
      ),
      dailyTokens: Map<String, int>.from(data['dailyTokens'] ?? {}),
      messageCounts: Map<String, int>.from(data['messageCounts'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'matchId': matchId,
      'participants': participants,
      'stage': stage.index,
      'chatType': chatType.index,
      'revelationProgress': revelationProgress,
      'dailyTokens': dailyTokens,
      'messageCounts': messageCounts,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class MatchResultScreen extends StatefulWidget {
  final Map<String, dynamic> matchResult;
  final UserModel matchedUser;

  const MatchResultScreen({
    super.key,
    required this.matchResult,
    required this.matchedUser,
  });

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  bool _creatingChat = false;
  bool _chatCreated = false;
  String? _chatId;
  ChatModel? _chatModel;

  // Método para crear chat premium
  ChatModel _createFullChat(String user1Id, String user2Id, String? matchId) {
    final chatId = 'chat_${DateTime.now().millisecondsSinceEpoch}';

    return ChatModel(
      id: chatId,
      matchId: matchId,
      participants: [user1Id, user2Id],
      stage: RelationshipStage.iceBreaker,
      chatType: ChatType.paidFull,
      revelationProgress: {
        user1Id: {'photos': 1.0, 'info': 1.0},
        user2Id: {'photos': 1.0, 'info': 1.0},
      },
      dailyTokens: {user1Id: 20, user2Id: 20},
      messageCounts: {user1Id: 0, user2Id: 0},
      createdAt: DateTime.now(),
    );
  }

  // Método para crear chat de prueba
  ChatModel _createTestChat(String user1Id, String user2Id, String? matchId) {
    final chatId = 'test_chat_${DateTime.now().millisecondsSinceEpoch}';

    return ChatModel(
      id: chatId,
      matchId: matchId,
      participants: [user1Id, user2Id],
      stage: RelationshipStage.iceBreaker,
      chatType: ChatType.freeTest,
      revelationProgress: {
        user1Id: {'photos': 0.3, 'info': 0.5},
        user2Id: {'photos': 0.3, 'info': 0.5},
      },
      dailyTokens: {user1Id: 3, user2Id: 3},
      messageCounts: {user1Id: 0, user2Id: 0},
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchResult = widget.matchResult;
    final matchedUser = widget.matchedUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    '¡MATCH!',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Animación de confeti
                    const Icon(
                      Icons.celebration,
                      size: 100,
                      color: Colors.yellow,
                    ),
                    const SizedBox(height: 30),

                    // Avatar del match
                    CircleAvatar(
                      radius: 80,
                      backgroundColor:
                          matchedUser.planColor.withValues(alpha: 0.2),
                      child: Icon(
                        matchedUser.planIcon,
                        size: 80,
                        color: matchedUser.planColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nombre y plan
                    Text(
                      matchedUser.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: matchedUser.planColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: matchedUser.planColor),
                      ),
                      child: Text(
                        matchedUser.planName,
                        style: TextStyle(
                          color: matchedUser.planColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Biografía
                    if (matchedUser.bio != null && matchedUser.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          matchedUser.bio!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),

                    // Estadísticas del match
                    if (matchResult['compatibilityScore'] != null)
                      _buildCompatibilityCard(matchResult),

                    const SizedBox(height: 40),

                    // Botones de acción
                    if (!_chatCreated)
                      _buildActionButtons(matchResult, matchedUser),

                    if (_chatCreated && _chatId != null)
                      _buildChatReadyButton(matchedUser),

                    if (_creatingChat)
                      const CircularProgressIndicator(color: Colors.yellow),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityCard(Map<String, dynamic> matchResult) {
    final compatibility = matchResult['compatibilityScore'] ?? 75;
    final commonInterests = matchResult['commonInterests']?.length ?? 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow),
      ),
      child: Column(
        children: [
          // Barra de compatibilidad
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compatibilidad: $compatibility%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: compatibility / 100,
                      backgroundColor: Colors.grey[800],
                      color: _getCompatibilityColor(compatibility),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Intereses comunes
          Row(
            children: [
              const Icon(Icons.celebration, color: Colors.amber),
              const SizedBox(width: 10),
              Text(
                'Intereses comunes: $commonInterests/5',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Química
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.orange),
              const SizedBox(width: 10),
              Text(
                'Química: ${_getChemistryLevel(compatibility)}',
                style: TextStyle(
                  color: _getChemistryColor(compatibility),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCompatibilityColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.yellow;
    return Colors.orange;
  }

  String _getChemistryLevel(int score) {
    if (score >= 80) return 'Alta ⚡';
    if (score >= 60) return 'Media 🔥';
    return 'Baja 💤';
  }

  Color _getChemistryColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActionButtons(
      Map<String, dynamic> matchResult, UserModel matchedUser) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;
    final isFreeMatch = !(currentUser?.isPremium ?? false);
    final requiresAd = isFreeMatch;

    return Column(
      children: [
        // Botón principal: Iniciar chat
        ElevatedButton.icon(
          icon: const Icon(Icons.chat),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            child: Text(
              'INICIAR CHAT',
              style: TextStyle(fontSize: 18),
            ),
          ),
          onPressed:
              _creatingChat ? null : () => _startChat(matchResult, matchedUser),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
          ),
        ),
        const SizedBox(height: 20),

        // Info para free users
        if (isFreeMatch)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'CHAT FREE',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 20 mensajes diarios\n'
                  '• Fotos se revelan gradualmente\n'
                  '• 3 tokens gratis al día\n'
                  '• Chat de prueba de 5 minutos',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                if (requiresAd)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.ads_click),
                    label: const Text('VER ANUNCIO PARA CHAT COMPLETO'),
                    onPressed: () => _watchAdForChat(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
              ],
            ),
          ),

        // Botón para paid users
        if (!isFreeMatch)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'CHAT PREMIUM',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '✅ Mensajes ilimitados\n'
                  '✅ Fotos visibles inmediatamente\n'
                  '✅ Videochat disponible\n'
                  '✅ Sin anuncios',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Invitar a premium
                  },
                  child: const Text('INVITAR A PREMIUM'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChatReadyButton(UserModel matchedUser) {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 60, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          '¡Chat listo!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Conecta con ${matchedUser.nickname}',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          icon: const Icon(Icons.chat_bubble),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            child: Text(
              'IR AL CHAT',
              style: TextStyle(fontSize: 18),
            ),
          ),
          onPressed: () => _goToChat(matchedUser),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startChat(
      Map<String, dynamic> matchResult, UserModel matchedUser) async {
    setState(() => _creatingChat = true);

    try {
      final currentUser =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      final currentUserId = currentUser?.id;
      final matchedUserId = matchedUser.id;

      if (currentUserId == null) {
        throw Exception('IDs de usuario no disponibles');
      }

      ChatModel chat;

      if (currentUser?.isPremium ?? false) {
        // Chat premium completo
        chat = _createFullChat(
            currentUserId, matchedUserId, matchResult['matchId']);
      } else {
        // Chat de prueba para free users
        chat = _createTestChat(
            currentUserId, matchedUserId, matchResult['matchId']);
      }

      // Aquí deberías guardar el chat en tu base de datos (Firestore, etc.)
      // Ejemplo:
      // await FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chat.id)
      //     .set(chat.toFirestore());

      setState(() {
        _chatModel = chat;
        _chatId = chat.id;
        _chatCreated = true;
        _creatingChat = false;
      });

      // Mostrar mensaje de éxito
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (currentUser!.isPremium)
                ? '💎 Chat premium creado con ${matchedUser.nickname}!'
                : '🎯 Chat de prueba iniciado. ¡Envía tu primer mensaje!',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.purple,
        ),
      );
    } catch (e) {
      setState(() => _creatingChat = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _watchAdForChat() async {
    // Simular ver anuncio
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Publicidad', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ads_click, size: 50, color: Colors.amber),
            SizedBox(height: 20),
            Text('Viendo anuncio...', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.amber),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pop(context);

    // Dar recompensa por ver anuncio
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.addCards(5); // +5 cartas de Icebreaker

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 +5 cartas ganadas por ver anuncio!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _goToChat(UserModel matchedUser) {
    if (_chatId == null || _chatModel == null) return;

    // Navegar a pantalla de chat
    // Ejemplo:
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatScreen(
    //       chatModel: _chatModel!,
    //       matchedUser: matchedUser,
    //       currentUser: currentUser!,
    //     ),
    //   ),
    // );

    // Por ahora mostramos un SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Iniciando chat con ${matchedUser.nickname}...',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.purple,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
