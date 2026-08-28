import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "¡Adiós al desorden! 💸",
      description: "¿A dónde se fue mi dinero? No más dudas. En FinanzaGT usamos el "
          "Sistema de Cubetas para que cada Quetzal tenga un propósito.",
      icon: Icons.account_balance_wallet_outlined,
      color: const Color(0xFF4A47F6),
    ),
    OnboardingContent(
      title: "La Regla de Oro: 50/30/20 📊",
      description: "50% Supervivencia (Comida, Techo).\n30% Santuario (Tus sueños). "
          "\n20% Deudas y Futuro.",
      icon: Icons.pie_chart_outline_rounded,
      color: Colors.orange,
    ),
    OnboardingContent(
      title: "Haz crecer tu Santuario 🌱",
      description: "Define metas reales. Desde un fondo de emergencia hasta ese viaje "
          "que tanto quieres. ¡Nosotros te guiaremos!",
      icon: Icons.eco_outlined,
      color: Colors.green,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        // --- CORRECCIÓN AQUÍ ---
        // Se agregó el parámetro isNewUser: true
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _contents.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          _contents[index].icon,
                          size: 120,
                          color: _contents[index].color
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _contents[index].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _contents[index].description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Indicadores y Botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text("Saltar", style: TextStyle(color: Colors.grey)),
                ),
                Row(
                  children: List.generate(
                    _contents.length,
                        (index) => Container(
                      height: 10,
                      width: _currentIndex == index ? 25 : 10,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _currentIndex == index
                            ? const Color(0xFF4A47F6)
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  backgroundColor: const Color(0xFF4A47F6),
                  onPressed: () {
                    if (_currentIndex == _contents.length - 1) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Icon(
                    _currentIndex == _contents.length - 1
                        ? Icons.check
                        : Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}