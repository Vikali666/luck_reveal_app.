import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luck_reveal_app/models/user_model.dart';
import 'package:luck_reveal_app/providers/user_provider.dart';

// Importaciones de tus otras pantallas
import 'icebreaker_screen.dart';
import 'streak_screen.dart';
import 'activities_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Escuchamos al UserProvider para que toda la Home reaccione a cambios
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser; // Cambiado de 'user' a 'currentUser'

    // Si el usuario es nulo (aún cargando), mostramos un loader místico
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.pink)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _getCurrentScreen(user, userProvider),
      bottomNavigationBar: _buildBottomNavigationBar(user),
    );
  }

  Widget _getCurrentScreen(UserModel user, UserProvider userProvider) {
    switch (_selectedIndex) {
      case 0:
        return _buildDiscoverScreen(user, userProvider);
      case 1:
        // CORREGIDO: Pasamos user y userProvider
        return IcebreakerScreen(user: user, userProvider: userProvider);
      case 2:
        return const StreakScreen();
      case 3:
        return _buildProfileScreen(user, userProvider);
      default:
        return _buildDiscoverScreen(user, userProvider);
    }
  }

  // --- PANTALLA DE DESCUBRIMIENTO (DASHBOARD) ---
  Widget _buildDiscoverScreen(UserModel user, UserProvider userProvider) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Luck Reveal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // Contador de Tokens dinámico
          _buildTokenBadge(user),
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar con Glow místico según el plan
            _buildMisticAvatar(user),
            const SizedBox(height: 20),
            Text(
                '¡Hola, ${user.nickname}!', // Cambiado de displayName a nickname
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            _buildPlanTag(user),
            const SizedBox(height: 30),

            // Botón Principal de Juego
            _buildMainActionButton(
              title: 'Jugar Icebreaker',
              subtitle: user.isPremium
                  ? 'Acceso Ilimitado'
                  : '${user.remainingCards} cartas restantes', // Cambiado de dailyTokens a remainingCards
              icon: Icons.icecream,
              color: Colors.pink,
              onTap: () => setState(() => _selectedIndex = 1),
            ),

            // Si no es premium, mostrar ofertas de cartas
            if (!user.isPremium) ...[
              const SizedBox(height: 15),
              _buildMainActionButton(
                title: 'Obtener +5 Cartas',
                subtitle: 'Mira un video corto',
                icon: Icons.ads_click,
                color: Colors.orange,
                onTap: () {
                  userProvider.addCards(5);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 ¡Ganaste 5 cartas extra!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildMainActionButton(
                title: 'Hacerme Premium',
                subtitle: 'Acceso ilimitado a todo',
                icon: Icons.workspace_premium,
                color: Colors.orange,
                onTap: () {
                  userProvider.upgradeToPremium();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⭐ ¡Ahora eres Premium!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ],

            // Si es premium, mostrar opciones especiales
            if (user.isPremium) ...[
              const SizedBox(height: 15),
              _buildMainActionButton(
                title: 'Modo Mystic',
                subtitle: 'Experiencia IA avanzada',
                icon: Icons.auto_awesome,
                color: Colors.purple,
                onTap: () {
                  userProvider.upgradeToMystic();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔮 ¡Activado Modo Mystic!'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 30),

            // Acceso rápido a otras secciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    icon: Icons.workspace_premium,
                    label: 'Racha',
                    color: Colors.orange,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _buildQuickAction(
                    icon: Icons.games,
                    label: 'Actividades',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActivitiesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.settings,
                    label: 'Ajustes',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DE ESTILO ---

  Widget _buildTokenBadge(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.deck, color: Colors.blue, size: 16),
          const SizedBox(width: 5),
          Text(user.isPremium ? '∞' : '${user.remainingCards}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMisticAvatar(UserModel user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: user.planColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5),
            ],
          ),
        ),
        CircleAvatar(
          radius: 65,
          backgroundColor: const Color(0xFF1E1E1E),
          child: Icon(user.planIcon, size: 60, color: user.planColor),
        ),
      ],
    );
  }

  Widget _buildPlanTag(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: user.planColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: user.planColor),
      ),
      child: Text(user.planName,
          style: TextStyle(color: user.planColor, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMainActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  // --- BARRA DE NAVEGACIÓN ---
  BottomNavigationBar _buildBottomNavigationBar(UserModel user) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF121212),
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
            icon: Icon(Icons.explore), label: 'Inicio'),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${user.remainingCards}'),
            isLabelVisible: !user.isPremium,
            child: const Icon(Icons.icecream),
          ),
          label: 'Icebreaker',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Racha'),
        BottomNavigationBarItem(
            icon: Icon(user.planIcon, color: user.planColor), label: 'Perfil'),
      ],
    );
  }

  // --- PANTALLA DE PERFIL (SIMPLIFICADA) ---
  Widget _buildProfileScreen(UserModel user, UserProvider userProvider) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mi Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showEditProfileDialog(user, userProvider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                _buildMisticAvatar(user),
                const SizedBox(height: 20),
                Text(user.nickname,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildPlanTag(user),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(user.bio!,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Estadísticas
          Card(
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estadísticas',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          'Cartas Hoy',
                          user.isPremium
                              ? '∞'
                              : '${user.remainingCards}/${user.dailyCardsLimit}'),
                      _buildStatItem('Plan', user.planName),
                      _buildStatItem('Desde',
                          'Reinicia: ${user.lastReset?.day ?? ''}/${user.lastReset?.month ?? ''}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Opciones
          Card(
            color: const Color(0xFF1E1E1E),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.workspace_premium, color: Colors.orange),
                  title: const Text('Racha Diaria',
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                const Divider(color: Colors.grey, height: 1),
                ListTile(
                  leading: const Icon(Icons.games, color: Colors.purple),
                  title: const Text('Actividades',
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActivitiesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.grey, height: 1),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.grey),
                  title: const Text('Configuración',
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
                const Divider(color: Colors.grey, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión',
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    // Cerrar sesión
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.pink, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _showEditProfileDialog(UserModel user, UserProvider userProvider) {
    final nicknameController = TextEditingController(text: user.nickname);
    final bioController = TextEditingController(text: user.bio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title:
            const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Apodo',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: 'Ej: Viajero del Destino',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Biografía',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: 'Cuéntanos sobre ti...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.updateProfile(
                nickname: nicknameController.text,
                bio: bioController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado ✅'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
