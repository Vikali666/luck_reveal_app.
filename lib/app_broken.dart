import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models

// Services
import 'services/location_service.dart';
import 'services/auth_service.dart';

// Repositories
import 'repositories/match_repository.dart';
import 'repositories/chat_repository.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/nearby_users_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/upgrade_screen.dart';
import 'screens/slots_machine_screen.dart';

// Providers
import 'providers/user_provider.dart';
import 'providers/match_provider.dart';
import 'providers/chat_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => MatchRepository()),
        Provider(create: (_) => ChatRepository()),
        Provider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
        title: 'Luck Reveal - Citas',
        debugShowCheckedModeBanner: false,
        theme: _buildLuckRevealTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const LuckRevealApp(),
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/preferences': (context) => const PreferencesScreen(),
          '/slot-machine': (context) => const SlotsMachineScreen(),
          '/chat': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?;
            return ChatScreen(
              chatId: args?['chatId'] ?? '',
              otherUserId: args?['otherUserId'] ?? '',
              otherUserName: args?['otherUserName'] ?? 'Usuario',
              otherUserPhotoUrl: args?['otherUserPhotoUrl'],
            );
          },
          '/nearby': (context) => const NearbyUsersScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/upgrade': (context) => const UpgradeScreen(),
        },
      ),
    );
  }

  ThemeData _buildLuckRevealTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      primaryColor: const Color(0xFF00FF88),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FF88),
        secondary: Color(0xFFFFD700),
      ),
    );
  }
}

class LuckRevealApp extends StatefulWidget {
  const LuckRevealApp({super.key});

  @override
  State<LuckRevealApp> createState() => _LuckRevealAppState();
}

class _LuckRevealAppState extends State<LuckRevealApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF003311), Colors.black],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: const Icon(Icons.favorite,
                  size: 140, color: Color(0xFF00FF88)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Luck Reveal',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                letterSpacing: 3,
              ),
            ),
            Text(
              'Bienvenido, ${userProvider.user.displayName}',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 50),
            _chiroButton(context, Icons.location_on, 'Cerca de ti',
                Colors.blueAccent, '/nearby'),
            _chiroButton(context, Icons.casino, 'Ruleta de Suerte',
                Colors.orangeAccent, '/slot-machine'),
            _chiroButton(context, Icons.person, 'Mi Perfil',
                Colors.purpleAccent, '/profile'),
            const SizedBox(height: 40),
            const Text('Intentos totales: 8',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _chiroButton(BuildContext context, IconData icon, String label,
      Color color, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
