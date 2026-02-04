import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/match_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Luck Reveal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFFD700), // Gold
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700), // Gold
            secondary: Color(0xFF006400), // Dark Green
            surface: Color(0xFF1E1E1E), // Dark Grey
          ),
          fontFamily:
              'Roboto', // Or 'Inter' if available, defaulting to standard
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (authProvider.isAuthenticated) {
      final user = authProvider.currentUser;

      // Si el perfil no está cargado en el UserProvider, lo cargamos
      if (userProvider.user == null && !userProvider.isLoading) {
        // Ejecutamos en el siguiente frame para evitar errores de compilación de build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProvider.fetchUser(user!.uid);
        });
      }

      // Si está cargando el perfil, mostramos loader
      if (userProvider.isLoading || userProvider.user == null) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.pink),
                SizedBox(height: 20),
                Text('Consultando al oráculo...',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
        );
      }

      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
