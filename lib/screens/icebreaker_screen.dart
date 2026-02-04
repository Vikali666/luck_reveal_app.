import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:luck_reveal_app/models/user_model.dart';
import 'package:luck_reveal_app/models/icebreaker_card.dart';
import 'package:luck_reveal_app/providers/user_provider.dart';
import 'package:luck_reveal_app/services/gemini_service.dart';

class IcebreakerScreen extends StatefulWidget {
  final UserModel user;
  final UserProvider userProvider;

  const IcebreakerScreen({
    super.key,
    required this.user,
    required this.userProvider,
  });

  @override
  State<IcebreakerScreen> createState() => _IcebreakerScreenState();
}

class _IcebreakerScreenState extends State<IcebreakerScreen> {
  late ConfettiController _confettiController;
  final GeminiIcebreakerService _geminiService = GeminiIcebreakerService();

  CardCategory _selectedCategory = CardCategory.inicio;
  IcebreakerCard? _currentCard;
  bool _isLoading = false;

  // Cartas de ejemplo locales
  final List<IcebreakerCard> _fallbackCards = [
    IcebreakerCard(
      id: '1',
      text: '¿Qué te gusta hacer en tu tiempo libre?',
      category: CardCategory.inicio,
      emoji: '🎯',
      createdAt: DateTime.now(),
    ),
    IcebreakerCard(
      id: '2',
      text: '¿Cuál es tu serie favorita?',
      category: CardCategory.inicio,
      emoji: '📺',
      createdAt: DateTime.now(),
    ),
    IcebreakerCard(
      id: '3',
      text: '¿Comida que podrías comer todos los días?',
      category: CardCategory.medio,
      emoji: '🍕',
      createdAt: DateTime.now(),
    ),
    IcebreakerCard(
      id: '4',
      text: '¿Qué talento oculto tienes?',
      category: CardCategory.medio,
      emoji: '🔮',
      createdAt: DateTime.now(),
    ),
    IcebreakerCard(
      id: '5',
      text: '¿Verdad o reto con un giro inesperado?',
      category: CardCategory.picante,
      emoji: '😏',
      isPremium: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _currentCard = _fallbackCards[0];
  }

  Future<void> _nextCard() async {
    // Verificar si el usuario tiene cartas disponibles
    if (!widget.user.hasCardsLeft) {
      _showLimitReachedDialog();
      return;
    }

    // Verificar si la categoría está bloqueada para free
    if (_selectedCategory == CardCategory.picante && !widget.user.isPremium) {
      _showPremiumLockedDialog();
      return;
    }

    // Si no es premium, usar una carta
    if (!widget.user.isPremium) {
      widget.userProvider.useCard();
    }

    setState(() => _isLoading = true);

    try {
      // Intentar generar carta con IA
      final newCard =
          await _geminiService.generateDynamicCard(_selectedCategory);

      // Verificar si es premium
      if (newCard.isPremium && !widget.user.isPremium) {
        _showPremiumLockedDialog();
        return;
      }

      setState(() {
        _currentCard = newCard;
        _confettiController.play();
      });
    } catch (e) {
      // Fallback a cartas locales
      final nextIndex =
          (_fallbackCards.indexOf(_currentCard!) + 1) % _fallbackCards.length;
      final nextCard = _fallbackCards[nextIndex];

      if (nextCard.isPremium && !widget.user.isPremium) {
        _showPremiumLockedDialog();
        return;
      }

      setState(() {
        _currentCard = nextCard;
        _confettiController.play();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLimitReachedDialog() {
    final remainingTime = _calculateNextResetTime();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Límite alcanzado 🎯'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Has usado tus ${widget.user.dailyCardsLimit} cartas diarias!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (!widget.user.isPremium)
              Text(
                'Próximo reset: $remainingTime\n\n'
                '🎁 Ve a Actividades para ganar más cartas\n'
                '⭐ Conviértete en Premium para acceso ilimitado',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (!widget.user.isPremium)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navegar a actividades
              },
              child: const Text('Ver Actividades'),
            ),
        ],
      ),
    );
  }

  String _calculateNextResetTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  void _showPremiumLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contenido Premium 🔒'),
        content: const Text(
            'Esta categoría solo está disponible para usuarios Premium o Mystic'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.userProvider.upgradeToPremium();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '⭐ ¡Ahora eres Premium! Desbloquea todo el contenido'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Hacerme Premium'),
          ),
        ],
      ),
    );
  }

  void _filterByCategory(CardCategory category) {
    if (category == CardCategory.picante && !widget.user.isPremium) {
      _showPremiumLockedDialog();
      return;
    }

    setState(() => _selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumLocked =
        _currentCard?.isPremium == true && !widget.user.isPremium;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Icebreaker 🎴'),
            actions: [
              // Mostrar plan del usuario
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: widget.user.planColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: widget.user.planColor),
                ),
                child: Row(
                  children: [
                    Icon(widget.user.planIcon,
                        size: 16, color: widget.user.planColor),
                    const SizedBox(width: 6),
                    Text(
                      widget.user.isPremium
                          ? 'ILIMITADO'
                          : '${widget.user.remainingCards}',
                      style: TextStyle(
                        color: widget.user.planColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _nextCard,
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF000814),
                  Color(0xFF003566),
                  Color(0xFF001D3D),
                ],
              ),
            ),
            child: Column(
              children: [
                // Contador de cartas
                _buildCardCounter(),

                // Selector de categorías
                _buildCategorySelector(),

                // Carta
                Expanded(
                  child: _isLoading
                      ? _buildLoadingAnimation()
                      : _buildCurrentCard(isPremiumLocked),
                ),

                // Botones de acción
                _buildActionButtons(),
              ],
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.pink, Colors.blue, Colors.purple],
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCardCounter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cartas ${widget.user.isPremium ? "Ilimitadas" : "Restantes"}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                widget.user.isPremium
                    ? '∞'
                    : '${widget.user.remainingCards}/${widget.user.dailyCardsLimit}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.user.isPremium ? Colors.green : Colors.white,
                ),
              ),
              if (!widget.user.isPremium && widget.user.remainingCards == 0)
                Text(
                  'Reset: ${_calculateNextResetTime()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade300,
                  ),
                ),
            ],
          ),
          if (!widget.user.isPremium && widget.user.remainingCards < 3)
            ElevatedButton.icon(
              onPressed: () {
                widget.userProvider.addCards(5);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 ¡Ganaste 5 cartas extra!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.bolt),
              label: const Text('+5 Cartas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCategoryButton(
              'Rompehielos 🎯', CardCategory.inicio, Colors.blue),
          _buildCategoryButton(
              'Profundizando 💭', CardCategory.medio, Colors.purple),
          _buildCategoryButton(
              'Calentando 🔥', CardCategory.picante, Colors.pink),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
      String label, CardCategory category, Color color) {
    final isSelected = _selectedCategory == category;
    final isLocked = category == CardCategory.picante && !widget.user.isPremium;

    return GestureDetector(
      onTap: isLocked ? null : () => _filterByCategory(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : isLocked
                  ? Colors.grey.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            if (isLocked) const Icon(Icons.lock, size: 14, color: Colors.grey),
            if (isLocked) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isLocked
                        ? Colors.grey
                        : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 20),
          Text(
            widget.user.isMystic
                ? 'El oráculo consulta las estrellas... 🔮'
                : 'Generando pregunta mística...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          if (widget.user.isMystic) const SizedBox(height: 10),
          Text(
            'IA avanzada en acción',
            style: TextStyle(
              color: Colors.purple.shade300,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCard(bool isPremiumLocked) {
    return Center(
      child: GestureDetector(
        onTap: isPremiumLocked ? null : _nextCard,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: isPremiumLocked
                ? Colors.grey.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isPremiumLocked
                  ? Colors.red
                  : Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPremiumLocked)
                const Column(
                  children: [
                    Icon(Icons.lock, size: 50, color: Colors.red),
                    SizedBox(height: 20),
                    Text(
                      'SOLO PREMIUM 🔒',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              Text(
                _currentCard?.emoji ?? '🃏',
                style: const TextStyle(fontSize: 60),
              ),

              const SizedBox(height: 30),

              Text(
                _currentCard?.text ?? 'Toca para comenzar',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: (_currentCard?.categoryColor ?? Colors.blue)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (_currentCard?.categoryColor ?? Colors.blue)
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _currentCard?.categoryName ?? 'ROMPEHIELOS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Badge de IA si fue generada
              if (_currentCard?.isAIGenerated == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.user.isMystic
                            ? Icons.auto_awesome
                            : Icons.psychology,
                        size: 12,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.user.isMystic
                            ? 'ORÁCULO MÍSTICO'
                            : 'GENERADO POR IA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              if (!isPremiumLocked)
                Text(
                  'Toca para siguiente carta',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.1),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            onPressed: _currentCard != null
                ? () {
                    // Enviar al chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('"${_currentCard!.text}" enviado al chat 🎯'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Enviar en Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          if (!widget.user.isPremium)
            ElevatedButton.icon(
              onPressed: () {
                widget.userProvider.addCards(3);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('🎉 ¡Ganaste 3 cartas extra viendo un anuncio!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              icon: const Icon(Icons.ads_click),
              label: const Text('Ganar +3'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}
