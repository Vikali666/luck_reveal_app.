import 'package:flutter/material.dart'
    show
        Alignment,
        Badge,
        Border,
        BorderRadius,
        BottomNavigationBar,
        BottomNavigationBarItem,
        BottomNavigationBarType,
        BoxDecoration,
        BoxShadow,
        BoxShape,
        BuildContext,
        Center,
        CircleAvatar,
        Color,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        CustomScrollView,
        EdgeInsets,
        ElevatedButton,
        Expanded,
        FlexibleSpaceBar,
        FontWeight,
        GestureDetector,
        Icon,
        IconButton,
        Icons,
        LinearGradient,
        MainAxisAlignment,
        MainAxisSize,
        MaterialPageRoute,
        Navigator,
        Row,
        Scaffold,
        ScaffoldMessenger,
        SizedBox,
        SliverAppBar,
        SliverChildListDelegate,
        SliverList,
        SliverPadding,
        SnackBar,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        Widget;
import 'package:provider/provider.dart';
import 'package:luck_reveal_app/models/user_model.dart';
import 'package:luck_reveal_app/providers/user_provider.dart';
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
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: _getCurrentScreen(user, userProvider),
      bottomNavigationBar: _buildModernBottomNavBar(user),
    );
  }

  Widget _getCurrentScreen(UserModel user, UserProvider userProvider) {
    switch (_selectedIndex) {
      case 0:
        return _buildModernHomeScreen(user, userProvider);
      case 1:
        return IcebreakerScreen(user: user, userProvider: userProvider);
      case 2:
        return const StreakScreen();
      case 3:
        return _buildModernProfileScreen(user, userProvider);
      default:
        return _buildModernHomeScreen(user, userProvider);
    }
  }

  Widget _buildModernHomeScreen(UserModel user, UserProvider userProvider) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Buenos días'
        : hour < 19
            ? 'Buenas tardes'
            : 'Buenas noches';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E21),
            Color(0xFF1A1F38),
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          // AppBar moderna
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.pink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 10),
            ),
            actions: [
              // Contador de cartas
              Container(
                margin: const EdgeInsets.only(right: 10, top: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.deck, color: Colors.blue, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      user.isPremium ? '∞' : '${user.remainingCards}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey.shade300,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
            ],
          ),

          // Contenido principal
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Tarjeta de bienvenida
                _buildWelcomeCard(user),
                const SizedBox(height: 25),

                // Icebreaker destacado
                _buildIcebreakerCard(user, userProvider),
                const SizedBox(height: 25),

                // Actividades
                _buildActivitiesCard(),
                const SizedBox(height: 25),

                // Plan actual
                _buildPlanCard(user, userProvider),
                const SizedBox(height: 25),

                // Estadísticas rápidas
                _buildQuickStats(user),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.2),
            Colors.purple.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: user.planColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  user.planIcon,
                  color: user.planColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.planName,
                      style: TextStyle(
                        color: user.planColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user.isPremium
                          ? 'Tienes acceso completo 🎉'
                          : '${user.remainingCards} cartas disponibles hoy',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIcebreakerCard(UserModel user, UserProvider userProvider) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 1),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A1F38),
              Color(0xFF2D1B69),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.icecream,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Icebreaker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.isPremium
                        ? 'Preguntas ilimitadas con IA 🔮'
                        : '${user.remainingCards} cartas místicas restantes',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ActivitiesScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A1F38),
              Color(0xFF0F4C75),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.games,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividades',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Gana cartas y recompensas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(UserModel user, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.planName,
                      style: TextStyle(
                        color: user.planColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.isPremium
                          ? 'Todo desbloqueado'
                          : 'Actualiza para más ventajas',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (!user.isPremium)
                ElevatedButton(
                  onPressed: () {
                    userProvider.upgradeToPremium();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⭐ ¡Ahora eres Premium!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('UPGRADE'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              'Cartas', user.isPremium ? '∞' : '${user.remainingCards}'),
          _buildStatItem('Plan', user.planName),
          _buildStatItem(
              'Reset', '${user.lastReset.day}/${user.lastReset.month}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.pink,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildModernProfileScreen(UserModel user, UserProvider userProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E21),
            Color(0xFF1A1F38),
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      user.planColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: user.planColor.withValues(alpha: 0.2),
                        child: Icon(
                          user.planIcon,
                          size: 60,
                          color: user.planColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Aquí iría el resto del perfil...
                const Center(
                  child: Text(
                    'Perfil en construcción',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildModernBottomNavBar(UserModel user) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1A1F38),
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('${user.remainingCards}'),
            isLabelVisible: !user.isPremium,
            child: const Icon(Icons.icecream),
          ),
          label: 'Icebreaker',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Racha',
        ),
        BottomNavigationBarItem(
          icon: Icon(user.planIcon),
          label: 'Perfil',
        ),
      ],
    );
  }
}
