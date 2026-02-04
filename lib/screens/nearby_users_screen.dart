import 'package:flutter/material.dart';
import '../../utils/luck_reveal_theme.dart';
import '../../widgets/nearby/radar_header.dart';
import '../../widgets/nearby/user_card.dart';
import '../../widgets/gold_dust_particles.dart';

class NearbyUsersScreen extends StatefulWidget {
  const NearbyUsersScreen({super.key});

  @override
  State<NearbyUsersScreen> createState() => _NearbyUsersScreenState();
}

class _NearbyUsersScreenState extends State<NearbyUsersScreen> {
  // LISTA MAESTRA (La fuente de todo)
  final List<Map<String, dynamic>> _allUsers = [
    {
      'name': 'Valentina',
      'age': 24,
      'distance': 2.1,
      'interests': ['Viajes', 'Sushi', 'Cine'],
      'photoUrl': 'https://i.pravatar.cc/300?img=1',
      'compatibility': 85,
      'isRevealed': false,
    },
    {
      'name': 'Camila',
      'age': 22,
      'distance': 0.5,
      'interests': ['Arte', 'Fiesta', 'Moda'],
      'photoUrl': 'https://i.pravatar.cc/300?img=5',
      'compatibility': 95,
      'isRevealed': false,
    },
    {
      'name': 'Sofía',
      'age': 26,
      'distance': 5.0,
      'interests': ['Fitness', 'Lectura'],
      'photoUrl': 'https://i.pravatar.cc/300?img=9',
      'compatibility': 70,
      'isRevealed': false,
    },
  ];

  // Esta es la lista que se filtrará en pantalla
  List<Map<String, dynamic>> _currentUsers = [];
  int _userTokens = 3;

  @override
  void initState() {
    super.initState();
    _currentUsers = List.from(_allUsers); // Al empezar, mostramos todos
  }

  void _handleReveal(int index) {
    if (_userTokens > 0) {
      if (_currentUsers[index]['isRevealed']) return;
      setState(() {
        _userTokens--;
        _currentUsers[index]['isRevealed'] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Foto Revelada! -1 Token")),
      );
    } else {
      _showNoTokensDialog();
    }
  }

  // --- ESTA ES LA LÓGICA QUE FALTABA ---
  void _filterByDistance(double km) {
    setState(() {
      _currentUsers = _allUsers
          .where((user) => (user['distance'] as double) <= km)
          .toList();
    });
  }

  void _handleMatch(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✨ ¡Es un Match! Enviando notificación...")),
    );
  }

  void _showNoTokensDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: LuckRevealTheme.background,
        title: const Text("Sin Tokens", style: TextStyle(color: Colors.white)),
        content: const Text("Necesitas más tokens para revelar fotos.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: LuckRevealTheme.accent),
            onPressed: () => Navigator.pop(context),
            child: const Text("Conseguir Tokens",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuckRevealTheme.background,
      body: Stack(
        children: [
          const Positioned.fill(child: GoldDustParticles()),
          SafeArea(
            child: Column(
              children: [
                RadarHeader(
                  visibleUsers: _currentUsers.length,
                  maxUsers: _allUsers.length,
                  onDistanceChanged: (km) => _filterByDistance(
                      km as double), // AQUÍ SE ACTIVA EL FILTRO
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _currentUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final card = UserCard(
                        userData: {
                          ..._currentUsers[index],
                          'distance':
                              "${_currentUsers[index]['distance']} km" // Volvemos a ponerle el texto "km" para la UI
                        },
                        onReveal: () => _handleReveal(index),
                        onMatch: () => _handleMatch(index),
                      );

                      if (index == 1) {
                        return Column(children: [
                          _buildPromoBanner(),
                          const SizedBox(height: 20),
                          card
                        ]);
                      }
                      return card;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double km(int km) => km as double;

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LuckRevealTheme.goldGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.casino, color: Colors.black),
          SizedBox(width: 12),
          Expanded(
              child: Text("🎰 GIRA LA RULETA PARA +3 TOKENS",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold))),
          Icon(Icons.arrow_forward, color: Colors.black),
        ],
      ),
    );
  }
}
