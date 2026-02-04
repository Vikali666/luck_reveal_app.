import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Gratis 🎮'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActivityCard(
            icon: Icons.ads_click,
            title: 'Ver Anuncio',
            description: 'Mira un anuncio de 30 segundos',
            reward: '+5 Cartas Icebreaker',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            icon: Icons.quiz,
            title: 'Trivia de Amor',
            description: 'Responde 5 preguntas sobre citas',
            reward: '+3 Super Likes',
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            icon: Icons.groups,
            title: 'Invitar Amigos',
            description: 'Invita a 3 amigos a la app',
            reward: '+7 días de Boost',
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildActivityCard(
            icon: Icons.star,
            title: 'Completar Perfil',
            description: 'Agrega 3 fotos y completa tu bio',
            reward: '+10 Likes Diarios',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String description,
    required String reward,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reward,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Comenzar actividad
              },
              child: const Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }
}
