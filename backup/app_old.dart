import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String nickname = '';
  String tempNickname = '';
  String currentScreen = 'login';
  int intentos = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carga el apodo y los intentos guardados
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nickname = prefs.getString('nickname') ?? '';
      intentos = prefs.getInt('intentos_ruleta') ?? 0;
      if (nickname.isNotEmpty) currentScreen = 'menu';
    });
  }

  Future<void> _handleLogin() async {
    if (tempNickname.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', tempNickname);
      setState(() {
        nickname = tempNickname;
        currentScreen = 'menu';
      });
    }
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      nickname = '';
      intentos = 0;
      currentScreen = 'login';
    });
  }

  // Lógica de la Suerte (50%, 25%, 5%)
  void _jugarRuleta() async {
    final prefs = await SharedPreferences.getInstance();
    intentos++;
    await prefs.setInt('intentos_ruleta', intentos);

    double probabilidad;
    if (intentos == 1) {
      probabilidad = 0.50;
    } else if (intentos == 2) {
      probabilidad = 0.25;
    } else {
      probabilidad = 0.05;
    }

    bool gana = Random().nextDouble() < probabilidad;

    _mostrarResultado(gana);
    setState(() {}); // Actualiza contador en pantalla
  }

  void _mostrarResultado(bool gana) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          gana ? "¡GANASTE! 🎉" : "Mala suerte...",
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          gana
              ? "Los tréboles se alinearon para ti."
              : "Sigue intentando, Chiro.",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentScreen == 'login') return _buildLogin();
    if (currentScreen == 'nearby') {
      return NearbyScreen(
        onBack: () => setState(() => currentScreen = 'menu'),
        currentNickname: nickname,
      );
    }
    if (currentScreen == 'ruleta') return _buildRuleta();

    return _buildMenu();
  }

  // --- VISTAS SEPARADAS PARA MAYOR ORDEN ---

  Widget _buildLogin() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🍀 Luck Reveal',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _buildInput(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
              ),
              child: const Text('ENTRAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🍀 Luck Reveal',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Bienvenido, $nickname',
            style: const TextStyle(color: Colors.green, fontSize: 18),
          ),
          const SizedBox(height: 50),
          MenuCard(
            icon: '🔍',
            title: 'Cerca de ti',
            badge: 'HOT',
            onTap: () => setState(() => currentScreen = 'nearby'),
          ),
          const SizedBox(height: 20),
          MenuCard(
            icon: '🎰',
            title: 'Ruleta',
            onTap: () => setState(() => currentScreen = 'ruleta'),
          ),
          const SizedBox(height: 20),
          MenuCard(icon: '⚙️', title: 'Salir', onTap: _handleLogout),
          const SizedBox(height: 40),
          Text(
            'Intentos totales: $intentos',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleta() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => currentScreen = 'menu'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🎰 TRAGAPERRAS 🎰",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => _buildSlot()),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _jugarRuleta,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "¡GIRAR!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlot() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      child: const Text("🍀", style: TextStyle(fontSize: 40)),
    );
  }

  Widget _buildInput() {
    return SizedBox(
      width: 250,
      child: TextField(
        onChanged: (value) => setState(() => tempNickname = value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tu apodo...',
          hintStyle: const TextStyle(color: Color(0xFF666666)),
          filled: true,
          fillColor: const Color(0xFF111111),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// --- TUS COMPONENTES DE APOYO ---

class NearbyScreen extends StatelessWidget {
  final VoidCallback onBack;
  final String currentNickname;
  const NearbyScreen({
    super.key,
    required this.onBack,
    required this.currentNickname,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Cerca de ti"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Text(
          "Hola $currentNickname,\nbuscando gente...",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;
  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF222222)),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
